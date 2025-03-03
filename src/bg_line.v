`default_nettype none

module bg_line #(parameter CONV = 0, parameter GND_LINE = 0) (
  input  wire       clk,      // clock
  input  wire       rst, 

  // Graphics
  input wire [9:CONV] i_hpos,
  input wire [9:CONV] i_vpos,
  output reg o_color_bg   // Dedicated outputs
);

  reg [9:CONV] y_offset;
  reg [9:CONV] x_offset;
  reg in_sprite;

  always @(*) begin
    o_color_bg = 1'b0;
    // optimize this heavily for ROM
    if (i_vpos == GND_LINE) begin
      o_color_bg = 1'b1;
    end
  end
endmodule


