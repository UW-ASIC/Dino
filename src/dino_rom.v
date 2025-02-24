`default_nettype none

module dino_rom (
  input  wire       clk,      // clock
  input  wire       rst, 
  input wire [5:0] i_rom_counter,
  input wire [2:0] i_player_state,
  output reg  o_sprite_color
);

// localparam RESTART   = 3'b000;
localparam JUMPING   = 3'b001;
localparam RUNNING_1 = 3'b010;
localparam RUNNING_2 = 3'b011;
localparam DUCKING   = 3'b100;
// localparam GAME_OVER = 3'b101;

reg [2:0] rom_x;
reg [2:0] rom_y;
always @(*) begin
  {rom_y, rom_x} = i_rom_counter;
end
reg [7:0] icon [7:0];
reg [7:0] icon_run_1 [7:0];
reg [7:0] icon_run_2 [7:0];
reg [7:0] icon_duck [7:0];

always @(posedge clk or posedge rst) begin
  if (rst) begin
    icon[0] <= 8'b01110000;
    icon[1] <= 8'b11110000;
    icon[2] <= 8'b00110000;
    icon[3] <= 8'b00111001;
    icon[4] <= 8'b00111111;
    icon[5] <= 8'b00011110;
    icon[6] <= 8'b00010100;
    icon[7] <= 8'b00010100;
  end
end

always @(posedge clk or posedge rst) begin
  if (rst) begin
    icon_run_1[0] <= 8'b01110000;
    icon_run_1[1] <= 8'b11110000;
    icon_run_1[2] <= 8'b00110000;
    icon_run_1[3] <= 8'b00111001;
    icon_run_1[4] <= 8'b00111111;
    icon_run_1[5] <= 8'b00011110;
    icon_run_1[6] <= 8'b00010100;
    icon_run_1[7] <= 8'b00000100;
  end
end

always @(posedge clk or posedge rst) begin
  if (rst) begin
    icon_run_2[0] <= 8'b01110000;
    icon_run_2[1] <= 8'b11110000;
    icon_run_2[2] <= 8'b00110000;
    icon_run_2[3] <= 8'b00111001;
    icon_run_2[4] <= 8'b00111111;
    icon_run_2[5] <= 8'b00011110;
    icon_run_2[6] <= 8'b00010100;
    icon_run_2[7] <= 8'b00010000;
  end
end

always @(posedge clk or posedge rst) begin
  if (rst) begin
    icon_duck[0] <= 8'b00000000;
    icon_duck[1] <= 8'b00000000;
    icon_duck[2] <= 8'b00000000;
    icon_duck[3] <= 8'b01110000;
    icon_duck[4] <= 8'b11111001;
    icon_duck[5] <= 8'b00111111;
    icon_duck[6] <= 8'b00011110;
    icon_duck[7] <= 8'b00010100;
    
  end
end

always @(*) begin
  case (i_player_state)
        JUMPING: begin
          o_sprite_color = icon[rom_y][rom_x];
        end
        RUNNING_1: begin
          o_sprite_color = icon_run_1[rom_y][rom_x];
        end
        RUNNING_2: begin
          o_sprite_color = icon_run_2[rom_y][rom_x];
        end
        DUCKING: begin
          o_sprite_color = icon_duck[rom_y][rom_x];
        end
        default: o_sprite_color = icon[rom_y][rom_x];
  endcase
end

endmodule

