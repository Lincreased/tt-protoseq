`default_nettype none
// c12 ROM on a packed two-dimensional localparam (program-memory style candidate for step 4).
// Combinational: y = ROM[a[3:0]]; a[7:4] is ignored. Same table as c11 and c15.
// ROM[i] is entry i. A packed concatenation lists the highest index first, so entry 15 comes first.
module canary_rom_packed (
    input  wire [7:0] a,
    output wire [7:0] y
);
  localparam logic [15:0][7:0] ROM = {
    8'hA3, 8'h5C, 8'h99, 8'h66, 8'hD4, 8'h2D, 8'h7E, 8'h81,  // entries 15..8
    8'h00, 8'hFF, 8'h4B, 8'h90, 8'hE2, 8'h17, 8'hC5, 8'h3A   // entries 7..0
  };

  assign y = ROM[a[3:0]];

  wire _unused = &{1'b0, a[7:4]};
endmodule
