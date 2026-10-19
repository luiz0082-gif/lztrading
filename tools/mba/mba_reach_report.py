#!/usr/bin/env python3
"""Reach study: writes one Markdown report per asset (sections A-I) from the CSVs of mba_reach_analyze.py / mba_reach_struct.py /
mba_reach_summary.py.   python tools/mba/mba_reach_report.py --out docs/relatorios/mba/reach --cache <m1cache>
"""
import argparse, glob, json, os, sys
import numpy as np
import pandas as pd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mba_reach_summary import SYMS, M1_LONG

sys.stdout.reconfigure(encoding="utf-8")


def md(df, nd=1):
    if df is None or len(df) == 0:
        return "_(vazio)_\n"
    d = df.copy()
    for c in d.columns:
        if d[c].dtype.kind == "f":
            d[c] = d[c].map(lambda v: "" if pd.isna(v) else f"{v:,.{nd}f}")
    cols = [str(c) for c in d.columns]
    out = "| " + " | ".join(cols) + " |\n|" + "|".join("---" for _ in cols) + "|\n"
    for _, r in d.iterrows():
        out += "| " + " | ".join(str(v) for v in r.values) + " |\n"
    return out


def rd(p, **kw):
    try:
        return pd.read_csv(p, **kw) if os.path.exists(p) else None
    except pd.errors.EmptyDataError:
        return None


def section_asset(out, cache, sym, audit, T, ST, C, G):
    od = os.path.join(out, sym)
    L = [f"# {sym} — investigação de alcance, horário e repetição\n"]
    # ---------------- A
    L.append("## A. Qualidade e cobertura dos dados\n")
    a = audit[audit["symbol"].str.replace(".", "_") == sym]
    L.append(md(a[["tf", "first", "last", "trading_days", "bars", "gaps_gt_bar", "gaps_gt15m", "max_gap_min", "pct_tick_spread", "spread_med", "spread_p90", "bad_ohlc", "dup_time"]]))
    sp = a.iloc[0] if len(a) else None
    if sp is not None:
        L.append(f"\nPonto MT5 = {sp['point']}, tick size = {sp['tick_size']}, tick value = {sp['tick_value']} (USD por tick por lote), contrato = {sp['contract_size']}. "
                 f"Barras de BID. Custo = spread medido nos ticks (perfil por faixa de 30 min do servidor onde não há tick) + swap; comissão não declarada pela corretora (não incluída).\n")
    if sym not in M1_LONG:
        L.append("\n**Limitação:** o M1 deste ativo só cobre ~mar/abr–out/2026 (≈140–158 dias, um único regime). Resultados de M1 são exploratórios; a confirmação vem de M5 (mai/2025→) e M15 (jan/2024→).\n")
    # ---------------- C
    L.append("\n## C. Distâncias percorridas (operação executável, líquida de spread)\n")
    for tag in ("M15_W60", "M15_W240", "M1_W60"):
        d = rd(os.path.join(od, f"C_distancias_{tag}.csv"))
        if d is None:
            continue
        L.append(f"\n**{tag.replace('_W', ', janela ')} min** — `net_reach` = % das entradas (todas as barras, seg–sex) em que a operação chegou a +k pts líquidos dentro da janela; "
                 "`t_*` = minutos até chegar; `mae_before` = quanto andou contra ANTES de chegar; `race_*` = corrida contra limite adverso de k pts (mesma barra = indeterminado, contado como perda).\n\n")
        L.append(md(d[["k_pts", "side", "n", "gross_reach_pct", "net_reach_pct", "ci95", "t_med_min", "t_p90_min", "mae_before_med", "mae_before_p90",
                       "race_win_pct", "race_loss_pct", "race_samebar_pct", "race_win_of_determined_pct"]]))
    # ---------------- B (hour x k reach) + top minutes
    L.append("\n## B. Varredura por horário (servidor)\n")
    h = rd(os.path.join(od, "C_alcance_por_hora_M15_W60.csv"))
    if h is not None:
        ks = sorted(h["k_pts"].unique())
        pick = [k for k in ks if k in (100, 300, 600, 1000, 2000)] or ks[:4]
        p = h[h["k_pts"].isin(pick)].pivot_table(index="hour", columns=["side", "k_pts"], values="reach_pct")
        p.columns = [f"{s} ≥{k}" for s, k in p.columns]
        L.append("\n% de entradas (M15, janela 60 min) que alcançaram a distância, por hora do servidor:\n\n")
        L.append(md(p.reset_index(), 1))
    tf_b = "M1" if os.path.exists(os.path.join(od, "B_varredura_relogio_M1_W60.csv.gz")) else "M5"
    b = rd(os.path.join(od, f"B_varredura_relogio_{tf_b}_W60.csv.gz"))
    if b is not None:
        ks = sorted(b["k_pts"].unique()); kmid = ks[len(ks) // 2]
        bb = b[b["k_pts"] == kmid].copy()
        bb["buy_menos_sell"] = bb["buy_pct"] - bb["sell_pct"]
        L.append(f"\nMinuto a minuto ({tf_b}, janela 60 min, k = {kmid} pts; tabela completa em `B_varredura_relogio_{tf_b}_W60.csv.gz` com todos os minutos e limiares). "
                 f"Maiores e menores taxas de alcance:\n\n")
        cols = ["clock", "n", "buy_hits", "buy_pct", "sell_hits", "sell_pct", "up_first_pct", "down_first_pct", "buy_t_med_min", "buy_mae_med"]
        L.append("Maior alcance (BUY):\n\n" + md(bb.sort_values("buy_pct", ascending=False).head(10)[cols]))
        L.append("\nMaior alcance (SELL):\n\n" + md(bb.sort_values("sell_pct", ascending=False).head(10)[cols]))
        L.append("\nMenor alcance (mercado parado):\n\n" + md(bb.sort_values("buy_pct").head(5)[cols]))
        L.append("\nMaior assimetria BUY−SELL (só descritivo; o teste de direção está na seção E):\n\n" + md(bb.reindex(bb["buy_menos_sell"].abs().sort_values(ascending=False).index).head(10)[cols + ["buy_menos_sell"]]))
    # ---------------- E
    L.append("\n## E. Direção (BUY vs SELL) por horário — teste contra o próprio dia\n")
    L.append("y = +1 se o preço anda +k antes de −k, −1 no contrário. Tira-se a média do dia (dias de tendência não contam como sinal) e testa-se cada horário. "
             "Descoberta 60% / validação 40% cronológicos; BH na descoberta; placebo = troca aleatória de sinal por dia (200×).\n\n")
    t = T[T["symbol"] == sym][["tf", "W", "clock", "dir_tests", "dir_validated", "dir_fwer_and_val", "dir_placebo_mean", "dir_placebo_max"]]
    L.append(md(t, 2))
    rows = []
    for f in sorted(glob.glob(os.path.join(od, "E_direcao_*.csv*"))):
        d = rd(f)
        if d is not None and len(d) and d["validated"].any():
            v = d[d["validated"]].copy(); v["arquivo"] = os.path.basename(f).replace("E_direcao_", "").replace(".csv.gz", "").replace(".csv", "")
            rows.append(v)
    if rows:
        v = pd.concat(rows)
        g = v.groupby(["arquivo", "clock", "direction"]).agg(ks=("k_pts", lambda s: ",".join(map(str, sorted(s)))), n_dias=("n_days", "max"),
                                                            sobe_antes=("up_first_pct", "median"), cai_antes=("down_first_pct", "median"),
                                                            t_desc=("t_disc", lambda s: s.abs().max()), t_val=("t_val", lambda s: s.abs().max()),
                                                            fwer=("fwer_disc", "any")).reset_index()
        L.append("\nHorários validados (descoberta + validação):\n\n" + md(g.sort_values("t_desc", ascending=False).head(40), 2))
    else:
        L.append("\nNenhum horário com direção validada.\n")
    # ---------------- G
    L.append("\n## G. Operação executável por horário (alvo k, limite k / 2k / sem limite; custo e swap incluídos)\n")
    t = T[T["symbol"] == sym][["tf", "W", "clock", "ev_tests", "ev_validated", "ev_validated_bh", "ev_clocks", "ev_placebo_mean", "ev_placebo_max"]]
    L.append(md(t, 2))
    if C is not None and len(C):
        c = C[C["symbol"] == sym]
        if len(c):
            c = c.sort_values("t_val", ascending=False).groupby(["tf", "W", "side", "clock"]).head(1)
            L.append("\nCombinações validadas (descoberta t≥3 e validação t≥1,645, média líquida > 0 nos dois períodos, com perdas na validação). "
                     "`confirmado_em` = outro timeframe com o mesmo lado a ±10 min; `rolagem` = entrada ou janela tocando 23:00–01:15 do servidor (cotações de bid distorcidas pelo spread da rolagem):\n\n")
            L.append(md(c[["tf", "W", "clock", "side", "k_pts", "adverse", "n_days", "win_pct", "ev_pts", "ev_disc", "t_disc", "ev_val", "t_val", "years_pos", "bh_disc", "confirmed_in", "rolagem"]].head(40), 1))
    # ---------------- D
    L.append("\n## D. Padrões estruturais (condição × hora/sessão, além do efeito do relógio)\n")
    s = ST[ST["symbol"] == sym]
    L.append(md(s[["tf", "W", "k_tested", "tests", "validated", "race", "ev_buy", "ev_sell", "placebo_mean", "placebo_max"]], 2))
    for f in sorted(glob.glob(os.path.join(od, "D_estruturais_*.csv*"))):
        d = rd(f)
        if d is not None and len(d) and d["validated"].any():
            L.append(f"\n`{os.path.basename(f)}` — validados:\n\n" + md(d[d["validated"]].head(20)[["k_pts", "outcome", "cond", "n_entries", "days_disc", "excess_disc", "t_disc", "excess_val", "t_val", "raw_val"]], 2))
    # ---------------- F
    L.append("\n## F. Distância × tempo e devolução\n")
    d = rd(os.path.join(od, "F_devolucao_apos_alvo_M15_W240.csv"))
    if d is not None:
        L.append("Das entradas que chegaram a +k (M15, janela 240 min), quantas terminaram a janela no prejuízo (o alvo foi tocado e devolvido):\n\n" + md(d))
    # ---------------- I
    L.append("\n## I. Outras regularidades\n")
    d = rd(os.path.join(od, "I_hora_max_min_dia_M15.csv"))
    if d is not None:
        d = d.rename(columns={d.columns[0]: "hora"})
        L.append("Hora do servidor em que se formou a máxima / mínima do dia (% dos dias, M15):\n\n" + md(d, 1))
    d = rd(os.path.join(od, "I_continuidade_M15.csv"))
    if d is not None:
        L.append("\nContinuidade entre sessões (mesmo sinal do movimento; 50% = sem relação):\n\n" + md(d, 2))
    g = G[G["symbol"] == sym] if G is not None else None
    if g is not None and len(g):
        L.append("\nGap de segunda-feira (abertura da semana vs fechamento de sexta) fechado no mesmo dia, comparado com a chance de o preço andar a mesma distância nos outros dias:\n\n" + md(g, 1))
    open(os.path.join(od, "RELATORIO.md"), "w", encoding="utf-8").write("\n".join(L))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True); ap.add_argument("--cache", required=True)
    a = ap.parse_args()
    audit = pd.read_csv(os.path.join(a.out, "auditoria_candles.csv"))
    T = pd.read_csv(os.path.join(a.out, "H_contagem_vs_placebo_relogio.csv"))
    ST = pd.read_csv(os.path.join(a.out, "H_contagem_vs_placebo_estrutural.csv"))
    C = rd(os.path.join(a.out, "H_candidatos_ev_relogio.csv"))
    G = rd(os.path.join(a.out, "I_gap_segunda.csv"))
    for sym in SYMS:
        section_asset(a.out, a.cache, sym, audit, T, ST, C, G)
        print("ok", sym)


if __name__ == "__main__":
    main()
