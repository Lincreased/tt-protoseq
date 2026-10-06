`default_nettype none
// c05 typedef enum (the base type uses logic, so read together with c02).
// Sequential: a 2-bit state S0->S1->S2->S3->S0 advances on each clock while a[0] = 1; y = {6'b0, state}.
module canary_enum (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] a,
    output wire [7:0] y
);
  typedef enum logic [1:0] {
    S0 = 2'd0,
    S1 = 2'd1,
    S2 = 2'd2,
    S3 = 2'd3
  } state_t;

  state_t state;

  always @(posedge clk) begin
    if (!rst_n) begin
      state <= S0;
    end else if (a[0]) begin
      case (state)
        S0:      state <= S1;
        S1:      state <= S2;
        S2:      state <= S3;
        default: state <= S0;
      endcase
    end
  end

  assign y = {6'b000000, state};

  wire _unused = &{1'b0, a[7:1]};
endmodule
