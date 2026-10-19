#!/usr/bin/env python3
"""Load + audit MBA M1 candles for the reach study (mba_reach.py) and cache them as .npz.

For each symbol: reads LIVE/CANDLES/candles_M1_part*.csv (schema 3), drops duplicate event_key, sorts by server time, recomputes UTC with the
New-York-close rule (server = UTC+3 during US DST, UTC+2 otherwise), keeps bid OHLC + tick-measured spread, and writes an audit row:
coverage, duplicates, out-of-order rows, OHLC inconsistencies, gaps inside the trading week, share of bars with tick-measured spread.

  python tools/mba/mba_reach_load.py --root "<Common/Files/MarketBehaviorAnalyzer>" --cache <dir> --out docs/relatorios/mba/reach
"""
import argparse, glob, json, os, sys
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
COLS = ["event_key", "server_time", "open", "high", "low", "close", "tick_volume", "tick_data_ok", "spread_avg_points",
        "bar_spread_points", "schema_version"]
TF_MIN = {"M1": 1, "M5": 5, "M15": 15}
SYMBOLS = [("Raw_Trading_Ltd", "XAUUSD"), ("Raw_Trading_Ltd", "XAGUSD"), ("Raw_Trading_Ltd", "US30"), ("Raw_Trading_Ltd", "DXY_Z6"),
           ("Raw_Trading_Ltd", "USDJPY"), ("Raw_Trading_Ltd", "EURJPY"), ("Raw_Trading_Ltd", "GBPJPY"), ("Raw_Trading_Ltd", "USDCHF"),
           ("First_Prudential_Markets_Lim", "AUDUSD"), ("First_Prudential_Markets_Lim", "NZDUSD_r")]


def us_dst(t_srv):
    """True when the US is on daylight time. Server clock = NY + 7h, so NY local = server - 7h; DST 2nd Sun Mar 02:00 .. 1st Sun Nov 02:00 NY."""
    ny = pd.DatetimeIndex(pd.to_datetime(t_srv)) - pd.Timedelta(hours=7)
    out = np.zeros(len(ny), bool)
    for y in np.unique(ny.year):
        d = pd.Timestamp(int(y), 3, 1); start = d + pd.Timedelta(days=(6 - d.weekday()) % 7 + 7, hours=2)
        n = pd.Timestamp(int(y), 11, 1); end = n + pd.Timedelta(days=(6 - n.weekday()) % 7, hours=2)
        out |= np.asarray((ny >= start) & (ny < end))
    return out


def uk_dst(t_utc):
    u = pd.DatetimeIndex(pd.to_datetime(t_utc))
    out = np.zeros(len(u), bool)
    for y in np.unique(u.year):
        m = pd.Timestamp(int(y), 3, 31); start = m - pd.Timedelta(days=(m.weekday() + 1) % 7) + pd.Timedelta(hours=1)
        o = pd.Timestamp(int(y), 10, 31); end = o - pd.Timedelta(days=(o.weekday() + 1) % 7) + pd.Timedelta(hours=1)
        out |= np.asarray((u >= start) & (u < end))
    return out


def read_spec(live):
    fs = sorted(glob.glob(os.path.join(live, "META", "symbol_spec_part*.csv")))
    if not fs:
        return {}
    s = pd.read_csv(fs[-1]).iloc[-1]
    keys = ["broker", "server", "symbol", "description", "digits", "point", "tick_size", "tick_value", "contract_size", "volume_min",
            "volume_step", "spread_now_points", "swap_long", "swap_short", "swap_mode", "commission_per_lot_declared", "commission_known", "server_utc_offset_sec"]
    return {k: (s[k].item() if hasattr(s[k], "item") else s[k]) for k in keys if k in s}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True); ap.add_argument("--cache", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--tfs", nargs="+", default=["M1", "M5", "M15"])
    a = ap.parse_args()
    os.makedirs(a.cache, exist_ok=True); os.makedirs(a.out, exist_ok=True)
    rows, specs = [], {}
    for broker, sym in SYMBOLS:
      for tf in a.tfs:
        live = os.path.join(a.root, broker, sym, "LIVE")
        parts = sorted(glob.glob(os.path.join(live, "CANDLES", f"candles_{tf}_part*.csv")))
        d = pd.concat([pd.read_csv(f, usecols=lambda c: c in COLS, low_memory=False) for f in parts], ignore_index=True)
        n_raw = len(d)
        d = d[d["schema_version"].astype(str) == "3"]
        n_s3 = len(d)
        t_raw = pd.to_datetime(d["server_time"], format="%Y.%m.%d %H:%M:%S")
        out_of_order = int((t_raw.diff().dt.total_seconds() < 0).sum())
        d = d.assign(t=t_raw).drop_duplicates("event_key")
        n_dup_key = n_s3 - len(d)
        n_dup_t = int(d.duplicated("t").sum())
        d = d.drop_duplicates("t").sort_values("t").reset_index(drop=True)
        # drop leading fragments (< 1000 bars) separated by > 7 days from the main block (the v1.23 catch-up cap left 1 stray bar in 2024)
        seg = np.concatenate([[0], np.cumsum(np.diff(d["t"].to_numpy("datetime64[m]").astype("int64")) > 7 * 1440)])
        sizes = np.bincount(seg); keep_from = next(i for i, n in enumerate(sizes) if n >= 1000)
        n_frag = int((seg < keep_from).sum()); d = d[seg >= keep_from].reset_index(drop=True)
        spec = read_spec(live); specs[sym] = spec
        pt = float(spec["point"])
        o, h, l, c = (d[k].to_numpy(float) for k in ("open", "high", "low", "close"))
        bad_ohlc = int(((h < np.maximum(o, c) - 1e-9) | (l > np.minimum(o, c) + 1e-9) | (h < l)).sum())
        tok = d["tick_data_ok"].astype(str).str.upper().eq("TRUE").to_numpy()
        spr = np.where(tok, d["spread_avg_points"].to_numpy(float), d["bar_spread_points"].to_numpy(float))
        t = d["t"].to_numpy("datetime64[m]")
        dst = us_dst(d["t"])
        utc = d["t"] - pd.to_timedelta(np.where(dst, 3, 2), unit="h")
        ldn = utc + pd.to_timedelta(np.where(uk_dst(utc), 1, 0), unit="h")
        # gaps: consecutive bars > 1 min apart, excluding the weekend (Fri -> Sun/Mon) and the daily 23:5x -> 01:0x break
        dt = np.diff(t).astype(int)
        tt = d["t"]
        wk = (tt.dt.dayofweek.to_numpy()[1:] < tt.dt.dayofweek.to_numpy()[:-1]) | (dt > 2 * 24 * 60)
        daily = (tt.dt.hour.to_numpy()[:-1] >= 23) & (tt.dt.hour.to_numpy()[1:] <= 1)
        gap = (dt > 1) & ~wk & ~daily
        big = (dt > 15) & ~wk & ~daily
        days = pd.Series(tt.dt.normalize().unique())
        np.savez_compressed(os.path.join(a.cache, f"{sym}_{tf}.npz"), t=t.astype("int64"), tv=d["tick_volume"].to_numpy(float), barmin=TF_MIN[tf], o=o, h=h, l=l, c=c, spr=spr, tok=tok,
                            utc=utc.to_numpy("datetime64[m]").astype("int64"), ldn=ldn.to_numpy("datetime64[m]").astype("int64"), point=pt)
        rows.append(dict(symbol=spec.get("symbol", sym), tf=tf, dropped_fragment_bars=n_frag, broker=spec.get("broker"), point=pt, digits=spec.get("digits"),
                         tick_size=spec.get("tick_size"), tick_value=spec.get("tick_value"), contract_size=spec.get("contract_size"),
                         first=str(tt.iloc[0]), last=str(tt.iloc[-1]), trading_days=len(days), bars=len(d), raw_rows=n_raw,
                         non_schema3=n_raw - n_s3, dup_event_key=n_dup_key, dup_time=n_dup_t, out_of_order=out_of_order, bad_ohlc=bad_ohlc,
                         gaps_gt_bar=int(((dt > TF_MIN[tf]) & ~wk & ~daily).sum()), gaps_gt15m=int(big.sum()), max_gap_min=int(dt[~wk & ~daily].max()) if (~wk & ~daily).any() else 0,
                         pct_tick_spread=round(100 * tok.mean(), 1), spread_med=round(float(np.nanmedian(spr)), 1),
                         spread_p90=round(float(np.nanpercentile(spr, 90)), 1), commission_known=spec.get("commission_known")))
        print(rows[-1], flush=True)
    pd.DataFrame(rows).to_csv(os.path.join(a.out, "auditoria_candles.csv"), index=False)
    json.dump(specs, open(os.path.join(a.out, "symbol_specs.json"), "w"), indent=1, default=str)


if __name__ == "__main__":
    main()
