`default_nettype none
// c06 typedef struct packed (members use logic, so read together with c02).
// Combinational: y = a with nibbles swapped.
module canary_struct (
    input  wire [7:0] a,
    output wire [7:0] y
);
  typedef struct packed {
    logic [3:0] hi;
    logic [3:0] lo;
  } pair_t;

  pair_t p;

  assign p = a;
  assign y = {p.lo, p.hi};
endmodule
