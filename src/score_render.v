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
reg [7:0] segment;

always @(*) begin
  y_offset = i_vpos - 1;
  x_offset = i_hpos - 28;
  in_sprite = (x_offset < 4) && (y_offset < 7);
  
  segment[0] = y_offset == 0 && (num == 0 || num == 2 || num == 3 || num == 5 || num == 6 || num == 7 || num == 8 || num == 9);
  segment[1] = y_offset < 3 && x_offset == 0 && (num == 0 || num == 4 || num == 5 || num == 6 || num == 8 || num == 9);
  segment[2] = y_offset < 3 && x_offset == 3 && (num == 0 || num == 1 || num == 2 || num == 3 || num == 4 || num == 7|| num == 8 || num == 9);
  segment[3] = y_offset == 3 && (num == 2 || num == 3 || num == 4 || num == 5 || num == 6 || num == 8 || num == 9);
  segment[4] = y_offset > 3  && x_offset == 0 && (num == 0 || num == 2 || num == 6 || num == 8);
  segment[5] = y_offset > 3 && x_offset == 3 && (num == 0 || num == 1 || num == 3 || num == 4 || num == 5 || num == 6 || num == 7 || num == 8 || num == 9);
  segment[6] = y_offset == 6 && (num == 0 || num == 2 || num == 3 || num == 5|| num == 6 || num == 8);
end 

always @(*) begin
  o_score_color = |segment && in_sprite;
  //o_score_color = 1;
end

endmodule



