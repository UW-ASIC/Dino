module bg_line #(parameter CONV = 0, parameter GND_LINE = 0) (
  // Graphics
  input wire [9:CONV] i_vpos,
  output reg o_color_bg   // Dedicated outputs
);


  always @(*) begin
    o_color_bg = 1'b0;
    // optimize this heavily for ROM
    if (i_vpos == GND_LINE) begin
      o_color_bg = 1'b1;
    end
  end
endmodule


