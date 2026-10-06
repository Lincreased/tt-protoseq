`default_nettype none
// c09 $clog2 in a localparam.
// Combinational: y = a + $clog2(12) = a + 4.
module canary_clog2 (
    input  wire [7:0] a,
    output wire [7:0] y
);
  localparam integer N = 12;
  localparam [7:0] W = $clog2(N);  // 4

  assign y = a + W;
endmodule
