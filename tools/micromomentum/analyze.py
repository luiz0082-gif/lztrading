"""Analise dos CSVs do EA MicroMomentum (telemetria v2.00 / v2.10).

Uso:
    python analyze.py                      # usa as 2 plataformas padrao abaixo
    python analyze.py A=<pasta> B=<pasta>  # pastas MQL5/Files/MicroMomentum de cada terminal

Le CSVs em chunks quando grandes (ticks), nao altera nenhum arquivo de origem e
imprime tabelas de: integridade, configuracao por sessao, performance de trades,
exposicao, execucao, bloqueios e reconciliacao de saldo.
"""
import glob
import os
import sys

import numpy as np
import pandas as pd

pd.set_option("display.width", 250, "display.max_rows", 300, "display.max_columns", 60)

ROOTS = {
    "A": r"C:\Users\luiz_\AppData\Roaming\MetaQuotes\Terminal\010E047102812FC0C18890992854220E\MQL5\Files\MicroMomentum",
    "B": r"C:\Users\luiz_\AppData\Roaming\MetaQuotes\Terminal\5194A13C185A318E8062DFAE26191AE3\MQL5\Files\MicroMomentum",
}
for arg in sys.argv[1:]:
    k, _, v = arg.partition("=")
    ROOTS[k] = v

TSF = "%Y.%m.%d %H:%M:%S.%f"


def load(kind, usecols=None):
    out = []
    for plat, root in ROOTS.items():
        for f in glob.glob(os.path.join(root, "*", "*", "*", kind + ".csv")):
            parts = f.split(os.sep)
            df = pd.read_csv(f, usecols=usecols)
            df["plat"], df["day"], df["sess"] = plat, parts[-3], parts[-2]
            out.append(df)
    return pd.concat(out, ignore_index=True) if out else pd.DataFrame()


def ts(s):
    return pd.to_datetime(s, format=TSF, errors="coerce")


def section(title):
    print("\n" + "=" * 100 + f"\n{title}\n" + "=" * 100)


def trade_stats(d):
    w, l = d[d.net > 0], d[d.net <= 0]
    return pd.Series(dict(
        n=len(d), net=d.net.sum(), win=(d.net > 0).mean(), avg_win=w.net.mean(),
        avg_loss=l.net.mean() if len(l) else np.nan, worst=d.net.min(),
        pf=w.net.sum() / -l.net.sum() if len(l) and l.net.sum() < 0 else np.inf,
        exp=d.net.mean(), hold_med_s=d.hold_ms.median() / 1000,
        hold_max_s=d.hold_ms.max() / 1000, mae_min_money=d.mae_money.min(),
        comm=d.commission.sum(), slip=d.entry_slip_pts.mean(),
        spread=d.entry_spread.mean()))


def main():
    trades = load("trades")
    for c in trades.columns.difference(["plat", "day", "sess", "exit_reason", "t_server", "t_local",
                                        "open_time", "close_time"]):
        trades[c] = pd.to_numeric(trades[c], errors="coerce")
    trades["ot"], trades["ct"] = ts(trades.open_time), ts(trades.close_time)

    section("1. INTEGRIDADE")
    for kind in ["trades", "orders", "signals", "events", "params", "account", "transactions"]:
        d = load(kind)
        dup = d.duplicated(["plat", "day", "sess", "seq"]).sum()
        nonmono = sum((g.seq.diff() < 0).sum() for _, g in d.groupby(["plat", "day", "sess"]))
        print(f"{kind:13s} rows={len(d):>8d} dup_seq={dup} seq_nao_monotono={nonmono}")
    print("tickets duplicados em trades:", trades.duplicated(["plat", "ticket"]).sum())

    section("2. CONFIGURACAO POR SESSAO (params.csv)")
    p = load("params")
    cfg = p.pivot_table(index=["plat", "day", "sess"], columns="key", values="value", aggfunc="first").reset_index()
    g = trades.groupby(["plat", "day", "sess"]).agg(n=("net", "size"), net=("net", "sum")).reset_index()
    cfg = cfg.merge(g, how="left", on=["plat", "day", "sess"])
    cols = ["plat", "day", "sess", "ea", "lot_effective", "InpTPMode", "tp_effective", "InpSLMode",
            "InpMaxSpreadPoints", "InpMaxOpenPositions", "InpRecoilEnable", "InpDailyGoalMoney", "n", "net"]
    print(cfg[[c for c in cols if c in cfg.columns]].fillna("").to_string())
    print("\nSessoes com InpSLMode != EXIT_OFF:", (cfg.InpSLMode != "EXIT_OFF").sum(), "de", len(cfg))

    section("3. TRADES")
    print(trade_stats(trades).round(3).to_frame("ALL").T.to_string())
    for col in ["plat", "exit_reason", "dir", "volume"]:
        print(f"\n-- por {col}")
        print(trades.groupby(col).apply(trade_stats).round(3).to_string())
    trades["hour"] = trades.ot.dt.hour
    print("\n-- por hora (servidor)")
    print(trades.groupby("hour").apply(trade_stats)[["n", "net", "win", "worst", "mae_min_money"]].round(2).to_string())
    print("\n-- por dia")
    print(trades.groupby(trades.ot.dt.date).apply(trade_stats)[["n", "net", "win", "worst", "mae_min_money", "hold_max_s"]].round(2).to_string())
    print("\n-- por duracao (s)")
    b = pd.cut(trades.hold_ms / 1000, [0, 10, 30, 60, 300, 900, 3600, 14400], include_lowest=True)
    print(trades.groupby(b, observed=True).apply(trade_stats)[["n", "net", "win", "mae_min_money"]].round(2).to_string())
    print("\n-- what-if stop em dinheiro (usa MAE; ignora slippage do stop)")
    for x in [3, 5, 10, 15, 20, 30]:
        cut = trades.mae_money <= -x
        net = np.where(cut, -x + trades.commission, trades.net)
        print(f"  SL ${x:>2}: cortaria {cut.sum():>3} trades ({cut.mean():.1%})  net={net.sum():8.2f}  real={trades.net.sum():.2f}")
    rng = np.random.default_rng(1)
    boot = [rng.choice(trades.net.values, len(trades)).mean() for _ in range(5000)]
    print("\nIC95 bootstrap expectativa/trade:", np.percentile(boot, [2.5, 97.5]).round(3))
    print("participacao dos 10 maiores trades no net:", round(trades.nlargest(10, "net").net.sum() / trades.net.sum(), 3))

    section("4. EXECUCAO (orders.csv)")
    o = load("orders")
    print(o.groupby(["plat", "action", "ok", "retcode"]).size())
    okd = o[o.retcode == 10009]
    print(okd.groupby(["plat", "action"]).agg(n=("slip_pts", "size"), slip_mean=("slip_pts", "mean"),
                                              slip_p90=("slip_pts", lambda s: s.quantile(.9)),
                                              slip_max=("slip_pts", "max"),
                                              lat_ms_med=("latency_us", lambda s: s.median() / 1000)).round(2))

    section("5. EXPOSICAO (positions.csv, ultimo registro por ticket/segundo)")
    pos = load("positions")
    pos["t"] = ts(pos.t_server).dt.floor("s")
    last = pos.sort_values("seq").groupby(["plat", "t", "ticket"]).tail(1)
    ex = last.groupby(["plat", "t"]).agg(n=("ticket", "size"), net=("net", "sum")).reset_index()
    for plat, d in ex.groupby("plat"):
        print(plat, "max posicoes simultaneas:", d.n.max(), "| pior flutuante EA:", round(d.net.min(), 2),
              "em", d.loc[d.net.idxmin(), "t"])

    section("6. CONTA (account.csv)")
    a = load("account")
    a["t"] = ts(a.t_server)
    for plat, d in a.sort_values(["plat", "t"]).groupby("plat"):
        d = d.copy()
        d["dd"] = d.equity - d.equity.cummax()
        d["db"] = d.balance.diff()
        steps = d[d.db.abs() > 0.001]
        print(f"{plat}: saldo {d.balance.iloc[0]} -> {d.balance.iloc[-1]} | equity min {d.equity.min()} | "
              f"pior flutuante {d.profit.min()} | maior DD pico-vale {d.dd.min():.2f} | "
              f"soma degraus de saldo {steps.db.sum():.2f} | soma net trades.csv {trades[trades.plat == plat].net.sum():.2f}")

    section("7. DEALS FORA DO EA (transactions.csv x trades.csv)")
    tr = load("transactions")
    dl = tr[tr.type == "TRADE_TRANSACTION_DEAL_ADD"].copy()
    dl["in_trades"] = dl.set_index(["plat", "position"]).index.isin(trades.set_index(["plat", "ticket"]).index)
    print(dl.groupby(["plat", "mine", "in_trades"]).size())
    print("req_comment dos deals fora do EA:", dl[~dl.in_trades].req_comment.value_counts(dropna=False).to_dict())

    section("8. EVENTOS E ESTADOS")
    ev = load("events")
    print(ev.groupby(["level", "code"]).size().sort_values(ascending=False).to_string())
    print(ev.state.value_counts().to_string())

    section("9. TICKS (agregado em chunks)")
    cols = ["t_server", "spread_pts", "state", "note", "block_reason"]
    agg = []
    for plat, root in ROOTS.items():
        for f in glob.glob(os.path.join(root, "*", "*", "*", "ticks*.csv")):
            for ch in pd.read_csv(f, usecols=lambda c: c in cols, chunksize=500000, low_memory=False):
                ch["hour"] = ts(ch.t_server).dt.hour
                agg.append(ch.groupby(["state", "note", "block_reason", "hour"], dropna=False)
                           .agg(n=("spread_pts", "size"), s=("spread_pts", "sum"), mx=("spread_pts", "max")).reset_index())
    ag = pd.concat(agg)
    tot = ag.n.sum()
    print("ticks:", tot)
    print((ag.groupby("state", dropna=False).n.sum().sort_values(ascending=False) / tot * 100).round(2).to_string())
    print((ag.groupby("note", dropna=False).n.sum().sort_values(ascending=False) / tot * 100).round(2).to_string())
    print("spread medio:", round(ag.s.sum() / tot, 2), "max:", ag.mx.max())


if __name__ == "__main__":
    main()
