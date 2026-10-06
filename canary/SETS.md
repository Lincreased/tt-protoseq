# Canary sets (canary branch only)

One commit per set. For each set, change two lists and push: `PROJECT_SOURCES` in
test/Makefile and `source_files` in info.yaml. Both lists hold the same files in the
same order (rule T8). When a set uses the package, canary_pkg.sv comes first.

src/project.v and test/test.py stay the same for all sets; the test reads the set id
from the harness (uio_in[4:0] = 31) and checks only the canaries of that set.

## Select codes (uio_in[4:0])

| sel | canary | construct | set |
|---|---|---|---|
| 0 | c00 canary_baseline | control, Verilog-2005 | all |
| 1 | c01 canary_ext_v | logic in a .v file | A |
| 2 | c02 canary_logic | logic | A |
| 3 | c03 canary_always_comb | always_comb | A |
| 4 | c04 canary_always_ff | always_ff | A |
| 5 | c05 canary_enum | typedef enum | A |
| 6 | c06 canary_struct | typedef struct packed | A |
| 7 | c07 canary_package | import inside the module body | removed from A |
| 8 | c08 canary_param | parameter override, localparam | A |
| 9 | c09 canary_clog2 | $clog2 | A |
| 10 | c10 canary_generate | generate for | A |
| 11 | c11 canary_rom_case | ROM on case | A |
| 12 | c12 canary_rom_packed | ROM on packed 2-D localparam | removed from A |
| 13 | c13 canary_unique_case | unique case | A |
| 14 | c14 canary_priority_case | priority case | A |
| 15 | c15 canary_rom_unpacked | ROM on unpacked localparam array | B |
| 16 | c16 canary_interface | interface | C |
| 17 | c17 canary_rom_flat | ROM on flat localparam vector, +: read | D |
| 18 | c18 canary_pkg_scope | package constant by scope reference | D |
| 19 | c19 canary_pkg_header | package import in the module header | D |
| 31 | set id | 0xA1 / 0xB2 / 0xC3 / 0xD4 | A / B / C / D |

## Set A (set id 0xA1), as it ran green: without c07 and c12

test/Makefile:

    PROJECT_SOURCES = canary_pkg.sv project.v canary_harness_a.v canary_baseline.v \
                      canary_ext_v.v canary_logic.sv canary_always_comb.sv canary_always_ff.sv \
                      canary_enum.sv canary_struct.sv canary_param.sv canary_clog2.sv \
                      canary_generate.sv canary_rom_case.sv canary_unique_case.sv \
                      canary_priority_case.sv

info.yaml:

    source_files:
      - "canary_pkg.sv"
      - "project.v"
      - "canary_harness_a.v"
      - "canary_baseline.v"
      - "canary_ext_v.v"
      - "canary_logic.sv"
      - "canary_always_comb.sv"
      - "canary_always_ff.sv"
      - "canary_enum.sv"
      - "canary_struct.sv"
      - "canary_param.sv"
      - "canary_clog2.sv"
      - "canary_generate.sv"
      - "canary_rom_case.sv"
      - "canary_unique_case.sv"
      - "canary_priority_case.sv"

## Set B (set id 0xB2)

    PROJECT_SOURCES = project.v canary_harness_b.v canary_baseline.v canary_rom_unpacked.sv

    source_files:
      - "project.v"
      - "canary_harness_b.v"
      - "canary_baseline.v"
      - "canary_rom_unpacked.sv"

## Set C (set id 0xC3)

    PROJECT_SOURCES = project.v canary_harness_c.v canary_baseline.v canary_interface.sv

    source_files:
      - "project.v"
      - "canary_harness_c.v"
      - "canary_baseline.v"
      - "canary_interface.sv"

## Set D (set id 0xD4)

The order matters: the port check stops at the first failing file, so the most important
candidate (c17) goes first.

    PROJECT_SOURCES = canary_pkg.sv project.v canary_harness_d.v canary_baseline.v \
                      canary_rom_flat.sv canary_pkg_scope.sv canary_pkg_header.sv

    source_files:
      - "canary_pkg.sv"
      - "project.v"
      - "canary_harness_d.v"
      - "canary_baseline.v"
      - "canary_rom_flat.sv"
      - "canary_pkg_scope.sv"
      - "canary_pkg_header.sv"

## If a tool fails in a set with several canaries (A or D)

The gds job runs the port check, then Verilator lint, then synthesis; the first error stops
the rest. Icarus in the test job stops at the first fatal error too. The error names a file,
and each file holds one construct. To remove canary cNN from set X:

1. both lists (PROJECT_SOURCES and source_files): remove its file;
2. src/canary_harness_<x>.v: remove yNN from the wire list, its instance line and its
   `5'dNN: y = yNN;` line;
3. test/test.py: remove NN from MEMBERS["X"].

Push and record the failure. Repeat until the set is green.
