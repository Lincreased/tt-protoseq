`default_nettype none
// c17 ROM on a flat localparam vector read with an indexed part-select (+:), Verilog-2005 style.
// Program-memory style candidate for step 4, after c12 (packed 2-D) and c15 (unpacked) failed in CI.
// Combinational: y = ROM[a[3:0]]; a[7:4] is ignored. Same table as c11, c12 and c15.
// Entry i occupies bits [8*i +: 8]; the concatenation lists entry 15 first (MSB) and entry 0 last.
module canary_rom_flat (
    input  wire [7:0] a,
    output wire [7:0] y
);
  localparam [127:0] ROM = {
    8'hA3, 8'h5C, 8'h99, 8'h66, 8'hD4, 8'h2D, 8'h7E, 8'h81,  // entries 15..8
    8'h00, 8'hFF, 8'h4B, 8'h90, 8'hE2, 8'h17, 8'hC5, 8'h3A   // entries 7..0
  };

  assign y = ROM[{a[3:0], 3'b000} +: 8];

  wire _unused = &{1'b0, a[7:4]};
endmodule
