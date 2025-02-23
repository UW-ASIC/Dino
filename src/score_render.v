`default_nettype none

module score_render #(parameter CONV = 0) (
  input  wire       clk,     
  input  wire       rst, 
  input wire [3:0] num,
  input wire [9:CONV] i_hpos,
  input wire [9:CONV] i_vpos,
  output reg  o_score_color
);

reg [9:CONV] y_offset;
reg [9:CONV] x_offset;
reg in_sprite;
reg [9:0] rom_data;
wire [9:0] rom_output;
reg [3:0] rom_address;
reg [3:0] digit_select;

always @(*) begin
  y_offset = i_vpos - 1;
  x_offset = i_hpos - 28;
  in_sprite = (x_offset < 4) && (y_offset < 7);
  
  rom_address = y_offset * 4 + x_offset;
  digit_select = num;
end 

always @(posedge clk or posedge rst) begin
  if (rst) begin
    rom_data <= 10'b0;
  end else begin
    rom_data <= rom_output;
  end
end

always @(*) begin
  o_score_color = rom_data[digit_select] && in_sprite;
end

score_rom score_rom_inst (
  .clk(clk),
  .rst(rst),
  .address(rom_address),
  .data(rom_output)
);

endmodule
