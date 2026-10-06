`default_nettype none
// Canary harness, set B: the control c00 plus c15 (ROM on an unpacked localparam array). Set id 0xB2.
// sel selects which canary drives y; sel = 31 returns the set id.
module canary_harness (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [4:0] sel,
    input  wire [7:0] a,
    output reg  [7:0] y
);
  wire [7:0] y00, y15;

  canary_baseline     c00 (.clk(clk), .rst_n(rst_n), .a(a), .y(y00));
  canary_rom_unpacked c15 (.a(a), .y(y15));

  always @* begin
    case (sel)
      5'd0:    y = y00;
      5'd15:   y = y15;
      5'd31:   y = 8'hB2;
      default: y = 8'h00;
    endcase
  end
endmodule
