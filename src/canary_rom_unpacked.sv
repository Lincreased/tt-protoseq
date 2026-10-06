`default_nettype none
// c15 ROM on an unpacked localparam array with an assignment-pattern literal (set B).
// Expected to fail in Yosys per FACT-084 (array literals not supported); measured here anyway.
// Combinational: y = ROM[a[3:0]]; a[7:4] is ignored. Same table as c11 and c12.
module canary_rom_unpacked (
    input  wire [7:0] a,
    output wire [7:0] y
);
  localparam logic [7:0] ROM [0:15] = '{
    8'h3A, 8'hC5, 8'h17, 8'hE2, 8'h90, 8'h4B, 8'hFF, 8'h00,  // entries 0..7
    8'h81, 8'h7E, 8'h2D, 8'hD4, 8'h66, 8'h99, 8'h5C, 8'hA3   // entries 8..15
  };

  assign y = ROM[a[3:0]];

  wire _unused = &{1'b0, a[7:4]};
endmodule
