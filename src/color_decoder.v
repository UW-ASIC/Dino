module color_decoder_2_6 (
    input wire is_colored,
    input wire [1:0] layer,
    input wire rgb_scheme,
    input wire invert,
    output reg [1:0] R,
    output reg [1:0] G,
    output reg [1:0] B
);
  always @(*) begin
    case (layer)
      2'b00: begin
        R = 2'b01;
        G = 2'b10;
        B = 2'b10;
      end
      2'b01: begin
        R = 2'b00;
        G = 2'b11;
        B = 2'b00;
      end
      2'b10: begin
        R = 2'b10;
        G = 2'b10;
        B = 2'b00;
      end
      2'b11: begin
        R = 2'b00;
        G = 2'b00;
        B = 2'b00;
      end
      default: begin
        R = 2'b00;
        G = 2'b00;
        B = 2'b00;
      end
    endcase
    if (~rgb_scheme) begin
      R = 2'b00;
      G = 2'b00;
      B = 2'b00;
    end
    if (~is_colored) begin
      R = 2'b11;
      G = 2'b11;
      B = 2'b11;
    end
    if (invert) begin
      R = ~R;
      G = ~G;
      B = ~B;
    end
  end
endmodule


