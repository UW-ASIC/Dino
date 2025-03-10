`default_nettype none

module obs_render #(parameter CONV = 0) (
  input  wire       clk,      // clock
  input  wire       rst, 

  // Graphics
  input wire [9:CONV] i_hpos,
  input wire [9:CONV] i_vpos,
  output reg o_color_obs,   // Dedicated outputs

  // ROM
  output reg [7:0] o_rom_counter,
  input wire  i_sprite_color,

  // Obstacle
  input wire [9:CONV] i_xpos
);

  reg [9:CONV] y_offset;
  reg [9:CONV] x_offset;
  reg in_sprite;

  reg [9:CONV] y_offset_r;
  reg [9:CONV] x_offset_r;
  always @(posedge clk) begin
  if (rst) begin 
    y_offset_r <= 0;
    x_offset_r <= 0;
  end else begin
      y_offset_r <= y_offset;
      x_offset_r <= x_offset;
  end 
  end 

  always @(*) begin
    y_offset = i_vpos - 42;
    x_offset = i_hpos - i_xpos[9:CONV] + 16;
    in_sprite = (x_offset_r < 16) && (y_offset_r < 16);
  end 
  
  // ROM addressing
  reg [3:0] rom_x;
  reg [3:0] rom_y;
  always @(*) begin
    rom_x = x_offset_r[CONV+3:CONV];
    rom_y = y_offset_r[CONV+3:CONV];
    o_rom_counter = {rom_y, rom_x};
  end

  always @(*) begin
    o_color_obs = 1'b0;
    if (in_sprite) begin
      o_color_obs = i_sprite_color;
    end
  end
endmodule


