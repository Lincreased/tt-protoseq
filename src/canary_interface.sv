`default_nettype none
// c16 interface (set C; expected risky: Yosys supports interfaces only partially, FACT-084).
// The interface is connected by name. Combinational: y = ~a.
interface canary_bus;
  logic [7:0] d;
endinterface

module canary_if_user (
    canary_bus       bus,
    output wire [7:0] y
);
  assign y = ~bus.d;
endmodule

module canary_interface (
    input  wire [7:0] a,
    output wire [7:0] y
);
  canary_bus bus_i ();

  assign bus_i.d = a;

  canary_if_user u_user (
      .bus(bus_i),
      .y  (y)
  );
endmodule
