`default_nettype none

module dino_render #(parameter CONV = 0) (
  input  wire       clk,      // clock
  input  wire       rst, 

  // Graphics
  input wire [9:CONV] i_hpos,
  input wire [9:CONV] i_vpos,
  output reg o_color_dino,   // Dedicated outputs

  // ROM
  output reg [5:0] o_rom_counter,
  input wire  i_sprite_color,

  // Player
  input wire [5:0] i_ypos
);

  reg [9:CONV] y_offset;
  reg [9:CONV] x_offset;
  reg in_sprite;

  reg [9:CONV] y_offset_r;
  reg [9:CONV] x_offset_r;
  always @(posedge clk or posedge rst) begin
  if (rst) begin 
    y_offset_r <= 0;
    x_offset_r <= 0;
  end else begin
      y_offset_r <= y_offset;
      x_offset_r <= x_offset;
  end 
  end 

  always @(*) begin
    y_offset = i_vpos - i_ypos;
    x_offset = i_hpos - 6;
    in_sprite = (x_offset_r < 8) && (y_offset_r < 8);
  end 

  // ROM addressing
  reg [2:0] rom_x;
  reg [2:0] rom_y;
  always @(*) begin
    rom_x = x_offset_r[CONV+2:CONV];
    rom_y = y_offset_r[CONV+2:CONV];
  end
  always @(*) begin
    o_rom_counter = {rom_y, rom_x};
  end

  always @(*) begin
    o_color_dino = 1'b0;
    // optimize this heavily for ROM
    if (in_sprite) begin
      o_color_dino = i_sprite_color;
    end
  end
endmodule

