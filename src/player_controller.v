`default_nettype none

module player_controller (
  input clk,
  input reset_n,
  input [1:0] game_tick,
  input button_up,
  input button_down,
  input crash,
  output reg [7:0] player_position,
  output reg game_start_pulse,
  output reg game_over_pulse,
  output reg jump_pulse,
  output reg jumping,
  output reg ducking,
);

  localparam RESTART    = 3'b000;
  localparam JUMPING    = 3'b001;
  localparam RUNNING    = 3'b010;
  localparam DUCKING    = 3'b011;
  localparam GAME_OVER  = 3'b100;

  wire jump_done;

  reg [2:0] game_state;

  always @(posedge(clk)) begin
    if (!reset_n) begin
      current_state <= RESTART;
    end else begin
      case (current_state)
        RESTART: begin
          else if (game_tick[0] &&  button_up  ) game_state <= JUMPING;
          else                                   game_state <= RESTART;
        end
        JUMPING: begin
          if      (game_tick[0] &&  crash      ) game_state <= GAME_OVER;
          else if (game_tick[1] &&  jump_done  ) game_state <= RUNNING;
          else                                   game_state <= JUMPING;
        end
        RUNNING: begin
          if      (game_tick[0] &&  crash      ) game_state <= GAME_OVER;
          else if (game_tick[0] &&  button_down) game_state <= DUCKING;
          else if (game_tick[0] &&  button_up  ) game_state <= JUMPING;
          else                                   game_state <= RUNNING;
        end
        DUCKING: begin
          if      (game_tick[0] &&  crash      ) game_state <= GAME_OVER;
          else if (game_tick[0] && !button_down) game_state <= RUNNING;
          else                                   game_state <= DUCKING;
        end
        GAME_OVER: begin
          if      (game_tick[0] &&  button_up  ) game_state <= RUNNING;
          else                                   game_state <= GAME_OVER;
        end
      endcase
    end
  end

  player_physics u_player_physics (
    .clk(clk),
    .reset_n(reset_n),
    .game_tick(game_tick),
    .jump_pulse(jump_pulse),
    .button_down(button_down),
    .jump_done(jump_done),
    .position(position),
  );

  assign game_start_pulse = (game_state == RESTART   && game_tick[0] && button_up);
  assign game_over_pulse  = (game_state != GAME_OVER && game_tick[0] && button_up);
  assign jump_pulse       = (game_state == RUNNING   && game_tick[0] && button_up);

  assign jumping = (game_state == RUNNING);
  assign ducking = (game_state == DUCKING);

endmodule
