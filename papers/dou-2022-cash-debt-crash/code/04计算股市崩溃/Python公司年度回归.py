"""Replace the Stata firm-year OLS loop; retain all source rows and columns."""
from pathlib import Path
import json
import time
import numpy as np
import pandas as pd

BASE = Path(__file__).resolve().parent
SOURCE = BASE / '周收益率_回归前.dta'
OUTPUT = BASE / '周收益率_回归完成.dta'
REPORT = BASE / 'Python回归核验.json'
start = time.perf_counter()
with pd.read_stata(SOURCE, iterator=True, convert_categoricals=False) as reader:
    labels = reader.variable_labels()
    data = reader.read()
features = ['rm_l2', 'rm_l1', 'rm', 'rm_f1', 'rm_f2']
required = ['stock', 'year', 'weekstr', 'type', 'tw', 'ri'] + features
assert all(c in data for c in required)
assert not data[['stock', 'year']].isna().any().any()
assert not data.duplicated(['stock', 'weekstr']).any()
# Reset any partial output from the interrupted Stata loop.
data['epsilon'] = np.nan
data['Nreg'] = np.nan
data['reg_ok'] = np.zeros(len(data), dtype=np.int8)
values = data[['ri'] + features].to_numpy(dtype=np.float64)
eps = np.full(len(data), np.nan)
nreg = np.full(len(data), np.nan)
ok = np.zeros(len(data), dtype=np.int8)
groups = data.groupby(['stock', 'year'], sort=False).indices
counts = {'total_groups': len(groups), 'successful_groups': 0,
          'under_30_groups': 0, 'rank_deficient_groups': 0}
max_orthogonality = 0.0
max_mean_error = 0.0
max_rss_gap = 0.0
for number, (key, indices) in enumerate(groups.items(), 1):
    block = values[indices]
    valid = np.isfinite(block).all(axis=1)
    selected = indices[valid]
    if len(selected) < 30:
        counts['under_30_groups'] += 1
        continue
    b = block[valid]
    y = b[:, 0]
    X = np.column_stack((np.ones(len(y)), b[:, 1:]))
    beta, _, rank, _ = np.linalg.lstsq(X, y, rcond=None)
    nreg[indices] = len(y)
    if rank != 6:
        counts['rank_deficient_groups'] += 1
        continue
    residual = y - X @ beta
    eps[selected] = residual
    ok[indices] = 1
    counts['successful_groups'] += 1
    max_orthogonality = max(max_orthogonality, float(np.max(np.abs(X.T @ residual))))
    max_mean_error = max(max_mean_error, float(abs(residual.mean())))
    # Independent QR solution for representative groups spread through the run.
    if number % 500 == 0 or counts['successful_groups'] == 1:
        Q, R = np.linalg.qr(X, mode='reduced')
        beta_qr = np.linalg.solve(R, Q.T @ y)
        residual_qr = y - X @ beta_qr
        assert np.allclose(residual, residual_qr, rtol=1e-9, atol=1e-10)
        max_rss_gap = max(max_rss_gap, abs(float(residual @ residual - residual_qr @ residual_qr)))
    if number % 5000 == 0:
        print(f'Processed {number}/{len(groups)} groups', flush=True)
assert max_orthogonality < 1e-7
assert max_mean_error < 1e-9
data['epsilon'] = eps
data['Nreg'] = nreg
data['reg_ok'] = ok
labels.update({'epsilon': '公司年度扩展市场模型回归残差',
               'Nreg': '公司年度回归有效周数', 'reg_ok': '至少30周且回归模型满秩'})
data.to_stata(OUTPUT, write_index=False, version=118, variable_labels=labels)
# Check the serialized results and key alignment.
check = pd.read_stata(OUTPUT, columns=['stock','weekstr','year','epsilon','Nreg','reg_ok'], convert_categoricals=False)
assert len(check) == len(data)
assert check[['stock','weekstr','year']].equals(data[['stock','weekstr','year']])
assert np.allclose(check['epsilon'], eps, equal_nan=True)
assert np.allclose(check['Nreg'], nreg, equal_nan=True)
assert np.array_equal(check['reg_ok'], ok)
consistency = {}
for col in features:
    consistency[col] = int((data.groupby(['type','tw'])[col].nunique() > 1).sum())
report = {**counts, 'rows': len(data), 'regression_rows': int(np.isfinite(eps).sum()),
          'log_invalid_residual_rows': int(np.sum(eps <= -1)),
          'max_abs_residual_mean': max_mean_error,
          'max_abs_X_transpose_residual': max_orthogonality,
          'max_qr_rss_difference': max_rss_gap,
          'inconsistent_market_week_groups': consistency,
          'elapsed_seconds_including_io_and_checks': round(time.perf_counter()-start, 2),
          'note': 'Uses supplied market lead/lag variables unchanged; no industry/ST filtering or winsorization. Numerical rank threshold can differ from Stata for nearly collinear data.'}
REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps(report, ensure_ascii=False, indent=2), flush=True)
print(f'Output: {OUTPUT}', flush=True)
