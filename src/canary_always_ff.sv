`default_nettype none
// c04 always_ff with a synchronous active-low reset (the reset style is not decided by the canary).
// Sequential: y = a - 1, registered; reset value 0.
module canary_always_ff (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] a,
    output wire [7:0] y
);
  reg [7:0] q;

  always_ff @(posedge clk) begin
    if (!rst_n) q <= 8'h00;
    else        q <= a - 8'd1;
  end

  assign y = q;
endmodule
