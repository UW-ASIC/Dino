`default_nettype none

module player_controller (
  input clk,
  input rst_n,
  input [1:0] game_tick,
  input button_start,
  input button_up,
  input button_down,
  input crash,
  output [5:0] player_position /*verilator public*/,
  output game_start_pulse,
  output game_over_pulse,
  output jump_pulse,
  output reg [2:0] game_state /*verilator public*/
);


endmodule
