`default_nettype none
// c10 generate for loop with a named block.
// Combinational: y = a with the bit order reversed.
module canary_generate (
    input  wire [7:0] a,
    output wire [7:0] y
);
  genvar i;

  generate
    for (i = 0; i < 8; i = i + 1) begin : g_rev
      assign y[i] = a[7 - i];
    end
  endgenerate
endmodule
