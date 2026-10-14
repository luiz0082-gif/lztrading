"""MarketBehaviorAnalyzer: de-duplicate v1.00 CSVs into a clean copy.

Originals are never modified. Output goes to <out>/<symbol>/<kind>_<tf>.csv (one logical file, all parts merged).

Why: EA v1.00 rewrote FORWARD every second (and M1 tick aggregates twice, and news on every restart),
so the same observation appears many times. N must count observations, not rows.

Keys (first occurrence kept unless noted):
  candles / events : event_id            (schema v1) or event_key (schema v2)
  forward          : (event_id, horizon_bars) or forward_key (v2)
  tick_aggregate   : (symbol, timeframe, start_time)  -> LAST row kept (the CopyTicks one, written after the live partial)
  news             : (calendar_value_id, revision, actual) -> first kept
Usage:
  python mba_dedupe.py --root "C:/.../Common/Files/MarketBehaviorAnalyzer" --symbol XAUUSD --out clean
"""
import argparse, glob, os
import pandas as pd


def read_parts(pattern):
    parts = sorted(glob.glob(pattern))
    dfs = []
    for f in parts:
        if os.path.getsize(f) == 0:
            continue
        dfs.append(pd.read_csv(f))
    return (pd.concat(dfs, ignore_index=True) if dfs else pd.DataFrame()), len(parts)


def dedupe(kind, df):
    n0 = len(df)
    if df.empty:
        return df, 0
    if kind == 'forward':
        key = ['forward_key'] if 'forward_key' in df.columns and df['forward_key'].notna().all() else ['event_id', 'horizon_bars']
        keep = 'first'
    elif kind in ('candles', 'events'):
        key = ['event_key'] if 'event_key' in df.columns and df['event_key'].notna().all() else ['event_id']
        keep = 'first'
    elif kind == 'tick_aggregate':
        key = ['symbol', 'timeframe', 'start_time']
        keep = 'last'
    elif kind == 'news':
        act = 'actual_value' if 'actual_value' in df.columns else 'actual_value_ppm'
        key = ['calendar_value_id', 'revision', act]
        keep = 'first'
    else:
        return df, 0
    out = df.drop_duplicates(key, keep=keep).reset_index(drop=True)
    return out, n0 - len(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', required=True)
    ap.add_argument('--symbol', required=True, help='folder name, e.g. XAUUSD or XAUUSD_r (include broker subfolder if used)')
    ap.add_argument('--mode', default='LIVE')
    ap.add_argument('--out', required=True)
    a = ap.parse_args()
    base = os.path.join(a.root, a.symbol, a.mode)
    layout = {'CANDLES': 'candles', 'EVENTS': 'events', 'FORWARD': 'forward', 'TICKS': 'tick_aggregate'}
    outdir = os.path.join(a.out, a.symbol, a.mode)
    os.makedirs(outdir, exist_ok=True)
    report = []
    for sub, kind in layout.items():
        for f in sorted(glob.glob(os.path.join(base, sub, f'{kind}_*_part001.csv'))):
            stem = os.path.basename(f).replace('_part001.csv', '')
            df, nparts = read_parts(os.path.join(base, sub, stem + '_part*.csv'))
            clean, removed = dedupe(kind, df)
            clean.to_csv(os.path.join(outdir, stem + '.csv'), index=False)
            report.append((stem, nparts, len(df), len(clean), removed))
    df, nparts = read_parts(os.path.join(base, 'NEWS', 'news_part*.csv'))
    clean, removed = dedupe('news', df)
    clean.to_csv(os.path.join(outdir, 'news.csv'), index=False)
    report.append(('news', nparts, len(df), len(clean), removed))
    rep = pd.DataFrame(report, columns=['file', 'parts', 'rows_in', 'rows_out', 'duplicates_removed'])
    rep['dup_pct'] = (100 * rep.duplicates_removed / rep.rows_in.where(rep.rows_in > 0)).round(1)
    rep.to_csv(os.path.join(outdir, '_dedupe_report.csv'), index=False)
    print(rep.to_string(index=False))


if __name__ == '__main__':
    main()
