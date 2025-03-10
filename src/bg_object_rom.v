`default_nettype none

module bg_object_rom (
  input  wire       clk,     
  input  wire       rst, 
  input wire [5:0] i_rom_counter,
  output reg  o_sprite_color
);

reg [2:0] rom_x;
reg [2:0] rom_y;


always @(*) begin
  {rom_y, rom_x} = i_rom_counter;
end

reg [7:0] icon_cloud [7:0];

always @(posedge clk) begin
  if (rst) begin
    icon_cloud[0]  <= 8'b00000000;
    icon_cloud[1]  <= 8'b00000000;
    icon_cloud[2]  <= 8'b00001100;
    icon_cloud[3]  <= 8'b00011110;
    icon_cloud[4]  <= 8'b01101011;
    icon_cloud[5]  <= 8'b11000001;
    icon_cloud[6]  <= 8'b11111111;
    icon_cloud[7]  <= 8'b01100110;
  end
end

always @(*) begin
  o_sprite_color = icon_cloud[rom_y][rom_x];
end

endmodule

