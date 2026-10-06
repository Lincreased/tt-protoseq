`default_nettype none
// c00 control: Verilog-2005 only. If this canary fails, the harness or the flow is broken, not a construct.
// Sequential: y = a + 1, registered; reset value 0.
module canary_baseline (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] a,
    output wire [7:0] y
);
  reg [7:0] q;

  always @(posedge clk) begin
    if (!rst_n) q <= 8'h00;
    else        q <= a + 8'd1;
  end

  assign y = q;
endmodule
