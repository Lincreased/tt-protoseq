# SPDX-FileCopyrightText: © 2026 Lincreased
# SPDX-License-Identifier: Apache-2.0
"""UART TX frame test (frame definition D-016).

The test sees the design only through the tb.v signals (T1) and runs unchanged
on RTL (job test) and on the gate-level netlist (gl_test), T2.
Timing (T14, D-018): inputs are written right after a falling clk edge; outputs
are read at a falling clk edge, so the read in cycle k gives Out(k) of D-016.
Outputs are also checked while rst_n = 0, from the falling edge after the first
rising edge with rst_n = 0 (D-019). All counts are clk cycles.

Tests:
  test_uart_frame            initial reset, idle, N_FRAMES frames with pauses
  test_uart_reset_mid_frame  reset in the start bit of frame 0, restart from k = 0
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge

# ===========================================================================
# Expected values. This block is the only place to change them: step 4
# substitutes its own values here to check programmability.
# ===========================================================================
TX_PORT = "uo_out"   # D-016 Pin: TX = uo_out[4]
TX_BIT = 4
BIT_CLKS = 435       # D-016 Baud: D, clk cycles per bit
PAUSE_CLKS = 434     # D-016 Pause: P, clk cycles of level 1 after the stop bit
SYMBOL = 0x41        # D-016 Symbol: 'A'
TOL_CLK = 0          # D-016 Tolerance: 0 clk (only 0 is defined, see check_config)

# Test setup, not part of the frame definition.
N_FRAMES = 3         # frames checked in a row (at least 3)
RESET_CYCLES = 10    # rising edges with rst_n = 0 per reset (T5; D-016 needs >= 1)
CLK_PERIOD_NS = 20   # test clock (T3); every check counts cycles, not ns
# ===========================================================================

# Derived from D-016. Not edited separately.
FIRST_START = PAUSE_CLKS                    # k_0 = P (D-016 Timing)
FRAME_BITS = 10                             # 8N1: start, d0..d7, stop
FRAME_PERIOD = FRAME_BITS * BIT_CLKS + PAUSE_CLKS
WINDOW_LAST = FIRST_START + N_FRAMES * FRAME_PERIOD  # k_N: first cycle of frame N
MID_RESET_AT = FIRST_START + BIT_CLKS // 2  # middle of the start bit of frame 0

LINE_IDLE, LINE_START, LINE_STOP = 1, 0, 1  # 8N1 line levels (D-016 Frame)
PORTS = ("uo_out", "uio_out", "uio_oe")     # outputs of tb.v (T1)
PORT_WIDTH = 8                              # tb.v ports are [7:0]: bit 7 is char 0
MAX_LISTED = 10                             # mismatches listed in the report


def check_config():
    """Reject constants the definition does not cover (no silent reinterpretation)."""
    problems = []
    if TOL_CLK != 0:
        problems.append("TOL_CLK must be 0: D-016 defines no nonzero tolerance")
    if TX_PORT not in ("uo_out", "uio_out"):
        problems.append(f"TX_PORT {TX_PORT!r} is not an output port")
    if not 0 <= TX_BIT < PORT_WIDTH:
        problems.append(f"TX_BIT {TX_BIT} out of range")
    if BIT_CLKS < 1 or PAUSE_CLKS < 0:
        problems.append("BIT_CLKS must be >= 1 and PAUSE_CLKS >= 0")
    if not 0 <= SYMBOL <= 0xFF:
        problems.append(f"SYMBOL {SYMBOL:#x} is not 8 bits")
    if N_FRAMES < 3 or RESET_CYCLES < 1:
        problems.append("N_FRAMES must be >= 3 and RESET_CYCLES >= 1")
    if not problems and expected_tx(MID_RESET_AT)[0] != LINE_START:
        problems.append("MID_RESET_AT is not inside the start bit of frame 0")
    if problems:
        raise AssertionError("config: " + "; ".join(problems))


def expected_tx(k):
    """D-016 Timing: (TX level, frame index or None, field) for sample k >= 0."""
    if k < FIRST_START:
        return LINE_IDLE, None, "idle after reset"
    n, r = divmod(k - FIRST_START, FRAME_PERIOD)
    if r >= FRAME_BITS * BIT_CLKS:
        return LINE_IDLE, n, "pause"
    j = r // BIT_CLKS
    if j == 0:
        return LINE_START, n, "start bit"
    if j == FRAME_BITS - 1:
        return LINE_STOP, n, "stop bit"
    return (SYMBOL >> (j - 1)) & 1, n, f"data bit d{j - 1}"  # LSB first


def expected_ports(tx):
    """D-016 Pin: TX on its bit, every other output bit 0 (uio_oe = 1 on a uio TX pin, T6)."""
    exp = dict.fromkeys(PORTS, 0)
    exp[TX_PORT] |= tx << TX_BIT
    if TX_PORT == "uio_out":
        exp["uio_oe"] |= 1 << TX_BIT
    return {port: format(value, f"0{PORT_WIDTH}b") for port, value in exp.items()}


def read_ports(dut):
    """Read the tb.v outputs as bit strings, bit 7 first; X and Z stay visible."""
    return {port: str(getattr(dut, port).value) for port in PORTS}


def tx_char(sample):
    return sample[TX_PORT][PORT_WIDTH - 1 - TX_BIT]


def edges(levels):
    """Sample indices where the level changes (the index of the new level)."""
    return [k for k in range(1, len(levels)) if levels[k] != levels[k - 1]]


class Report:
    """Collects every mismatch of a test, then raises one AssertionError at the end.

    Consecutive samples with the same phase, field, expected and received value are
    merged into one range, so the report reads field by field.
    """

    def __init__(self, dut):
        self.log = dut._log
        self.ranges = []  # [phase, pos_name, first, last, frame, field, what, expected, got]
        self.tx_count = 0
        self.other_count = 0
        self.edge_notes = []

    def _add(self, phase, pos_name, pos, frame, field, what, expected, got):
        key = [phase, pos_name, frame, field, what, expected, got]
        last = self.ranges[-1] if self.ranges else None
        if last and last[3] == pos - 1 and [last[0], last[1]] + last[4:] == key:
            last[3] = pos
        else:
            self.ranges.append([phase, pos_name, pos, pos, frame, field, what, expected, got])

    def _compare(self, phase, pos_name, pos, frame, field, sample, tx_level):
        exp = expected_ports(tx_level)
        if tx_char(sample) != str(tx_level):
            self.tx_count += 1
            self._add(phase, pos_name, pos, frame, field, "TX", str(tx_level), tx_char(sample))
        mask = [i != PORT_WIDTH - 1 - TX_BIT for i in range(PORT_WIDTH)]
        for port in PORTS:
            want, got = exp[port], sample[port]
            if port == TX_PORT:
                differs = any(m and w != g for m, w, g in zip(mask, want, got))
            else:
                differs = want != got
            if differs:
                self.other_count += 1
                self._add(phase, pos_name, pos, frame, "other outputs 0 (Pin)", port, want, got)

    def reset(self, samples, phase):
        """C1, C2, C13 (D-019): while rst_n = 0, TX = 1 and every other output 0."""
        for i, sample in enumerate(samples):
            self._compare(phase, "reset edge", i + 1, None, "TX = 1 while rst_n = 0",
                          sample, LINE_IDLE)
        self.log.info("%s: %d samples while rst_n = 0 checked", phase, len(samples))

    def window(self, samples, phase):
        """C3-C12, C14: every sample k against D-016, plus measured TX edges for the log."""
        for k, sample in enumerate(samples):
            level, frame, field = expected_tx(k)
            self._compare(phase, "k", k, frame, field, sample, level)
        want = edges([expected_tx(k)[0] for k in range(len(samples))])
        got = edges([tx_char(s) for s in samples])
        runs = [b - a for a, b in zip([0] + got, got)]
        self.log.info("%s: k=0..%d checked (%d samples)", phase, len(samples) - 1, len(samples))
        self.log.info("%s: TX edges measured %s", phase, got)
        self.log.info("%s: TX run lengths measured (clk) %s", phase, runs)
        if got != want:
            first = next((i for i, (w, g) in enumerate(zip(want, got)) if w != g),
                         min(len(want), len(got)))
            w = want[first] if first < len(want) else None
            g = got[first] if first < len(got) else None
            self.edge_notes.append(
                f"{phase}: TX edge #{first} expected at k={w}, measured at k={g}; "
                f"edges expected {len(want)}, measured {len(got)}"
            )

    def finish(self):
        if not self.ranges:
            self.log.info("all checks passed: TX mismatches 0, other-output mismatches 0")
            return
        lines = [
            f"MISMATCH: TX mismatches {self.tx_count}, other-output mismatches "
            f"{self.other_count}, in {len(self.ranges)} ranges; first "
            f"{min(MAX_LISTED, len(self.ranges))}:"
        ]
        for phase, pos_name, first, last, frame, field, what, expected, got in \
                self.ranges[:MAX_LISTED]:
            frame_txt = "" if frame is None else f" frame={frame}"
            count = last - first + 1
            lines.append(
                f"{phase}: {pos_name}={first}..{last} ({count} sample{'' if count == 1 else 's'})"
                f"{frame_txt} field={field}: {what} expected {expected} got {got}"
            )
        lines += self.edge_notes
        raise AssertionError("\n".join(lines))


async def start_in_reset(dut):
    """T4: every input is set before the first clock edge; the clock starts low."""
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    Clock(dut.clk, CLK_PERIOD_NS, unit="ns").start(start_high=False)
    await RisingEdge(dut.clk)  # first rising edge with rst_n = 0 seen by this test


async def hold_reset(dut):
    """Read at RESET_CYCLES falling edges with rst_n = 0, then release (T14).

    Called right after rst_n = 0 was written or right after a rising edge with
    rst_n = 0, so every read follows at least one rising edge with rst_n = 0.
    The rising edge after the release is k = 0 (D-016).
    """
    samples = []
    for _ in range(RESET_CYCLES):
        await FallingEdge(dut.clk)
        samples.append(read_ports(dut))
    dut.rst_n.value = 1
    return samples


async def sample_window(dut, count):
    """Out(k) for k = 0 .. count-1: one read at the falling edge inside each cycle."""
    samples = []
    for _ in range(count):
        await FallingEdge(dut.clk)
        samples.append(read_ports(dut))
    return samples


@cocotb.test()
async def test_uart_frame(dut):
    """Reset, idle after reset, N_FRAMES frames with pauses, other outputs 0."""
    check_config()
    report = Report(dut)
    await start_in_reset(dut)
    report.reset(await hold_reset(dut), "initial reset")
    report.window(await sample_window(dut, WINDOW_LAST + 1), "frames after reset")
    report.finish()


@cocotb.test()
async def test_uart_reset_mid_frame(dut):
    """Reset in the middle of the start bit of frame 0, then the same window from k = 0."""
    check_config()
    report = Report(dut)
    await start_in_reset(dut)
    report.reset(await hold_reset(dut), "initial reset")
    report.window(await sample_window(dut, MID_RESET_AT + 1), "before reset during frame")
    dut.rst_n.value = 0  # T14: right after the falling edge inside cycle MID_RESET_AT
    report.reset(await hold_reset(dut), "reset during frame 0")
    report.window(await sample_window(dut, WINDOW_LAST + 1), "frames after restart")
    report.finish()
