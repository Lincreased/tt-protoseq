`default_nettype none
// c03 always_comb. The variable is a reg, so this canary does not depend on logic.
// Combinational: y = a | 8'hF0.
module canary_always_comb (
    input  wire [7:0] a,
    output wire [7:0] y
);
  reg [7:0] t;

  always_comb begin
    t = a | 8'hF0;
  end

  assign y = t;
endmodule
