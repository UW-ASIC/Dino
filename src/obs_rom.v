`default_nettype none

module obs_rom (
  input  wire       clk,     
  input  wire       rst, 
  input wire [2:0] i_rom_counter,
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

reg  rom_x;
reg [1:0] rom_y;


always @(*) begin
  {rom_y, rom_x} = i_rom_counter;
end
reg [1:0] icon [3:0];

always @(posedge clk or posedge rst) begin
  if (rst) begin
    icon[0] <= 2'b01;
    icon[1] <= 2'b01;
    icon[2] <= 2'b01;
    icon[3] <= 2'b01;
  end
end

always @(*) begin
  case (i_obs_type)
        EMPTY: begin
          o_sprite_color = 1'b0;
        end
        CAC_3: begin
          o_sprite_color = icon[rom_y][rom_x];
        end
        CAC_2: begin
          o_sprite_color = icon[rom_y][rom_x];
        end
        CAC_THICK_1: begin
          o_sprite_color = icon[rom_y][rom_x];
        end
        CAC_THICK_2: begin
          o_sprite_color = icon[rom_y][rom_x];
        end
        CAC_THIN: begin
          o_sprite_color = icon[rom_y][rom_x];
        end
        BIRD_LOW: begin
          o_sprite_color = icon[rom_y][rom_x];
        end
        BIRD_HIGH: begin
          o_sprite_color = icon[rom_y][rom_x];
        end
        default: o_sprite_color = 1'b0;
  endcase
end

endmodule

