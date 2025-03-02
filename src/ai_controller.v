`default_nettype none

module ai_controller
    #(    parameter CONV = 0, parameter GEN_LINE = 250)
(
  input clk,
  input rst_n,
  input [1:0] game_tick,
  input wire [9:CONV] obstacle1_pos,
  input wire [9:CONV] obstacle2_pos,
  output button_up,
  input crash,
);



endmodule
