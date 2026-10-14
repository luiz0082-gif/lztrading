"""Analise dos CSVs do EA FluxMatrix PRO (telemetria schema 1-3).

Uso:
    python analyze.py                         # IC e FP (pastas padrao abaixo)
    python analyze.py BT=<pasta>              # adiciona uma pasta (ex.: agente do Strategy Tester)

Somente leitura. Imprime, por plataforma: baskets (resultado, pernas, MAE, duracao),
risco (pior flutuante, volume, margem), integridade (deals duplicados / alheios)
e funil de sinais. Nao altera nenhum arquivo de origem.
"""
import collections
import csv
import datetime as dt
import glob
import os
import statistics as st
import sys

TERM = os.path.expandvars(r"%APPDATA%\MetaQuotes\Terminal")
ROOTS = {
    "IC": TERM + r"\010E047102812FC0C18890992854220E\MQL5\Files\FluxMatrix_PRO",
    "FP": TERM + r"\5194A13C185A318E8062DFAE26191AE3\MQL5\Files\FluxMatrix_PRO",
}
for arg in sys.argv[1:]:
    k, _, v = arg.partition("=")
    ROOTS[k] = v


def load(root, fam):
    rows = []
    for f in sorted(glob.glob(os.path.join(root, fam + "_*_PART*.csv"))):
        with open(f, encoding="utf-8", errors="replace", newline="") as fh:
            r = csv.reader(fh, delimiter=";")
            hdr = next(r, None)
            if not hdr:
                continue
            for row in r:
                row += [""] * (len(hdr) - len(row))
                rows.append(dict(zip(hdr, row)))
    return rows


def kv(detail):
    out = {}
    for p in detail.split(" | "):
        if "=" in p:
            k, v = p.split("=", 1)
            out[k.strip()] = v.strip()
    return out


def num(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return None


def pt(s):
    return dt.datetime.strptime(s, "%Y.%m.%d %H:%M:%S")


def baskets(root):
    """BASKET_CLOSED deduplicado (o schema v2 gravava o mesmo fechamento em 2 eventos)."""
    seen, out = set(), []
    for r in load(root, "BASKET_SUMMARY"):
        if r["Event"] != "BASKET_CLOSED":
            continue
        key = (r["BasketID"], r["ServerTime"])
        d = kv(r["Detail"])
        if key in seen or "Realized" not in d:
            continue
        seen.add(key)
        d.update(t=r["ServerTime"], cfg=r["ConfigHash"])
        out.append(d)
    return out


def report(name, root):
    print("=" * 78, "\n", name, root, "\n", "=" * 78, sep="")
    B = baskets(root)
    if not B:
        print("sem baskets")
        return
    R = [num(b["Realized"]) for b in B]
    D = [num(b["DurationSec"]) for b in B]
    print(f"baskets {len(B)}  net {sum(R):.2f}  ganhos {sum(1 for x in R if x > 0)}  "
          f"perdas {sum(1 for x in R if x <= 0)}  pior {min(R):.2f}  melhor {max(R):.2f}")
    print(f"duracao s: mediana {st.median(D):.0f}  max {max(D):.0f}  >1h {sum(1 for x in D if x > 3600)}  "
          f">3h {sum(1 for x in D if x > 10800)}")
    L = [int(b["Legs"]) for b in B]
    print("alcance de nivel:", {k: f"{sum(1 for x in L if x >= k)} ({100 * sum(1 for x in L if x >= k) / len(L):.1f}%)"
                                 for k in range(2, max(L) + 1)})
    print("saida:", dict(collections.Counter(b["ExitReason"] for b in B)),
          " direcao:", dict(collections.Counter(b["Direction"] for b in B)))
    by = collections.defaultdict(list)
    for b in B:
        by[int(b["Legs"])].append(b)
    print("pernas | n | R medio | MAE medio | MAE max | dur media min")
    for k in sorted(by):
        l = by[k]
        print(f"  {k}     {len(l):3d}  {st.mean(num(x['Realized']) for x in l):7.2f}  "
              f"{st.mean(num(x['MAE']) for x in l):9.1f}  {max(num(x['MAE']) for x in l):8.1f}  "
              f"{st.mean(num(x['DurationSec']) for x in l) / 60:8.0f}")
    day = collections.defaultdict(float)
    for b in B:
        day[b["t"][:10]] += num(b["Realized"])
    print("por dia:", {k: round(v, 2) for k, v in sorted(day.items())})
    print("piores MAE:")
    for b in sorted(B, key=lambda b: -num(b["MAE"]))[:5]:
        print(f"  {b['t']} {b['Direction']} pernas={b['Legs']} MAE={b['MAE']} Realized={b['Realized']} dur={b['DurationSec']}s")

    # risco
    S = []
    for r in load(root, "RISK_STATE"):
        if r["Event"] != "RISK_SNAPSHOT":
            continue
        d = kv(r["Detail"])
        if num(d.get("BasketProfit")) is None:
            continue
        S.append((r["ServerTime"], num(d["BasketProfit"]), int(d.get("Positions", 0)),
                  num(d.get("Volume")), num(d.get("MarginLevel")), num(d.get("MaxBasketVolume"))))
    if S:
        w = min(S, key=lambda x: x[1])
        print(f"risco: snapshots {len(S)}  pior flutuante {w[1]:.2f} em {w[0]} ({w[2]} pernas, {w[3]} lotes, ML {w[4]})")
        print("       MaxBasketVolume vistos:", dict(collections.Counter(x[5] for x in S)))

    # integridade
    deals = {}
    dup = 0
    for r in load(root, "DEALS_EXPORT"):
        if r["Event"] != "DEAL_OBSERVED":
            continue
        k = kv(r["Detail"]).get("Deal")
        dup += k in deals
        deals[k] = pt(r["ServerTime"])
    W = []
    for b in B:
        e = pt(b["t"])
        W.append((e - dt.timedelta(seconds=num(b["DurationSec"]) + 5), e + dt.timedelta(seconds=5)))
    if deals and W:
        first = min(a for a, _ in W)
        after = [t for t in deals.values() if t >= first]
        inside = sum(1 for t in after if any(a <= t <= b for a, b in W))
        print(f"integridade: deals distintos {len(deals)}  linhas duplicadas {dup}  "
              f"fora de qualquer basket (alheios) {len(after) - inside}/{len(after)}  "
              f"pernas proprias {sum(L)} (~{2 * sum(L)} deals esperados)")

    # funil
    c = collections.Counter()
    for r in load(root, "SIGNAL_FUNNEL"):
        if r["Event"] == "SIGNAL_REJECTED":
            c["REJEITADO:" + str(kv(r["Detail"]).get("Reason"))] += 1
        elif r["Event"] == "NO_SETUP":
            c["NO_SETUP:" + r["Detail"].split(" | ")[0]] += 1
        elif r["Event"] == "SIGNAL_APPROVED":
            c["APROVADO"] += 1
    print("funil:", c.most_common(8))


if __name__ == "__main__":
    for n, p in ROOTS.items():
        report(n, p)
