/*
 * Canary branch only: the TT top instantiates the canary harness instead of the design.
 * Do not merge into the main branch.
 */
`default_nettype none

module tt_um_Lincreased_protoseq (
    input  wire [7:0] ui_in,    // a: canary input
    output wire [7:0] uo_out,   // y of the selected canary
    input  wire [7:0] uio_in,   // [4:0] = sel
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
  canary_harness u_harness (
      .clk  (clk),
      .rst_n(rst_n),
      .sel  (uio_in[4:0]),
      .a    (ui_in),
      .y    (uo_out)
  );

  assign uio_out = 8'h00;
  assign uio_oe  = 8'h00;  // all uio are inputs

  wire _unused = &{ena, uio_in[7:5], 1'b0};
endmodule
