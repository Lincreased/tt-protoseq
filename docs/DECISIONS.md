

# Decisions

Format: question → decision → why → revisit if. New entries go at the bottom.

### D-001. Which plan do we follow?
Decision: pio_steps.md — steps 0–4 plus the queue. The brief (2026-09-23), the checkpoint roadmap and the "5 steps" plan are frozen as v0.
Why: a short plan where every step ends with a green CI; the worst-case rework is one step.
Revisit if: step 4 is closed (then order the queue), or steps 1–2 take longer than 2026-10-25.
Step / date: 0 / 2026-10-02

### D-002. Agent flow or regular chats?
Decision: regular claude.ai chats driven by docs/pipeline.md; artifacts and logs are carried over by hand. The agent flow is parked; where it stopped: local note, not in the repo.
Why: get a working part of the project without the overhead of the agent flow.
Revisit if: carrying CI logs by hand becomes the bottleneck.
Step / date: 0 / 2026-10-02

### D-003. Where does the ASIC flow run?
Decision: the template's CI in GitHub Actions.
Why: step 1 of pio_steps; installing the flow locally is a common place to get stuck (brief §10).
Revisit if: CI becomes unavailable, or run time slows down iterations.
Step / date: 0 / 2026-10-02

### D-004. Which targets are in part 1?
Decision: two targets — the TT tile (ASIC) and ZedBoard (FPGA prototype). Zynq mini stays out of part 1. From step 3 on, a step closes only when the design also works on a real ZedBoard pin. Why: passing simulation and CI does not prove the design works on a real pin; the organizers also advise running the RTL on an FPGA before the ASIC flow (FACT-002). Revisit if: the board check stops catching anything that simulation and CI miss. 
Step / date: 1 / 2026-10-02

### D-005. What do we isolate first?
Decision: the flow and the SV frontend — steps 1–2, before any own RTL.
Why: silent failures are more likely in the flow and at the FPGA→ASIC gap than in the architecture (brief §12).
Revisit if: steps 1–2 close without surprises.
Step / date: 0 / 2026-10-02

### D-006. Which documents do we keep in part 1?
Decision: docs/DECISIONS.md, docs/verified_facts.md, docs/metrics.md, docs/pipeline.md. docs-structure-C and the architecture sketch are frozen as v0.
Why: pio_steps step 0 — do not polish the drafts.
Revisit if: submission prep starts (README, docs/info.md, verification report).
Step / date: 0 / 2026-10-02

### D-007. From which template branch and commit was the repository created?
Solution: ttihp-verilog-template, branch cmos5l, commit b86a2a781484bcab7ba522dc5de540086695a430 (24.06.2026). The default branch in the repository is cmos5l. The project's first commit is e808068c245b0cbb54e271c275c655d2926aa66d.
Reason: template branches change (FACT-014); the template's `main` branch builds for ihp-sg13g2, not CMOS5L.
Review if: new commits appear in the template's cmos5l branch — compare the workflow using a diff.
Step / date: 1 / 2026-10-03

### D-009. How do we observe signals on ZedBoard?
Decision: a logic analyzer as the main instrument (it decodes UART, SPI and I2C), a USB-UART adapter for terminal checks and, later, for sending data into the design, and the Vivado ILA for signals inside the FPGA. Devices: [❏ fill in: before step 3]; both external instruments must match the I/O voltage of the chosen ZedBoard connector. Why: the project is about multi-wire protocols, so the analyzer serves all of them; the ILA costs nothing and shows signals before the pin. Revisit if: the instruments cannot resolve the timing the frame definition requires. Step / date: 1 / 2026-10-03

### D-010. Does the ZedBoard design use the Zynq PS?
Decision: no — PL only, programmed over JTAG; the PS is not configured. Why: keeps the board side to one RTL wrapper and one XDC; configuring the PS (DDR, MIO, clocks) is a separate project. Revisit if: we need the board's own USB-UART (if it is wired to the PS) or a CPU-side test harness. Step / date: 1 / 2026-10-03

### D-011. Which tile size do we use?
Decision: tiles "6x4" — the contest maximum; defined in tt-support-tools (tech/ihp-sg13cmos5l/tile_sizes.yaml).
Why: the contest rules ask for 6x4; the template's info.yaml comment lists only older sizes (FACT-013).
Revisit if: Jane Street opens 8x4 (they announced they are working on it).
Step / date: 1 / 2026-10-04

### D-012. Where do we run the tests locally?
Decision: the proof is the cocotb test in CI (job test on RTL, gl_test on the netlist). Locally: (1) a SystemVerilog testbench for the core in Vivado Simulator (xsim), for functional coverage, assertions and, later, agent-flow runs; it is optional — it does not gate a step, and its checks may be trimmed; (2) the same cocotb test with Icarus, installed when local debugging is needed (Linux or WSL, chosen at install time). No local gate-level runs in part 1. Vivado also builds the ZedBoard wrapper, constraints and bitstream (D-004).
Why: one open CI test stays the proof (FACT-018, FACT-059); xsim adds coverage (FACT-020) and a second simulator on the same RTL, at the cost of a second testbench maintained by hand (FACT-062).
Revisit if: the xsim testbench catches nothing beyond cocotb by the end of step 4, or keeping it in sync slows steps 3–4; debugging through pushes becomes routine (install cocotb locally); a gl_test failure cannot be understood from CI artifacts; the competition states a rule on verification tools.
Step / date: 2 / 2026-10-05

### D-013. How do we make gl_test work for designs with flip-flops?
Decision: add the PDK's sg13cmos5l_udp.v to the gate-level sources in test/Makefile, one line before sg13cmos5l_stdcell.v.
Why: the stdcell models instantiate UDPs (ihp_dff_r, ihp_mux2 and others) defined only in sg13cmos5l_udp.v; without it gl_test fails on any design with flip-flops (canary: gds run 37520166736 red, 37531242422 green after the change).
Revisit if: the template's cmos5l branch changes test/Makefile upstream (take its version, D-007), or the PDK moves the UDPs.
Step / date: 2 / 2026-10-07

### D-014. Which SystemVerilog may the RTL use?
Decision: Verilog-2005 plus logic, always_comb, always_ff, typedef enum (logic base type), typedef struct packed, parameter override and localparam, $clog2 in a localparam, generate for with a named block, unique case / priority case only when the case is full and its items do not overlap, a package used through pkg::name, ROM as a case statement or as a flat localparam vector read with +:. Not allowed: import in any form, unpacked localparam arrays and '{...} patterns, variable indexing of packed multidimensional arrays, interface; anything not listed stays out until a canary passes it in every tool. Files with SystemVerilog syntax use .sv and start with `default_nettype none; package files come first in source_files and PROJECT_SOURCES; local Vivado and xsim always read sources with -sv / --sv.
Why: measured in the canary branch (canary/RESULTS.md): the CI tools (Yosys 0.55 port check, Verilator 5.046, Yosys 0.66, Icarus 12.0-2build2, gl_test) set the limits; Vivado and xsim accept everything once told to read SystemVerilog.
Revisit if: a tool version changes (LibreLane image, Icarus from apt, the YoWASP pin, Vivado), or a step needs a construct outside the list — then a new canary first.
Step / date: 2 / 2026-10-07

### D-015. Which Yosys frontend do we use?
Decision: keep the built-in Yosys Verilog frontend (LibreLane default, FACT-015).
Why: no construct failed only in it: c15 and c16 also fail in Icarus 12, which runs the RTL in CI; import fails in the port check, which uses the built-in parser of Yosys 0.55 whatever the synthesis frontend (FACT-017).
Revisit if: a construct needed for a step passes every other tool and fails only in Yosys synthesis.
Step / date: 2 / 2026-10-07

### D-016. UART TX frame definition
Decision: All counts are clk cycles. k = 0 is the first rising edge of clk at which rst_n = 1;
Out(k) is the TX pin value just after rising edge k. TX changes only just after a rising clk edge.
- Clock: 50 MHz (CLOCK_PERIOD stays 20 ns, the template default).
- Baud: nominal 115200; bit time D = 434 clk (8.680 us); actual 50 000 000 / 434 = 115 207.37 Bd,
  error +0.0064 % vs 115200.
- Frame (8N1): idle level 1; start bit 0 (D clk); 8 data bits, LSB first (D clk each);
  no parity; 1 stop bit = 1 (D clk). Frame length 10*D = 4340 clk.
- Symbol: 'A' = 0x41; line sequence (start, d0..d7, stop) = 0,1,0,0,0,0,0,1,0,1. Sent forever.
- Pause: P = 434 clk of level 1 after the stop bit, before the next start bit;
  frame period 10*D + P = 4774 clk.
- Timing: TX = 1 while rst_n = 0 (after >= 1 rising edge with rst_n = 0) and for k = 0 .. P-1.
  Frame n starts (first cycle of the start bit) at k_n = P + n*(10*D + P): 434, 5208, 9982, ...
  Bit j of frame n (j = 0 start, 1..8 d0..d7, 9 stop) occupies k_n + j*D .. k_n + (j+1)*D - 1.
  Reset during a frame: TX = 1 after >= 1 rising edge with rst_n = 0; on release the sequence
  restarts at k = 0.
- Tolerance in simulation: 0 clk; every bit lasts exactly D cycles.
- Sampling (rule K1): the test reads TX at the falling edge of clk inside cycle k, which gives Out(k).
- Pin: uo_out[4] = TX. All other outputs 0: uo_out[7:5], uo_out[3:0], uio_out = 0, uio_oe = 0.
Why: fixed numbers give the test (#3T) an exact contract with no tolerance; 8N1 at 115200
  matches the project example, and D is a core parameter, so a clock change touches one number.
Revisit if: a CMOS5L clock recommendation appears (FACT-121); the demo board does not match the
  TT UART pinout (FACT-122); the analyzer or USB-UART adapter (D-009) cannot handle 115200;
  timing__setup__ws or timing__hold__ws < 0 at 20 ns.
Step / date: 3 / 2026-10-08

### D-017. UART core naming and structure
Decision: the core is module uart_tx_hardcoded in src/uart_tx_hardcoded.sv; parameters BIT_CLKS and
PAUSE_CLKS (defaults 434 and 434); the symbol 'A' is a localparam; reset is synchronous (rst_n active
low, tx = 1 after at least one rising edge with rst_n = 0); tx comes straight from a flop. The top
module passes both parameters explicitly and contains no logic. info.yaml source_files and
test/Makefile PROJECT_SOURCES list the core first, with the .sv extension.
Why: the name states what the module is; D and P as parameters keep a clock or baud change to one
number (D-016). Synchronous reset kept over asynchronous: the gds run at 8ef9baeb is green with
measured numbers and there is no recovery/removal risk on rst_n.
Revisit if: the programmable machine (step 4) replaces the core; the symbol or frame must change;
the synchronous reset costs noticeable area once the flip-flop count grows (the only mapped
flip-flop, sg13cmos5l_dfrbpq_1, has an asynchronous reset input).
Step / date: 3 / 2026-10-11

### D-018. When do cocotb tests change inputs and read outputs? (candidate K1)
Decision: K1 becomes rule T14 for every cocotb test from step 3 on: inputs (rst_n, ena, ui_in, uio_in) are written only right after a falling clk edge; outputs (uo_out, uio_out, uio_oe) are read only at a falling clk edge. The only exception is the initial values set before the clock starts (T4). For the UART frame test, k = 0 (D-016) is the rising edge that follows the falling edge at which rst_n is written to 1; Out(k) is read at the falling edge inside cycle k, as D-016 states.
Why: no write or read lands on a rising edge, so results do not depend on event order at that edge in Icarus 12/13 or in the cell models; the step-2 canary test used this scheme and passed on RTL and netlist (gds 37531242422, 37546124499).
Revisit if: a test needs an input that changes on a rising edge or asynchronously to clk; gate-level simulation with timing annotation is introduced (a half-period read becomes a timing assumption).
Step / date: 3 / 2026-10-12

### D-019. May tests check outputs while rst_n = 0?
Decision: yes, where the design definition states reset behaviour (D-016): from the falling edge after the first rising edge with rst_n = 0 that the test itself awaited, at every falling edge while rst_n = 0 — in the initial reset and in a reset during a frame. T5 is narrowed to: nothing is checked before that first rising edge. "All other outputs 0" (D-016) is read with the same timing.
Why: D-016 defines outputs during reset; T5 only has to keep checks away from values before reset takes effect, and the first-edge condition does that.
Revisit if: a definition stops specifying outputs during reset; gl_test shows X on an output after the first reset edge.
Step / date: 3 / 2026-10-12