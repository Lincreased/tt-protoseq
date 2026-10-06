`default_nettype none
// c14 priority case (a priority encoder with a default).
// Combinational: y = 8'h08 if a[3], else 8'h04 if a[2], else 8'h02 if a[1], else 8'h00.
module canary_priority_case (
    input  wire [7:0] a,
    output reg  [7:0] y
);
  always @* begin
    priority case (1'b1)
      a[3]:    y = 8'h08;
      a[2]:    y = 8'h04;
      a[1]:    y = 8'h02;
      default: y = 8'h00;
    endcase
  end

  wire _unused = &{1'b0, a[7:4], a[0]};
endmodule
