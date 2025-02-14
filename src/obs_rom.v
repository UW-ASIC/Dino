`default_nettype none

module obs_rom (
  input  wire       clk,     
  input  wire       rst, 
  input wire [2:0] i_rom_counter,
  output reg  o_sprite_color
);

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
  o_sprite_color = icon[rom_y][rom_x];
end

endmodule

