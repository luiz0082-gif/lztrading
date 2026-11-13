import sys; sys.path.insert(0,'.')
from vp_run import *
for a,b,l in (('2026.10.13','2026.11.01','OUT 13/10-31/10'),('2026.11.03','2026.11.12','NOV 03-11/11')):
    show(l, run('VantagePulse_B3_v1.02',{},a,b))
