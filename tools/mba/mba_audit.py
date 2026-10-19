#!/usr/bin/env python3
"""MBA v1.23 collection audit (read-only).

Checks a LIVE folder written by MarketBehaviorAnalyzer_EA (schema 3) and answers: is the collection complete and consistent?
  python tools/mba/mba_audit.py --live "<Common>/Files/MarketBehaviorAnalyzer/<broker>/<symbol>/LIVE"

Per timeframe: parts/headers, rows, duplicate event_key, time gaps (bars missing inside the series, weekend/holiday gaps listed apart),
OHLC sanity, server-vs-tick OHLC audit (ohlc_vs_ticks), tick aggregates vs candles, UTC offset vs NY-close DST rule,
FORWARD_TIME completeness, last META/data_quality snapshot, RAW_TICKS monotonic time.
Nothing is modified.
"""
import argparse, csv, glob, os, sys
from collections import Counter
from datetime import datetime, timedelta

TFS = ["M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1"]
SEC = {"M1": 60, "M5": 300, "M15": 900, "M30": 1800, "H1": 3600, "H4": 14400, "D1": 86400, "W1": 604800}
FMT = "%Y.%m.%d %H:%M:%S"


def rows(folder, base, schema="3"):
    """Yield dict rows of every part whose rows carry the given schema_version (parts with other headers are counted, not mixed)."""
    other = 0
    out = []
    for fn in sorted(glob.glob(os.path.join(folder, base + "_part*.csv"))):
        with open(fn, newline="", encoding="utf-8-sig") as fh:
            rd = csv.DictReader(fh)
            if rd.fieldnames is None:
                continue
            if "schema_version" in rd.fieldnames:
                for r in rd:
                    if r.get("schema_version") == schema:
                        out.append(r)
                    else:
                        other += 1
            else:
                out.extend(rd)
    return out, other


def t(s):
    return datetime.strptime(s, FMT)


def us_dst_offset(server_dt):
    """NY-close server: +3h during US DST (2nd Sunday of March .. 1st Sunday of November), else +2h (day granularity)."""
    y = server_dt.year
    d = datetime(y, 3, 1)
    sun1 = d + timedelta(days=(6 - d.weekday()) % 7)
    start = sun1 + timedelta(days=7)
    n = datetime(y, 11, 1)
    end = n + timedelta(days=(6 - n.weekday()) % 7)
    return 3 if start <= server_dt.replace(hour=0, minute=0, second=0) < end else 2


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--live", required=True)
    ap.add_argument("--schema", default="3")
    a = ap.parse_args()
    live = a.live
    problems = 0
    print(f"LIVE folder: {live}\n")
    for tf in TFS:
        c, other = rows(os.path.join(live, "CANDLES"), f"candles_{tf}", a.schema)
        if not c:
            print(f"[{tf}] no schema-{a.schema} rows" + (f" ({other} rows of other schemas ignored)" if other else ""))
            continue
        keys = Counter(r["event_key"] for r in c)
        dup = sum(v - 1 for v in keys.values() if v > 1)
        times = sorted(t(r["server_time"]) for r in c)
        gaps, big = 0, []
        if tf in SEC:
            for p, q in zip(times, times[1:]):
                miss = int((q - p).total_seconds() // SEC[tf]) - 1
                if miss > 0:
                    gaps += 1
                    big.append((miss, p))
        # weekend/holiday gaps are normal for FX/metals; list only the 5 largest so they can be eyeballed
        big.sort(reverse=True)
        bad_ohlc = sum(1 for r in c if not (float(r["low"]) <= min(float(r["open"]), float(r["close"])) and float(r["high"]) >= max(float(r["open"]), float(r["close"]))))
        oc = Counter(r.get("ohlc_vs_ticks", "") for r in c)
        tick_ok = sum(1 for r in c if r["tick_data_ok"] == "TRUE")
        # UTC check (only meaningful for the NY-close rule)
        utc_bad = 0
        rule_rows = [r for r in c if r["utc_basis"].startswith("RULE_NY_CLOSE")]
        for r in rule_rows:
            st = t(r["server_time"])
            if int(r["server_utc_offset_sec"]) != us_dst_offset(st) * 3600:
                utc_bad += 1
        ta, _ = rows(os.path.join(live, "TICKS"), f"tick_aggregate_{tf}", a.schema)
        ta_keys = {(r["start_time"]) for r in ta}
        no_agg = sum(1 for r in c if r["tick_data_ok"] == "TRUE" and r["server_time"] not in ta_keys) if ta else None
        print(f"[{tf}] candles={len(c)} (other-schema rows ignored: {other}) {times[0]} .. {times[-1]}")
        print(f"      duplicate event_key={dup}  gaps={gaps}  largest gaps (bars,after)={[(m, str(p)) for m, p in big[:5]]}")
        print(f"      OHLC incoherent={bad_ohlc}  tick_data_ok={tick_ok}  ohlc_vs_ticks={dict(oc)}")
        print(f"      rows with DST rule={len(rule_rows)}  offset != rule={utc_bad}  tick_aggregate rows={len(ta)}  tick_ok without aggregate row={no_agg}")
        problems += dup + bad_ohlc + utc_bad + oc.get("DIFF", 0) // 1000
        # forward time
        ft, _ = rows(os.path.join(live, "FORWARD_TIME"), f"forward_time_{tf}", a.schema)
        if ft:
            k = Counter(r["forward_key"] for r in ft)
            fd = sum(v - 1 for v in k.values() if v > 1)
            comp = sum(1 for r in ft if r["complete"] == "TRUE")
            print(f"      FORWARD_TIME rows={len(ft)} duplicate forward_key={fd} complete={comp} ({100 * comp / len(ft):.1f}%)")
            problems += fd
    # data quality
    dq, _ = rows(os.path.join(live, "META"), "data_quality", a.schema) if glob.glob(os.path.join(live, "META", "data_quality_part*.csv")) else ([], 0)
    if dq:
        last = {}
        for r in dq:
            last[r["timeframe"]] = r
        print("\nLast META/data_quality snapshot per series:")
        for k, r in last.items():
            print(f"  {k:10s} status={r['status']:18s} expected={r['expected_bars_run']} written={r['candles_written_run']} missing={r['missing_vs_terminal']} skipped={r['bars_skipped']} retries={r['bar_retries']} wfail={r['write_failures']} ohlc_diff={r['ohlc_diff']}/{r['ohlc_checked']} raw_lag_ms={r['raw_lag_ms']}")
            if r["status"] not in ("OK", "NO_BARS_THIS_RUN", "WAITING_HISTORY"):
                problems += 1
    # raw ticks
    last_msc, n, back, dupe = 0, 0, 0, 0
    prev = None
    for fn in sorted(glob.glob(os.path.join(live, "RAW_TICKS", "raw_ticks_part*.csv"))):
        with open(fn, newline="", encoding="utf-8-sig") as fh:
            for r in csv.DictReader(fh):
                m = int(r["time_msc"])
                n += 1
                if m < last_msc:
                    back += 1
                if (m, r["bid"], r["ask"], r["last"], r["volume"]) == prev:
                    dupe += 1
                prev = (m, r["bid"], r["ask"], r["last"], r["volume"])
                last_msc = max(last_msc, m)
    print(f"\nRAW_TICKS rows={n} time going backwards={back} identical consecutive rows={dupe}")
    print(f"\n{'PROBLEMS FOUND: ' + str(problems) if problems else 'No structural problems found (this does not prove completeness against the broker feed).'}")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
