`default_nettype none

module score_render #(parameter CONV = 0, parameter OFFSET = 0) (
  input  wire       clk,     
  input  wire       rst, 
  input wire [3:0] num,
  input wire [9:CONV] i_hpos,
  input wire [9:CONV] i_vpos,
  output reg  o_score_color
);

reg [9:CONV] y_offset;
reg [9:CONV] x_offset;
reg [9:CONV] y_offset_r;
reg [9:CONV] x_offset_r;
reg [3:0] num_r;
reg in_sprite;
reg [6:0] segment;
always @(posedge clk) begin
  if (rst) begin
    x_offset_r <= {(9-CONV+1){1'b0}};
    y_offset_r <= {(9-CONV+1){1'b0}};
    num_r <= 4'd0;
  end else begin
    num_r <= num;
    x_offset_r <= x_offset;
    y_offset_r <= y_offset;
  end
end

always @(*) begin
  y_offset = i_vpos - 1;
  x_offset = i_hpos - OFFSET;

  in_sprite = (x_offset_r < 4) && (y_offset_r < 7);
  
  segment[0] = y_offset_r == 0 && (num_r == 0 || num_r == 2 || num_r == 3 || num_r == 5 || num_r == 6 || num_r == 7 || num_r == 8 || num_r == 9);
  segment[1] = y_offset_r < 3 && x_offset_r == 0 && (num_r == 0 || num_r == 4 || num_r == 5 || num_r == 6 || num_r == 8 || num_r == 9);
  segment[2] = y_offset_r < 3 && x_offset_r == 3 && (num_r == 0 || num_r == 1 || num_r == 2 || num_r == 3 || num_r == 4 || num_r == 7|| num_r == 8 || num_r == 9);
  segment[3] = y_offset_r == 3 && (num_r == 2 || num_r == 3 || num_r == 4 || num_r == 5 || num_r == 6 || num_r == 8 || num_r == 9);
  segment[4] = y_offset_r > 3  && x_offset_r == 0 && (num_r == 0 || num_r == 2 || num_r == 6 || num_r == 8);
  segment[5] = y_offset_r > 3 && x_offset_r == 3 && (num_r == 0 || num_r == 1 || num_r == 3 || num_r == 4 || num_r == 5 || num_r == 6 || num_r == 7 || num_r == 8 || num_r == 9);
  segment[6] = y_offset_r == 6 && (num_r == 0 || num_r == 2 || num_r == 3 || num_r == 5 || num_r == 6 || num_r == 8);
end 

always @(*) begin
  o_score_color = |segment && in_sprite;
end

endmodule



