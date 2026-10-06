`default_nettype none
// c11 ROM written as a case statement (program-memory style candidate for step 4).
// Combinational: y = ROM[a[3:0]]; a[7:4] is ignored. Same table as c12 and c15.
module canary_rom_case (
    input  wire [7:0] a,
    output reg  [7:0] y
);
  always @* begin
    case (a[3:0])
      4'h0: y = 8'h3A;
      4'h1: y = 8'hC5;
      4'h2: y = 8'h17;
      4'h3: y = 8'hE2;
      4'h4: y = 8'h90;
      4'h5: y = 8'h4B;
      4'h6: y = 8'hFF;
      4'h7: y = 8'h00;
      4'h8: y = 8'h81;
      4'h9: y = 8'h7E;
      4'hA: y = 8'h2D;
      4'hB: y = 8'hD4;
      4'hC: y = 8'h66;
      4'hD: y = 8'h99;
      4'hE: y = 8'h5C;
      4'hF: y = 8'hA3;
    endcase
  end

  wire _unused = &{1'b0, a[7:4]};
endmodule
