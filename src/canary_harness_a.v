`default_nettype none
// Canary harness, set A: constructs expected to pass, plus the control c00. Set id 0xA1.
// sel selects which canary drives y; sel = 31 returns the set id.
module canary_harness (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [4:0] sel,
    input  wire [7:0] a,
    output reg  [7:0] y
);
  wire [7:0] y00, y01, y02, y03, y04, y05, y06, y07;
  wire [7:0] y08, y09, y10, y11, y13, y14;

  canary_baseline      c00 (.clk(clk), .rst_n(rst_n), .a(a), .y(y00));
  canary_ext_v         c01 (.a(a), .y(y01));
  canary_logic         c02 (.a(a), .y(y02));
  canary_always_comb   c03 (.a(a), .y(y03));
  canary_always_ff     c04 (.clk(clk), .rst_n(rst_n), .a(a), .y(y04));
  canary_enum          c05 (.clk(clk), .rst_n(rst_n), .a(a), .y(y05));
  canary_struct        c06 (.a(a), .y(y06));
  canary_package       c07 (.a(a), .y(y07));
  canary_param #(.ADD(8'd7)) c08 (.a(a), .y(y08));  // override: default ADD is 5
  canary_clog2         c09 (.a(a), .y(y09));
  canary_generate      c10 (.a(a), .y(y10));
  canary_rom_case      c11 (.a(a), .y(y11));
  canary_unique_case   c13 (.a(a), .y(y13));
  canary_priority_case c14 (.a(a), .y(y14));

  always @* begin
    case (sel)
      5'd0:    y = y00;
      5'd1:    y = y01;
      5'd2:    y = y02;
      5'd3:    y = y03;
      5'd4:    y = y04;
      5'd5:    y = y05;
      5'd6:    y = y06;
      5'd7:    y = y07;
      5'd8:    y = y08;
      5'd9:    y = y09;
      5'd10:   y = y10;
      5'd11:   y = y11;
      5'd13:   y = y13;
      5'd14:   y = y14;
      5'd31:   y = 8'hA1;
      default: y = 8'h00;
    endcase
  end
endmodule
