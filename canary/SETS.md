# Canary sets (canary branch only)

One commit per set. For each set, change two lists and push: `PROJECT_SOURCES` in
test/Makefile and `source_files` in info.yaml. Both lists hold the same files in the
same order (rule T8). In set A, canary_pkg.sv comes first.

src/project.v and test/test.py stay the same for all three sets; the test reads the set
id from the harness (uio_in[4:0] = 31) and checks only the canaries of that set.

## Select codes (uio_in[4:0])

| sel | canary | construct | set |
|---|---|---|---|
| 0 | c00 canary_baseline | control, Verilog-2005 | A, B, C |
| 1 | c01 canary_ext_v | logic in a .v file | A |
| 2 | c02 canary_logic | logic | A |
| 3 | c03 canary_always_comb | always_comb | A |
| 4 | c04 canary_always_ff | always_ff | A |
| 5 | c05 canary_enum | typedef enum | A |
| 6 | c06 canary_struct | typedef struct packed | A |
| 7 | c07 canary_package | package + import | A |
| 8 | c08 canary_param | parameter override, localparam | A |
| 9 | c09 canary_clog2 | $clog2 | A |
| 10 | c10 canary_generate | generate for | A |
| 11 | c11 canary_rom_case | ROM on case | A |
| 12 | c12 canary_rom_packed | ROM on packed 2-D localparam | A |
| 13 | c13 canary_unique_case | unique case | A |
| 14 | c14 canary_priority_case | priority case | A |
| 15 | c15 canary_rom_unpacked | ROM on unpacked localparam array literal | B |
| 16 | c16 canary_interface | interface | C |
| 31 | set id | 0xA1 / 0xB2 / 0xC3 | A / B / C |

## Set A (set id 0xA1)

test/Makefile:

    PROJECT_SOURCES = canary_pkg.sv project.v canary_harness_a.v canary_baseline.v \
                      canary_ext_v.v canary_logic.sv canary_always_comb.sv canary_always_ff.sv \
                      canary_enum.sv canary_struct.sv canary_package.sv canary_param.sv \
                      canary_clog2.sv canary_generate.sv canary_rom_case.sv canary_rom_packed.sv \
                      canary_unique_case.sv canary_priority_case.sv

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
      - "canary_package.sv"
      - "canary_param.sv"
      - "canary_clog2.sv"
      - "canary_generate.sv"
      - "canary_rom_case.sv"
      - "canary_rom_packed.sv"
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

## If a tool fails in set A

The gds job runs the port check, then Verilator lint, then synthesis; the first error stops
the rest. The error names a file, and each file holds one construct. Remove that file from
both lists and from canary_harness_a.v (its instance and its select line), push, and record
the failure. Repeat until set A is green.
