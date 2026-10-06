`default_nettype none
// c19 package import in the module header: module m import canary_pkg::*; (...).
// (c07 with "import canary_pkg::*;" inside the module body failed the Yosys 0.55 port check.)
// Needs canary_pkg.sv earlier in every file list.
// Combinational: y = a ^ K, where canary_pkg::K = 8'h3C.
module canary_pkg_header
  import canary_pkg::*;
(
    input  wire [7:0] a,
    output wire [7:0] y
);
  assign y = a ^ K;
endmodule
