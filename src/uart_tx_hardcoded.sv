/*
 * Copyright (c) 2026 Lincreased
 * SPDX-License-Identifier: Apache-2.0
 *
 * uart_tx_hardcoded: hardcoded UART transmitter, contract = DECISIONS.md D-016.
 * Sends 8N1 frames of one fixed symbol forever, with a pause of PAUSE_CLKS
 * clock cycles of level 1 between frames.
 *
 * Timing (k = 0 is the first rising clk edge with rst_n = 1):
 *   tx = 1 for k = 0 .. PAUSE_CLKS-1, then frame n starts at
 *   k_n = PAUSE_CLKS + n * (10 * BIT_CLKS + PAUSE_CLKS).
 *   Every bit lasts exactly BIT_CLKS cycles. tx comes straight from a flop.
 *
 * Parameter limits: BIT_CLKS >= 1, PAUSE_CLKS >= 1.
 * Reset is synchronous: tx = 1 after >= 1 rising edge with rst_n = 0.
 */

`default_nettype none

module uart_tx_hardcoded #(
    parameter BIT_CLKS   = 434,  // D: clk cycles per bit (50 MHz / 115200)
    parameter PAUSE_CLKS = 434   // P: clk cycles of idle level after each stop bit
) (
    input  logic clk,
    input  logic rst_n,  // active low
    output logic tx
);

  // Symbol 'A' = 0x41, sent LSB first.
  localparam [7:0] CHAR = 8'h41;

  // Line sequence indexed by slot: [0] start, [8:1] d0..d7, [9] stop,
  // [15:10] idle (slot 10 = pause; 11..15 are never reached).
  localparam [15:0] FRAME = {6'b111111, 1'b1, CHAR, 1'b0};

  localparam [3:0] PAUSE_IDX = 4'd10;

  // Counter width from the longer of the two slot lengths.
  localparam LIM = (BIT_CLKS > PAUSE_CLKS) ? BIT_CLKS : PAUSE_CLKS;
  localparam CW = $clog2(LIM + 1);

  // Last cycle count of a slot.
  localparam [CW-1:0] BIT_LAST = BIT_CLKS - 1;
  localparam [CW-1:0] PAUSE_LAST = PAUSE_CLKS - 1;

  logic [3:0]    idx;   // current slot: 0..9 frame bits, 10 pause
  logic [CW-1:0] cnt;   // cycle within the current slot
  logic [CW-1:0] last;  // last cycle of the current slot

  always_comb begin
    if (idx == PAUSE_IDX) begin
      last = PAUSE_LAST;
    end else begin
      last = BIT_LAST;
    end
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      idx <= PAUSE_IDX;
      cnt <= {CW{1'b0}};
      tx  <= 1'b1;
    end else begin
      tx <= FRAME[idx+:1];
      if (cnt == last) begin
        cnt <= {CW{1'b0}};
        if (idx == PAUSE_IDX) begin
          idx <= 4'd0;
        end else begin
          idx <= idx + 4'd1;
        end
      end else begin
        cnt <= cnt + 1'b1;
      end
    end
  end

endmodule
