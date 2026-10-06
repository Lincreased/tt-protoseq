`default_nettype none
// c08 parameter and localparam. The harness overrides ADD to 7, so a result with 5 means the override was lost.
// Combinational: y = (a + ADD) & 8'h7F.
module canary_param #(
    parameter [7:0] ADD = 8'd5
) (
    input  wire [7:0] a,
    output wire [7:0] y
);
  localparam [7:0] MASK = 8'h7F;

  assign y = (a + ADD) & MASK;
endmodule
