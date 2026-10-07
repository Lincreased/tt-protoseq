

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