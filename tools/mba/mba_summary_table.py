#!/usr/bin/env python3
"""One-row-per-asset summary table from the mba_day / mba_slots outputs."""
import glob, os, re, sys
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mba_report as r
from mba_report import md_table

B = "C:/Users/luiz_/AppData/Roaming/MetaQuotes/Terminal/Common/Files/MarketBehaviorAnalyzer"
D = "docs/relatorios/mba/padroes_dia"
S = "docs/relatorios/mba/padroes"
LIVE = {"XAUUSD": "Raw_Trading_Ltd", "XAGUSD": "Raw_Trading_Ltd", "USDJPY": "Raw_Trading_Ltd", "EURJPY": "Raw_Trading_Ltd", "GBPJPY": "Raw_Trading_Ltd", "USDCHF": "Raw_Trading_Ltd",
        "NZDUSD": "First_Prudential_Markets_Lim", "AUDUSD": "First_Prudential_Markets_Lim", "DXY": "Raw_Trading_Ltd", "US30": "Raw_Trading_Ltd", "DE40": "Raw_Trading_Ltd",
        "USTEC": "Raw_Trading_Ltd", "US500": "Raw_Trading_Ltd", "XTIUSD": "Raw_Trading_Ltd", "XBRUSD": "Raw_Trading_Ltd"}
FOLDER = {"DXY": "DXY_Z6", "NZDUSD": "NZDUSD_r"}
ORDER = ["XAUUSD", "XAGUSD", "USDJPY", "EURJPY", "GBPJPY", "USDCHF", "NZDUSD", "AUDUSD", "DXY", "US30", "DE40", "USTEC", "US500", "XTIUSD", "XBRUSD"]
rows = []
for s in ORDER:
    live = f"{B}/{LIVE[s]}/{FOLDER.get(s, s)}/LIVE"
    spr = atr = np.nan
    if os.path.isdir(live):
        point = float(r.read_spec(live).get("point", 1e-5))
        m5 = r.load_candles(live, "M5")
        if len(m5):
            tk = m5[m5["tick_data_ok"].astype(str).str.upper() == "TRUE"]
            spr = float(tk["spread_avg_points"].median()) if len(tk) > 500 else float(m5["bar_spread_points"].median())
            atr = float(np.nanmedian(m5["atr"].to_numpy(float) / point))
    if not np.isfinite(spr):
        pp = f"docs/relatorios/mba/ativos/{s}/perfil_hora_utc.csv"
        if os.path.exists(pp):
            pr = pd.read_csv(pp)
            col = "spread_ticks_med" if "spread_ticks_med" in pr and pr["spread_ticks_med"].notna().any() else "spread_med"
            spr = float(np.average(pr[col].fillna(pr["spread_med"]), weights=pr["n"])); atr = float(np.average(pr["atr_med_pts"], weights=pr["n"]))
    md = open(f"{D}/{s}.md", encoding="utf-8").read()
    mm = re.search(r"Padrões que passaram: \*\*(\d+)\*\*; placebo: média ([\d.]+), máximo (\d+)", md)
    clock = f"{mm.group(1)} (placebo máx {mm.group(3)})" if mm else "?"
    clock_ok = bool(mm and int(mm.group(1)) > int(mm.group(3)))
    best_clock = "—"
    fh = f"{D}/{s}_horarios.csv"
    if os.path.exists(fh):
        h = pd.read_csv(fh)
        h = h.sort_values("ev_estresse_pts", ascending=False).iloc[0]
        best_clock = f"{h['lado']} {h['janela_entrada']} alvo {int(h['alvo_pts'])}: acerto {h['pct_alvo']:.0f}%, média {h['media_real_pts']:+.0f} pts, pior dia {h['pior_dia_pts']:,.0f}"
    cond = "—"
    fc = f"{D}/{s}_condicionais.csv"
    if os.path.exists(fc):
        c0 = pd.read_csv(fc)
        if "dias_com_sinal" in c0:
            c0 = c0[c0["cat"] == "demais"]
            ok = c0["anos_pos"].map(lambda v: v.split("/")[0] == v.split("/")[1])
            c = c0[~c0["condicao"].str.contains("month=|dom_w=") & (c0["n"] >= 250) & (c0["dias_com_sinal"] >= 60) & ((c0["pct_alvo_val"] - c0["pct_base_val"]) >= 8) & ok & (c0["media_real_pts"] > 0)]
            c = c.sort_values(["passou_BH", "ev_estresse_pts"], ascending=[False, False])
            if len(c):
                x = c.iloc[0]
                cond = f"{x['lado']} {x['condicao']} ({x['melhores_horas'] if isinstance(x['melhores_horas'], str) else '—'}), alvo {int(x['alvo_pts'])}: {x['pct_alvo']:.0f}% vs base {x['pct_base_val']:.0f}%, média {x['media_real_pts']:+.0f}, pior dia {x['pior_dia_pts']:,.0f}; {len(c)} famílias"
    rows.append(dict(ativo=s, spread_ticks_pts=spr, ATR_M5_pts=atr, custo_sobre_ATR=spr / atr if atr else np.nan, horarios_puros_vs_acaso=clock, passa_acaso="SIM" if clock_ok else "nao", melhor_horario=best_clock, melhor_condicao=cond))
T = pd.DataFrame(rows)
T.to_csv("docs/relatorios/mba/resumo_por_ativo.csv", index=False)
print(md_table(T, 2))
