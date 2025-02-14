`default_nettype none

module dino_rom (
  input  wire       clk,      // clock
  input  wire       rst, 
  input wire [5:0] i_rom_counter,
  output reg  o_sprite_color
);

reg [2:0] rom_x;
reg [2:0] rom_y;
reg color;
always @(*) begin
  {rom_y, rom_x} = i_rom_counter;
end
reg [7:0] icon [7:0];

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
    color <= 0;
  end else begin
    color <= icon[rom_y][rom_x];
  end
end

always @(*) begin
  o_sprite_color = color;
  o_sprite_color = icon[rom_y][rom_x];
end

endmodule

