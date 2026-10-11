# Metrics

One row per green CI run worth comparing. Numbers come from the gds run → Summary.

| Step | Commit | Cells | Area / utilization | Timing (frequency, slack) | Where in CI output | Note |
|---|---|---|---|---|---|---|
| 1 | 518f76b1c825c8f51e3bac889052f2839cc079da | 53 | 1.954 % | 50 MHz (CLOCK_PERIOD 20 ns); setup WS 9.905 ns, hold WS 7.852 ns | gds run → Summary (Routing stats, Cell usage by Category); timing: GDS_logs artifact → runs/wokwi/final/metrics.csv | template example (uo_out = ui_in + uio_in), tiles 1x1, reference only; no registers — slack is for input→output paths under LibreLane base.sdc I/O delays |
| 1 | ff31938495fecaa7d42a63ef55a6fb80c420aebb | 53 | 0.063 % | 50 MHz (CLOCK_PERIOD 20 ns); setup WS 9.908 ns, hold WS 7.866 ns | gds run → Summary (Routing stats, Cell usage by Category); timing: GDS_logs artifact → runs/wokwi/final/metrics.csv | baseline, tiles 6x4; template example (uo_out = ui_in + uio_in), no registers; gds run 35 min |
| 3 | 8ef9baeb563287fb4c9f47e09170642ab28a3f6f | 104 total (14 flip-flops, 30 dlygate4sd3) | utilisation 0.178 %, wire length 1985 um | 50 MHz (CLOCK_PERIOD 20 ns); setup ws +14.098 ns, hold ws +0.199 ns (min over corners) | gds run 37971484735, Summary (cells, routing); GDS_logs runs/wokwi/final/metrics.csv (timing) | hardcoded UART TX; test and gl_test red only on the old template assert; 30 dlygate4sd3 = 30 hold buffers inserted by step 37 (repair_timing -hold, 14 endpoints with hold violations before repair)