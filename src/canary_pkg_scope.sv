`default_nettype none
// c18 package constant by explicit scope reference, no import: canary_pkg::K.
// (c07 with "import canary_pkg::*;" inside the module body failed the Yosys 0.55 port check.)
// Needs canary_pkg.sv earlier in every file list.
// Combinational: y = a ^ canary_pkg::K (8'h3C).
module canary_pkg_scope (
    input  wire [7:0] a,
    output wire [7:0] y
);
  assign y = a ^ canary_pkg::K;
endmodule
