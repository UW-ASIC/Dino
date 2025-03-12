/*
 * Copyright (c) 2025 UW ASIC
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module ScoreModule (
    input  wire              game_start,     // pulse for starting the counter
    input  wire              game_frozen,    // If the game is frozen
    input  wire              game_tick,      // 60 Hz. end of frame pulse
    input  wire              clk,            // clock
    input  wire              rst_n,          // reset_n - low to reset
    output wire [15:0]       score
);

  // Internal registers to help with keeping track of the score in decimal
  reg [3:0] score_int [3:0];

  // determine if game_active
  always @(posedge clk) begin
    if (!rst_n || game_start) begin
      score_int[0] <= 0;
      score_int[1] <= 0;
      score_int[2] <= 0;
      score_int[3] <= 0;
    end else begin
      
      if (!game_frozen && game_tick) begin
        if (score_int[0] == 9) begin
          if (score_int[1] == 9) begin
            if (score_int[2] == 9) begin
              if (score_int[3] == 9) begin
                // Reset the game if the score gets to 9999
                score_int[3] <= 0;
              end else begin
                score_int[3] <= score_int[3] + 1;
                score_int[2] <= 0;
              end
            end else begin
              score_int[2] <= score_int[2] + 1;
              score_int[1] <= 0;
            end
          end else begin
            score_int[1] <= score_int[1] + 1;
            score_int[0] <= 0;
          end
        end else begin
          score_int[0] <= score_int[0] + 1;
        end
      end
      
    end
  end
  
  assign score = {score_int[3], score_int[2], score_int[1], score_int[0]};

endmodule
