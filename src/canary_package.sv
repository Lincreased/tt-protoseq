`default_nettype none
// c07 package, part 2 of 2: a module that imports canary_pkg.
// Combinational: y = a ^ K, where canary_pkg::K = 8'h3C.
module canary_package (
    input  wire [7:0] a,
    output wire [7:0] y
);
  import canary_pkg::*;

  assign y = a ^ K;
endmodule
