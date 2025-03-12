`default_nettype none

module ai_controller
    #(    parameter CONV = 0, parameter GEN_LINE = 250, parameter PLAYER_OFFSET = 6, parameter OBSTACLE_TRESHOLD = 40 )
(
  input wire clk,
  input wire rst_n,
  input wire game_tick,
  input wire gamepad_is_present,
  input wire gamepad_start,
  input wire gamepad_up,
  input wire gamepad_down,
  input wire [9:CONV] obstacle1_pos,
  input wire [9:CONV] obstacle2_pos,
  input wire crash,
  input wire game_frozen,
  output reg button_start,
  output reg button_up,
  output reg button_down
);

localparam RESTART_DELAY = 60; // Clock cycles to wait after crash to restart

// reg [9:CONV] obstacle_threshold; // When an obstacle reaches this xpos, set button_up signal
reg [7:0] restart_counter; 

always @(posedge clk) begin
  if (!rst_n) begin
    button_start <= 1'b0;
    button_up <= 1'b0;
    button_down <= 1'b0;
    restart_counter <= 8'b00000000;
  end else if (game_tick) begin
    if (gamepad_is_present) begin
      button_start <= gamepad_start;
      button_up <= gamepad_up;
      button_down <= gamepad_down;
    end else if (crash | game_frozen) begin
      restart_counter <= restart_counter + 1;
      if (restart_counter == RESTART_DELAY) begin
        button_start <= 1'b1;
        restart_counter <= 8'b00000000;
      end else begin
        button_start <= 1'b0;
      end
      button_up <= 1'b0;
      button_down <= 1'b0;
    end else if ((obstacle1_pos <= OBSTACLE_TRESHOLD && obstacle1_pos > PLAYER_OFFSET) || (obstacle2_pos <= OBSTACLE_TRESHOLD && obstacle2_pos > PLAYER_OFFSET)) begin
      button_up <= 1'b1;
    end else begin
      button_up <= 1'b0;
    end
  end
end



endmodule
