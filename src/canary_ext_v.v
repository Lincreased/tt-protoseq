`default_nettype none
// c01 file extension: the same construct as c02 (logic), but in a .v file.
// Read together with c02: c02 passes and c01 fails in a tool => that tool reads .v as Verilog, not SystemVerilog.
// Combinational: y = a ^ 8'h5A.
module canary_ext_v (
    input  wire [7:0] a,
    output wire [7:0] y
);
  logic [7:0] t;

  assign t = a ^ 8'h5A;
  assign y = t;
endmodule
