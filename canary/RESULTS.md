# Step 2 canary: results

Canary branch `canary` (not merged). One construct per file; each canary computes a known
function, and the same cocotb test checks it on RTL (job test) and on the gate-level netlist
(gl_test). Vivado and xsim were run locally, one process per canary.

## Tools

| Column | Tool | Version | Source of the version |
|---|---|---|---|
| Y55 | Yosys port check (tt_tool.py --create-user-config, `read_verilog -lib -sv`) | 0.55 (YoWASP) | FACT-017 (by code; not printed in the logs) |
| VL | Verilator lint (LibreLane) | 5.046 2026-02-28 rev v5.046 | verilator-lint.log |
| Y66 | Yosys synthesis (LibreLane) | 0.66 (git sha1 86f2ddeb) | yosys-synthesis.log, yosys-jsonheader.log |
| IC | Icarus, job test, cocotb on RTL | 12.0-2build2 (apt) | FACT-119 |
| GL | gl_test, cocotb on the Yosys netlist | Icarus 13.0-1 | FACT-018 (not printed in the logs) |
| VD / VS | Vivado synthesis, xc7z020clg484-1, `read_verilog` / `read_verilog -sv` | v2025.2, SW Build 6299465 | summary.txt |
| XD / XS | xvlog + xelab / xvlog --sv + xelab | Vivado Simulator v2025.2 | summary.txt |

LibreLane image: ghcr.io/librelane/librelane:3.1.0.dev3,
digest sha256:d109140b8f17fc54f4fca998beb8124f4949404ec52e339eebd2250854a18b5a.

## Runs

| Set | Commit | test run | gds run | Note |
|---|---|---|---|---|
| A | 14fe1242997ae716346e54edaf8430fe608a0d36 | 37514212364 | 37514212312 | IC crash on c12; Y55 error on c07 |
| A without c07, c12 | 6121e0d6c61bf8427db875ea654cf5e26e199b9f | 37520166772 | 37520166736 | all green except gl_test (missing UDPs, see D-013); 6x4 |
| A without c07, c12; udp; 1x1 | 0456e35b6fc1a5fdd1eb266cdfb6c9ba83466391 | 37531242287 | 37531242422 | all green |
| B | f1cb65d93a09171933fe84f778b85a2f0494e267 | 37535796998 | 37535797036 | c15 |
| C | 9506e0fdaa3bce50137ce81f3ed9bb18082df1d9 | 37539549365 | 37539549394 | c16 |
| D | 652e16d0fd5569917ae8d13eaf6ff076ba430fe0 | 37543262171 | 37543258052 | Y55 error on c19 |
| D without c19 | 96e10dfd3faf309086e7f3c35a74f0f68f3473fe | 37546124560 | 37546124499 | all green |
| local | canary working copy (canary files as in 96e10df) | — | — | Vivado and xsim, 2026-10-07 |

Commits that only fixed my harness or file lists are not results and are left out.

## Matrix

`✓` passed; `⚠` passed with a warning; `✗` error (notes below); `—` not run (an earlier
step stopped). IC and GL are functional checks; VD/VS mean "synthesis finished", XD/XS mean
"compiled and elaborated" — no functional check in Vivado or xsim.

| # | Construct | Y55 | VL | Y66 | IC | GL | VD | VS | XD | XS |
|---|---|---|---|---|---|---|---|---|---|---|
| c00 | control, Verilog-2005 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| c01 | `logic` in a `.v` file | ✓ | ✓ | ✓ | ✓ | ✓ | ✗1 | ✓ | ✗2 | ✓ |
| c02 | `logic` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗2 | ✓ |
| c03 | `always_comb` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗3 | ✓ |
| c04 | `always_ff` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗3 | ✓ |
| c05 | `typedef enum` (logic base) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗3 | ✓ |
| c06 | `typedef struct packed` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗3 | ✓ |
| — | package declaration (canary_pkg.sv) | ✓ | ⚠4 | ✓ | ✓ | ✓ | ✓ | ✓ | ✗5 | ✓ |
| c07 | `import pkg::*;` in the module body | ✗6 | — | — | —7 | — | ✓ | ✓ | ✗5 | ✓ |
| c08 | parameter override, `localparam` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| c09 | `$clog2` in a localparam | ✓ | ⚠8 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| c10 | `generate for`, named block | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| c11 | ROM as `case` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| c12 | ROM as packed 2-D localparam, variable index | — | — | — | ✗9 | — | ✓ | ✓ | ✗2 | ✓ |
| c13 | `unique case` (full) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓10 | ✓10 | ✗3 | ✓ |
| c14 | `priority case` (with default) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓10 | ✓10 | ✗3 | ✓ |
| c15 | ROM as unpacked localparam array, `'{...}` | ✓11 | ✓ | ✗12 | ✗13 | — | ✓ | ✓ | ✗3 | ✓ |
| c16 | `interface` | ✓11 | ✓ | ✗14 | ✗15 | — | ⚠16 | ⚠16 | ✗5 | ✓ |
| c17 | ROM as flat localparam vector, `+:` read | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| c18 | package constant by `pkg::name` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗5 | ✓ |
| c19 | `import pkg::*;` in the module header | ✗17 | — | — | ✓ | — | ✓ | ✓ | ✗5 | ✓ |

Notes:

1. `[Synth 8-8896] 'logic' is an unknown type`: without `-sv`, Vivado reads a `.v` file as Verilog.
2. `[VRFC 10-2939] 'logic' is an unknown type`: without `--sv`, xvlog reads every file as Verilog, `.sv` included.
3. `[VRFC 10-4982] syntax error near ...` (same cause as 2).
4. `UNUSEDPARAM` on K, only in the set where its user c07 had been removed; no warning in set D.
5. `[VRFC 10-8386] root scope declaration is not allowed in Verilog 95/2K mode` (same cause as 2).
6. `canary_package.sv:8: ERROR: syntax error, unexpected TOK_PACKAGESEP, expecting '(' or '['`.
7. Parsed without an error in the first set A run (Icarus then aborted on c12); never tested.
8. `WIDTHTRUNC`: `$clog2` returns 32 bits, assigned to an 8-bit localparam.
9. Abort: `assert: netmisc.cc:1821: failed assertion packed_dims.size() == 1` on `assign y = ROM[a[3:0]];`.
10. INFO: unique → `implementing as parallel_case` (Synth 8-294); priority → `implementing as full_case` (Synth 8-293).
11. Inferred: the next step of the gds job started.
12. `canary_rom_unpacked.sv:9: ERROR: syntax error, unexpected '[', expecting ',' or ';' or '='` (at the unpacked dimension, before the literal).
13. `canary_rom_unpacked.sv:9: error: localparam must have a value`, `syntax error`; `:12: error: Invalid module item`.
14. Parse passed; elaboration: `canary_interface.sv:21: ERROR: Identifier '\bus_i.d' is implicitly declared and 'default_nettype is set to none` (`assign bus_i.d = a;`).
15. `canary_interface.sv:9: syntax error`, `Errors in port declarations` (the interface port).
16. `[Synth 8-330] inout connections inferred for interface port 'canary_bus' with no modport`.
17. `canary_pkg_header.sv:7: ERROR: syntax error, unexpected TOK_ID, expecting '(' or ';' or '#'`.

## Allowed SV subset (decision: D-014)

Allowed, because they passed every tool: `logic`, `always_comb`, `always_ff`, `typedef enum`
with a logic base type, `typedef struct packed`, parameter override and `localparam`,
`$clog2` in a localparam, `generate for` with a named block, `unique case` / `priority case`
only when the case is full and its items do not overlap, a package declaration used through
`pkg::name`, ROM as a `case` statement or as a flat localparam vector read with `+:`.

Not allowed: `import` in any form; unpacked localparam arrays and assignment patterns `'{...}`;
variable indexing of packed multidimensional arrays; `interface`. Anything not listed is not
allowed until a canary passes it.

## Proposed DECISIONS entries

### D-013. How do we make gl_test work for designs with flip-flops?
Decision: add the PDK's sg13cmos5l_udp.v to the gate-level sources in test/Makefile, one line before sg13cmos5l_stdcell.v.
Why: the stdcell models instantiate UDPs (ihp_dff_r, ihp_mux2 and others) defined only in sg13cmos5l_udp.v; without it gl_test fails on any design with flip-flops (canary: gds run 37520166736 red, 37531242422 green after the change).
Revisit if: the template's cmos5l branch changes test/Makefile upstream (take its version, D-007), or the PDK moves the UDPs.
Step / date: 2 / 2026-10-07

### D-014. Which SystemVerilog may the RTL use?
Decision: Verilog-2005 plus the constructs listed in "Allowed SV subset" above, with the conditions given there; everything else stays out until a canary passes it in every tool. Files with SystemVerilog syntax use the .sv extension and start with `default_nettype none`; package files come first in source_files and PROJECT_SOURCES; local Vivado and xsim always read sources with -sv / --sv.
Why: measured in the canary branch (runs listed above): the CI tools (Yosys 0.55 port check, Verilator 5.046, Yosys 0.66, Icarus 12.0-2build2, gl_test) set the limits; Vivado and xsim accept everything once told to read SystemVerilog.
Revisit if: a tool version changes (LibreLane image, Icarus from apt, the YoWASP pin in tt-support-tools, Vivado), or a step needs a construct outside the list — then a new canary first.
Step / date: 2 / 2026-10-07

### D-015. Which Yosys frontend do we use?
Decision: keep the built-in Yosys Verilog frontend (LibreLane default, FACT-015).
Why: no construct failed only in it: c15 and c16 also fail in Icarus 12, which runs the RTL in CI; import fails in the port check, which uses the built-in parser of Yosys 0.55 whatever the synthesis frontend (FACT-017).
Revisit if: a construct needed for a step passes every other tool and fails only in Yosys synthesis.
Step / date: 2 / 2026-10-07

## Local run recipe

Commands and flags: verify in your version.

Environment (cmd):

    call "<Vivado install>\settings64.bat"
    cd /d <repository root>

xsim, compile and elaborate RTL (package files first):

    xvlog --sv <pkg>.sv <file>.sv ...
    xelab <top> -s <top>_snap

With the SV testbench for the core (D-012), add the testbench to xvlog, elaborate its top and run:

    xsim <tb_top>_snap -R

Vivado synthesis in non-project mode, synth.tcl:

    read_verilog -sv [list src/<pkg>.sv src/<file>.sv ...]
    synth_design -top <top> -part xc7z020clg484-1

    vivado -mode batch -nojournal -log synth.log -source synth.tcl

CI results for the current commit (GitHub CLI, after `gh auth login`):

    git rev-parse HEAD
    gh run list --branch <branch> --limit 6 --json databaseId,workflowName,headSha,conclusion
    gh run view <run-id> --log-failed > failed_<run-id>.txt
    gh run download <run-id> -D ci\<run-id>

cocotb with Icarus locally: deferred (D-012); the recipe is written at install time.

The canary itself stays re-runnable in the canary branch: canary/run_vivado_synth.ps1,
canary/run_xsim.ps1 and the CI sets in canary/SETS.md.

## Proposed verified_facts.md entries (measured)

IDs are assigned by №0.

| ID | Statement | Source | Date | Status | Step |
|---|---|---|---|---|---|
| FACT-NNN | LibreLane runs as ghcr.io/librelane/librelane:3.1.0.dev3, digest sha256:d109140b8f17fc54f4fca998beb8124f4949404ec52e339eebd2250854a18b5a. | RUN 37535797036 @ f1cb65d93a09171933fe84f778b85a2f0494e267, step "Make GDS with LibreLane" | 2026-10-06 | measured | 2 |
| FACT-NNN | The Yosys 0.55 port check rejects `import pkg::*;` in a module body ("unexpected TOK_PACKAGESEP, expecting '(' or '['") and in a module header ("unexpected TOK_ID, expecting '(' or ';' or '#'"); a package declaration and `pkg::name` pass. | RUN 37514212312 @ 14fe1242997ae716346e54edaf8430fe608a0d36; RUN 37543258052 @ 652e16d0fd5569917ae8d13eaf6ff076ba430fe0; RUN 37546124499 @ 96e10dfd3faf309086e7f3c35a74f0f68f3473fe | 2026-10-06 | measured | 2 |
| FACT-NNN | Icarus 12.0-2build2 aborts (assert netmisc.cc:1821 packed_dims.size() == 1) on a variable index into a packed two-dimensional localparam. | RUN 37514212364 @ 14fe1242997ae716346e54edaf8430fe608a0d36, job test | 2026-10-06 | measured | 2 |
| FACT-NNN | An unpacked localparam array with an assignment pattern fails in Icarus 12.0-2build2 ("localparam must have a value") and in Yosys 0.66 ("syntax error, unexpected '['"); Verilator 5.046 lint passes it without warnings. | RUN 37535796998 (test), 37535797036 (gds) @ f1cb65d93a09171933fe84f778b85a2f0494e267 | 2026-10-06 | measured | 2 |
| FACT-NNN | interface: Icarus 12.0-2build2 rejects an interface port; Yosys 0.66 parses the file but fails on an assignment to an interface instance member from the parent ("Identifier '\bus_i.d' is implicitly declared and `default_nettype is set to none"); Verilator 5.046 lint passes. | RUN 37539549365 (test), 37539549394 (gds) @ 9506e0fdaa3bce50137ce81f3ed9bb18082df1d9 | 2026-10-06 | measured | 2 |
| FACT-NNN | These constructs pass the port check, Verilator 5.046 lint, Yosys 0.66 synthesis and the cocotb test on RTL (Icarus 12.0-2build2) and on the netlist (gl_test): logic (also in a .v file), always_comb, always_ff, typedef enum, typedef struct packed, parameter override and localparam, $clog2, generate for, ROM as case, ROM as a flat localparam vector read with +:, unique case and priority case (full cases), package declaration with pkg::name. | RUN 37531242287 (test), 37531242422 (gds) @ 0456e35b6fc1a5fdd1eb266cdfb6c9ba83466391; RUN 37546124560 (test), 37546124499 (gds) @ 96e10dfd3faf309086e7f3c35a74f0f68f3473fe | 2026-10-06 | measured | 2 |
| FACT-NNN | gl_test fails on any design with flip-flops unless the PDK's sg13cmos5l_udp.v is compiled: sg13cmos5l_stdcell.v instantiates UDPs (ihp_dff_r, ihp_dff_sr_1, ihp_latch, ihp_latch_r, ihp_mux2, ihp_mux4) that it does not define, and it has no `include or `ifdef (so -DFUNCTIONAL does not change it). | RUN 37520166736 @ 6121e0d6c61bf8427db875ea654cf5e26e199b9f (red: Unknown module type ihp_dff_r); RUN 37531242422 @ 0456e35b6fc1a5fdd1eb266cdfb6c9ba83466391 (green with the file) | 2026-10-06 | measured | 2 |
| FACT-NNN | With sg13cmos5l_udp.v added, gl_test simulates the flip-flop models correctly: sequential canaries pass on the netlist, although the models drive delayed_* nets only through $setuphold/$recrem. | RUN 37531242422 @ 0456e35b6fc1a5fdd1eb266cdfb6c9ba83466391, artifact gatelevel_test_results | 2026-10-06 | measured | 2 |
| FACT-NNN | A compile error in job test fails the "Run tests" step (make exits 2) before the grep, and no results.xml is written (Test Summary: ENOENT). | RUN 37535796998 @ f1cb65d93a09171933fe84f778b85a2f0494e267 | 2026-10-06 | measured | 2 |
| FACT-NNN | results.xml lists every cocotb test as a testcase with its name and sim_time_ns; a name containing "failure" would therefore trip the CI grep (rule T12). | RUN 37520166772 @ 6121e0d6c61bf8427db875ea654cf5e26e199b9f, artifact test-results | 2026-10-06 | measured | 2 |
| FACT-NNN | Vivado 2025.2 (SW Build 6299465): read_verilog without -sv picks the language by extension (a .v file with logic: "[Synth 8-8896] 'logic' is an unknown type"); with -sv all 20 canaries synthesize for xc7z020clg484-1, including those the CI tools reject. unique case is implemented as parallel_case (Synth 8-294), priority case as full_case (Synth 8-293). | local run, canary working copy (canary files as in 96e10dfd3faf309086e7f3c35a74f0f68f3473fe), logs of 2026-10-07 | 2026-10-07 | measured | 2 |
| FACT-NNN | Vivado Simulator 2025.2: xvlog without --sv reads every file as Verilog 95/2K whatever the extension ("[VRFC 10-2939] 'logic' is an unknown type" for a .sv file); with --sv all 20 canaries compile and elaborate without warnings. | local run, same working copy and logs | 2026-10-07 | measured | 2 |

Proposed earlier in this chat (unchanged): FACT-118 (Yosys 0.66, Verilator 5.046) to measured;
Verilator lint flags `--Wall --Wno-fatal --Werror-LATCH --Werror-MULTIDRIVEN`; FACT-119 (Icarus
12.0-2build2) to measured; job test duration on the template example.
