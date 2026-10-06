`default_nettype none
// Canary harness, set D: the control c00 plus c17 (flat ROM), c18 (package scope reference)
// and c19 (package import in the module header). Set id 0xD4.
// sel selects which canary drives y; sel = 31 returns the set id.
module canary_harness (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [4:0] sel,
    input  wire [7:0] a,
    output reg  [7:0] y
);
  wire [7:0] y00, y17, y18, y19;

  canary_baseline   c00 (.clk(clk), .rst_n(rst_n), .a(a), .y(y00));
  canary_rom_flat   c17 (.a(a), .y(y17));
  canary_pkg_scope  c18 (.a(a), .y(y18));
  canary_pkg_header c19 (.a(a), .y(y19));

  always @* begin
    case (sel)
      5'd0:    y = y00;
      5'd17:   y = y17;
      5'd18:   y = y18;
      5'd19:   y = y19;
      5'd31:   y = 8'hD4;
      default: y = 8'h00;
    endcase
  end
endmodule
