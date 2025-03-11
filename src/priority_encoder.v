module priority_encoder_4_2 (
    input wire I0,
    input wire I1,
    input wire I2,
    input wire I3,
    output reg O0,
    output reg O1,
    output reg V
);
  always @(*) begin
    V = I0 || I1 || I2 || I3;
    O0 = ((~I2) && I1) || I3;
    O1 = I2 || I3;
  end
endmodule


