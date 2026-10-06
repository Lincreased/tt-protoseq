`default_nettype none
// c13 unique case. The case is full, so its meaning does not depend on how a tool treats "unique".
// Combinational: y = 8'h11 / 8'h22 / 8'h44 / 8'h88 for a[1:0] = 0 / 1 / 2 / 3.
module canary_unique_case (
    input  wire [7:0] a,
    output reg  [7:0] y
);
  always @* begin
    unique case (a[1:0])
      2'b00: y = 8'h11;
      2'b01: y = 8'h22;
      2'b10: y = 8'h44;
      2'b11: y = 8'h88;
    endcase
  end

  wire _unused = &{1'b0, a[7:2]};
endmodule
