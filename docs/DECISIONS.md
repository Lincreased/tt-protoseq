

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
