`default_nettype none
// c02 logic (and the .sv half of the extension pair with c01).
// Combinational: y = a ^ 8'hC3.
module canary_logic (
    input  wire [7:0] a,
    output wire [7:0] y
);
  logic [7:0] t;

  assign t = a ^ 8'hC3;
  assign y = t;
endmodule
