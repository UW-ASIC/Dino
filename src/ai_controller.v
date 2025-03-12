`default_nettype none

module ai_controller
    #(    parameter CONV = 0, parameter GEN_LINE = 250, parameter PLAYER_OFFSET = 6, parameter OBSTACLE_TRESHOLD = 30 )
(
  input clk,
  input rst_n,
  input [9:CONV] obstacle1_pos,
  input [9:CONV] obstacle2_pos,
  input crash,
  output reg button_up,
  output reg crash_out
);

localparam RESTART_DELAY = 60; // Clock cycles to wait after crash to restart

// reg [9:CONV] obstacle_threshold; // When an obstacle reaches this xpos, set button_up signal
reg [7:0] restart_counter; 

always @(posedge clk) begin
  if (!rst_n) begin
    button_up <= 1'b0;
    crash_out <= 1'b0;
    restart_counter <= 'b0;
  end else begin
    if (crash_out) begin
      restart_counter <= restart_counter + 1;
      if (restart_counter == RESTART_DELAY) begin
        crash_out <= 1'b0;
        button_up <= 1'b1;
        restart_counter <= 'b0;
      end
    end else if (crash) begin
      crash_out <= 1'b1;
    end else begin
      if ((obstacle1_pos <= OBSTACLE_TRESHOLD && obstacle1_pos > PLAYER_OFFSET) || (obstacle2_pos <= OBSTACLE_TRESHOLD && obstacle2_pos > PLAYER_OFFSET)) begin
        button_up <= 1'b1;
      end else begin
        button_up <= 1'b0;
      end
    end
  end
end



endmodule
