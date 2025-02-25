`default_nettype none

module obs_rom (
  input  wire       clk,     
  input  wire       rst, 
  input wire [7:0] i_rom_counter,
  input wire [2:0] i_obs_type,
  output reg  o_sprite_color
);

localparam EMPTY        = 3'b000;
localparam CAC_3        = 3'b001;
localparam CAC_2        = 3'b010;
localparam CAC_THICK_1  = 3'b011; // actually the same as cac thick 2 but just repeating for probability purposes
localparam CAC_THICK_2  = 3'b100;
localparam CAC_THIN     = 3'b101;
localparam BIRD_LOW     = 3'b110;
localparam BIRD_HIGH    = 3'b111;

reg [3:0] rom_x;
reg [3:0] rom_y;


always @(*) begin
  {rom_y, rom_x} = i_rom_counter;
end

reg [15:0] icon_cac_3 [15:0];
reg [15:0] icon_cac_2 [15:0];
reg [15:0] icon_cac_thick_1 [15:0];
reg [15:0] icon_cac_thick_2 [15:0];
reg [15:0] icon_cac_thin [15:0];
reg [15:0] icon_bird_low [15:0];
reg [15:0] icon_bird_high [15:0];

always @(posedge clk) begin
  if (rst) begin
    icon_cac_3[0]  <= 16'b0000000000000000;
    icon_cac_3[1]  <= 16'b0000000000000000;
    icon_cac_3[2]  <= 16'b0000000000000000;
    icon_cac_3[3]  <= 16'b0000000000000000;
    icon_cac_3[4]  <= 16'b0000000000000000;
    icon_cac_3[5]  <= 16'b0000000000000000;
    icon_cac_3[6]  <= 16'b0000000000000000;
    icon_cac_3[7]  <= 16'b0000000110000000;
    icon_cac_3[8]  <= 16'b0001000110000100;
    icon_cac_3[9]  <= 16'b0001000110000100;
    icon_cac_3[10] <= 16'b0101010110010100;
    icon_cac_3[11] <= 16'b0101011110011101;
    icon_cac_3[12] <= 16'b0101000110100111;
    icon_cac_3[13] <= 16'b0011000111100100;
    icon_cac_3[14] <= 16'b0001000110000100;
    icon_cac_3[15] <= 16'b0001000110000100;
  end
end

always @(posedge clk) begin
  if (rst) begin
    icon_cac_2[0]  <= 16'b0000000000000000;
    icon_cac_2[1]  <= 16'b0000000000000000;
    icon_cac_2[2]  <= 16'b0000000000000000;
    icon_cac_2[3]  <= 16'b0000000000000000;
    icon_cac_2[4]  <= 16'b0000000000000000;
    icon_cac_2[5]  <= 16'b0000000000000000;
    icon_cac_2[6]  <= 16'b0000000000000000;
    icon_cac_2[7]  <= 16'b0000000000000000;
    icon_cac_2[8]  <= 16'b0000110000000000;
    icon_cac_2[9]  <= 16'b0000110000010000;
    icon_cac_2[10] <= 16'b0000110000010000;
    icon_cac_2[11] <= 16'b0010110000010100;
    icon_cac_2[12] <= 16'b0011110101011100;
    icon_cac_2[13] <= 16'b0000111101110000;
    icon_cac_2[14] <= 16'b0000110000010000;
    icon_cac_2[15] <= 16'b0000110000010000;
  end
end
always @(posedge clk) begin
  if (rst) begin
    icon_cac_thick_1[0]  <= 16'b0000000000000000;
    icon_cac_thick_1[1]  <= 16'b0000000000000000;
    icon_cac_thick_1[2]  <= 16'b0000000000000000;
    icon_cac_thick_1[3]  <= 16'b0000000000000000;
    icon_cac_thick_1[4]  <= 16'b0000000000000000;
    icon_cac_thick_1[5]  <= 16'b0000000000000000;
    icon_cac_thick_1[6]  <= 16'b0000000000000000;
    icon_cac_thick_1[7]  <= 16'b0000000110000000;
    icon_cac_thick_1[8]  <= 16'b0000001110000000;
    icon_cac_thick_1[9]  <= 16'b0000001110110000;
    icon_cac_thick_1[10] <= 16'b0000001110110000;
    icon_cac_thick_1[11] <= 16'b0001101111110000;
    icon_cac_thick_1[12] <= 16'b0001101110000000;
    icon_cac_thick_1[13] <= 16'b0001111110000000;
    icon_cac_thick_1[14] <= 16'b0000001110000000;
    icon_cac_thick_1[15] <= 16'b0000001110000000;
  end
end
always @(posedge clk) begin
  if (rst) begin
    icon_cac_thick_2[0]  <= 16'b0000000000000000;
    icon_cac_thick_2[1]  <= 16'b0000000000000000;
    icon_cac_thick_2[2]  <= 16'b0000000000000000;
    icon_cac_thick_2[3]  <= 16'b0000000000000000;
    icon_cac_thick_2[4]  <= 16'b0000000000000000;
    icon_cac_thick_2[5]  <= 16'b0000000000000000;
    icon_cac_thick_2[6]  <= 16'b0000000000000000;
    icon_cac_thick_2[7]  <= 16'b0000000000000000;
    icon_cac_thick_2[8]  <= 16'b0000000110000000;
    icon_cac_thick_2[9]  <= 16'b0000110110000000;
    icon_cac_thick_2[10] <= 16'b0000111110110000;
    icon_cac_thick_2[11] <= 16'b0000000110110000;
    icon_cac_thick_2[12] <= 16'b0000000111110000;
    icon_cac_thick_2[13] <= 16'b0000000110000000;
    icon_cac_thick_2[14] <= 16'b0000000110000000;
    icon_cac_thick_2[15] <= 16'b0000000110000000;
  end
end
always @(posedge clk) begin
  if (rst) begin
    icon_cac_thin[0]  <= 16'b0000000000000000;
    icon_cac_thin[1]  <= 16'b0000000000000000;
    icon_cac_thin[2]  <= 16'b0000000000000000;
    icon_cac_thin[3]  <= 16'b0000000000000000;
    icon_cac_thin[4]  <= 16'b0000000000000000;
    icon_cac_thin[5]  <= 16'b0000000000000000;
    icon_cac_thin[6]  <= 16'b0000000000000000;
    icon_cac_thin[7]  <= 16'b0000000000000000;
    icon_cac_thin[8]  <= 16'b0000000100000000;
    icon_cac_thin[9]  <= 16'b0000000100000000;
    icon_cac_thin[10] <= 16'b0000010100000000;
    icon_cac_thin[11] <= 16'b0000011100000000;
    icon_cac_thin[12] <= 16'b0000000101000000;
    icon_cac_thin[13] <= 16'b0000000111000000;
    icon_cac_thin[14] <= 16'b0000000100000000;
    icon_cac_thin[15] <= 16'b0000000100000000;
  end
end
always @(posedge clk) begin
  if (rst) begin
    icon_bird_low[0]  <= 16'b0000000000000000;
    icon_bird_low[1]  <= 16'b0000000000000000;
    icon_bird_low[2]  <= 16'b0000000000000000;
    icon_bird_low[3]  <= 16'b0000000000000000;
    icon_bird_low[4]  <= 16'b0000000000000000;
    icon_bird_low[5]  <= 16'b0000000110000000;
    icon_bird_low[6]  <= 16'b0000000011000000;
    icon_bird_low[7]  <= 16'b0000000111101100;
    icon_bird_low[8]  <= 16'b0000101111101010;
    icon_bird_low[9]  <= 16'b0000011111110110;
    icon_bird_low[10] <= 16'b0000000000000000;
    icon_bird_low[11] <= 16'b0000000000000000;
    icon_bird_low[12] <= 16'b0000000000000000;
    icon_bird_low[13] <= 16'b0000000000000000;
    icon_bird_low[14] <= 16'b0000000000000000;
    icon_bird_low[15] <= 16'b0000000000000000;
  end
end
always @(posedge clk) begin
  if (rst) begin
    icon_bird_high[0]  <= 16'b0000000110000000;
    icon_bird_high[1]  <= 16'b0000000011000000;
    icon_bird_high[2]  <= 16'b0000000111101100;
    icon_bird_high[3]  <= 16'b0000101111101010;
    icon_bird_high[4]  <= 16'b0000011111110110;
    icon_bird_high[5]  <= 16'b0000000000000000;
    icon_bird_high[6]  <= 16'b0000000000000000;
    icon_bird_high[7]  <= 16'b0000000000000000;
    icon_bird_high[8]  <= 16'b0000000000000000;
    icon_bird_high[9]  <= 16'b0000000000000000;
    icon_bird_high[10] <= 16'b0000000000000000;
    icon_bird_high[11] <= 16'b0000000000000000;
    icon_bird_high[12] <= 16'b0000000000000000;
    icon_bird_high[13] <= 16'b0000000000000000;
    icon_bird_high[14] <= 16'b0000000000000000;
    icon_bird_high[15] <= 16'b0000000000000000;
  end
end

always @(*) begin
  case (i_obs_type)
        EMPTY: begin
          o_sprite_color = 1'b0;
        end
        CAC_3: begin
          o_sprite_color = icon_cac_3[rom_y][rom_x];
        end
        CAC_2: begin
          o_sprite_color = icon_cac_2[rom_y][rom_x];
        end
        CAC_THICK_1: begin
          o_sprite_color = icon_cac_thick_1[rom_y][rom_x];
        end
        CAC_THICK_2: begin
          o_sprite_color = icon_cac_thick_2[rom_y][rom_x];
        end
        CAC_THIN: begin
          o_sprite_color = icon_cac_thin[rom_y][rom_x];
        end
        BIRD_LOW: begin
          o_sprite_color = icon_bird_low[rom_y][rom_x];
        end
        BIRD_HIGH: begin
          o_sprite_color = icon_bird_high[rom_y][rom_x];
        end
        default: o_sprite_color = 1'b0;
  endcase
end

endmodule

