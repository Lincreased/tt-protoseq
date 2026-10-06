# SPDX-License-Identifier: Apache-2.0
# Canary test (canary branch only; do not merge into the main branch).
#
# Each canary drives uo_out while uio_in[4:0] selects it; uio_in[4:0] = 31 returns the set id.
# The test touches only the TT top ports (rule T1), so the same test runs on RTL (job test) and on
# the gate-level netlist (gl_test). On the netlist it checks how Yosys understood each construct.
#
# Timing: inputs change right after a falling edge and uo_out is read at the next falling edge,
# so a sequential canary sees exactly one rising edge per vector.

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge

SEL_SET_ID = 31
SET_IDS = {0xA1: "A", 0xB2: "B", 0xC3: "C", 0xD4: "D"}
MEMBERS = {
    "A": set(range(0, 15)) - {7, 12},  # c00..c14 without c07 and c12 (removed after CI runs)
    "B": {0, 15},                      # c00, c15 rom_unpacked
    "C": {0, 16},                      # c00, c16 interface
    "D": {0, 17, 18, 19},              # c00, c17 rom_flat, c18 pkg_scope, c19 pkg_header
}

ROM = [0x3A, 0xC5, 0x17, 0xE2, 0x90, 0x4B, 0xFF, 0x00,
       0x81, 0x7E, 0x2D, 0xD4, 0x66, 0x99, 0x5C, 0xA3]

VECTORS = [0x00, 0x01, 0x02, 0x0F, 0x10, 0x3C, 0x5A, 0x7F,
           0x80, 0xA5, 0xC3, 0xF0, 0xFE, 0xFF]
NIBBLE_VECTORS = [low | high for high in (0x00, 0xF0) for low in range(16)]


def bit_reverse(a):
    return int(f"{a:08b}"[::-1], 2)


def priority_value(a):
    if a & 0x08:
        return 0x08
    if a & 0x04:
        return 0x04
    if a & 0x02:
        return 0x02
    return 0x00


async def apply(dut, sel, a):
    """Drive sel and a now (right after a falling edge); return uo_out at the next falling edge."""
    dut.uio_in.value = sel
    dut.ui_in.value = a
    await FallingEdge(dut.clk)
    return dut.uo_out.value


async def start(dut, sel):
    """Start the clock and hold reset for 10 cycles with sel applied.
    Return uo_out right after reset and the name of the active set."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = sel
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await FallingEdge(dut.clk)
    after_reset = dut.uo_out.value
    set_id = await apply(dut, SEL_SET_ID, 0)
    for value, name in SET_IDS.items():
        if set_id == value:
            return after_reset, name
    assert False, f"unknown set id on uo_out: {set_id}"


async def check(dut, name, sel, expected, vectors=VECTORS, reset_value=None):
    after_reset, set_name = await start(dut, sel)
    if sel not in MEMBERS[set_name]:
        dut._log.info(f"{name}: not in set {set_name}, nothing checked")
        return
    if reset_value is not None:
        assert after_reset == reset_value, (
            f"{name}: after reset expected 0x{reset_value:02X}, got {after_reset}")
    for a in vectors:
        got = await apply(dut, sel, a)
        exp = expected(a) & 0xFF
        assert got == exp, f"{name}: a=0x{a:02X} expected 0x{exp:02X}, got {got}"
    dut._log.info(f"{name}: {len(vectors)} vectors checked in set {set_name}")


@cocotb.test()
async def test_set_id(dut):
    """The harness reports a known set id."""
    _, set_name = await start(dut, 0)
    dut._log.info(f"active canary set: {set_name}")


@cocotb.test()
async def test_c00_baseline(dut):
    """c00 control, Verilog-2005: y = a + 1, registered."""
    await check(dut, "c00 baseline", 0, lambda a: a + 1, reset_value=0x00)


@cocotb.test()
async def test_c01_ext_v(dut):
    """c01 logic in a .v file: y = a ^ 0x5A."""
    await check(dut, "c01 ext_v", 1, lambda a: a ^ 0x5A)


@cocotb.test()
async def test_c02_logic(dut):
    """c02 logic: y = a ^ 0xC3."""
    await check(dut, "c02 logic", 2, lambda a: a ^ 0xC3)


@cocotb.test()
async def test_c03_always_comb(dut):
    """c03 always_comb: y = a | 0xF0."""
    await check(dut, "c03 always_comb", 3, lambda a: a | 0xF0)


@cocotb.test()
async def test_c04_always_ff(dut):
    """c04 always_ff: y = a - 1, registered."""
    await check(dut, "c04 always_ff", 4, lambda a: a - 1, reset_value=0x00)


@cocotb.test()
async def test_c05_enum(dut):
    """c05 typedef enum: a 2-bit state advances on each clock while a[0] = 1."""
    name, sel = "c05 enum", 5
    after_reset, set_name = await start(dut, sel)
    if sel not in MEMBERS[set_name]:
        dut._log.info(f"{name}: not in set {set_name}, nothing checked")
        return
    assert after_reset == 0x00, f"{name}: after reset expected 0x00, got {after_reset}"
    # start() already applied one clock with a = 0, so the state is still S0.
    steps = [(1, 1), (1, 2), (0, 2), (1, 3), (1, 0), (1, 1), (0, 1)]
    for a, exp in steps:
        got = await apply(dut, sel, a)
        assert got == exp, f"{name}: a[0]={a} expected 0x{exp:02X}, got {got}"
    dut._log.info(f"{name}: {len(steps)} steps checked in set {set_name}")


@cocotb.test()
async def test_c06_struct(dut):
    """c06 typedef struct packed: nibbles swapped."""
    await check(dut, "c06 struct", 6, lambda a: ((a & 0x0F) << 4) | (a >> 4))


@cocotb.test()
async def test_c07_package(dut):
    """c07 package and import: y = a ^ 0x3C."""
    await check(dut, "c07 package", 7, lambda a: a ^ 0x3C)


@cocotb.test()
async def test_c08_param(dut):
    """c08 parameter override (ADD = 7) and localparam: y = (a + 7) & 0x7F."""
    await check(dut, "c08 param", 8, lambda a: (a + 7) & 0x7F)


@cocotb.test()
async def test_c09_clog2(dut):
    """c09 $clog2(12) = 4: y = a + 4."""
    await check(dut, "c09 clog2", 9, lambda a: a + 4)


@cocotb.test()
async def test_c10_generate(dut):
    """c10 generate loop: bit order reversed."""
    await check(dut, "c10 generate", 10, bit_reverse)


@cocotb.test()
async def test_c11_rom_case(dut):
    """c11 ROM on case."""
    await check(dut, "c11 rom_case", 11, lambda a: ROM[a & 0x0F], vectors=NIBBLE_VECTORS)


@cocotb.test()
async def test_c12_rom_packed(dut):
    """c12 ROM on a packed 2-D localparam."""
    await check(dut, "c12 rom_packed", 12, lambda a: ROM[a & 0x0F], vectors=NIBBLE_VECTORS)


@cocotb.test()
async def test_c13_unique_case(dut):
    """c13 unique case."""
    await check(dut, "c13 unique_case", 13, lambda a: [0x11, 0x22, 0x44, 0x88][a & 0x03],
                vectors=NIBBLE_VECTORS)


@cocotb.test()
async def test_c14_priority_case(dut):
    """c14 priority case."""
    await check(dut, "c14 priority_case", 14, priority_value, vectors=NIBBLE_VECTORS)


@cocotb.test()
async def test_c15_rom_unpacked(dut):
    """c15 ROM on an unpacked localparam array literal (set B)."""
    await check(dut, "c15 rom_unpacked", 15, lambda a: ROM[a & 0x0F], vectors=NIBBLE_VECTORS)


@cocotb.test()
async def test_c16_interface(dut):
    """c16 interface (set C): y = ~a."""
    await check(dut, "c16 interface", 16, lambda a: ~a)


@cocotb.test()
async def test_c17_rom_flat(dut):
    """c17 ROM on a flat localparam vector with an indexed part-select (set D)."""
    await check(dut, "c17 rom_flat", 17, lambda a: ROM[a & 0x0F], vectors=NIBBLE_VECTORS)


@cocotb.test()
async def test_c18_pkg_scope(dut):
    """c18 package constant by scope reference canary_pkg::K (set D): y = a ^ 0x3C."""
    await check(dut, "c18 pkg_scope", 18, lambda a: a ^ 0x3C)


@cocotb.test()
async def test_c19_pkg_header(dut):
    """c19 package import in the module header (set D): y = a ^ 0x3C."""
    await check(dut, "c19 pkg_header", 19, lambda a: a ^ 0x3C)
