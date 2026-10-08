/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_Lincreased_protoseq (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
  wire tx;

  uart_tx_hardcoded #(
    .BIT_CLKS  (434),
    .PAUSE_CLKS(434)
  ) u_uart_tx (
    .clk  (clk),
    .rst_n(rst_n),
    .tx   (tx)
  )
  // All outputs must be assigned. If not used, assign to 0. 
  // D-016: uo_out[4] = TX, all other outputs 0.
  assign uo_out = {3'b000, tx, 4'b000};
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in, uio_in, 1'b0};

endmodule
