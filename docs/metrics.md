# Metrics

One row per green CI run worth comparing. Numbers come from the gds run → Summary.

| Step | Commit | Cells | Area / utilization | Timing (frequency, slack) | Where in CI output | Note |
|---|---|---|---|---|---|---|
| 1 | 518f76b1c825c8f51e3bac889052f2839cc079da | 53 | 1.954 % | 50 MHz (CLOCK_PERIOD 20 ns); setup WS 9.905 ns, hold WS 7.852 ns | gds run → Summary (Routing stats, Cell usage by Category); timing: GDS_logs artifact → runs/wokwi/final/metrics.csv | template example (uo_out = ui_in + uio_in), tiles 1x1, reference only; no registers — slack is for input→output paths under LibreLane base.sdc I/O delays |
