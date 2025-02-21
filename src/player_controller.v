`default_nettype none

module player_controller (
  input clk,
  input rst_n,
  input [1:0] game_tick,
  input button_up,
  input button_down,
  input crash,
  output [5:0] player_position,
  output game_start_pulse,
  output game_over_pulse,
  output jump_pulse,
  output jumping,
  output ducking
);

  localparam RESTART   = 3'b000;
  localparam JUMPING   = 3'b001;
  localparam RUNNING   = 3'b010;
  localparam DUCKING   = 3'b011;
  localparam GAME_OVER = 3'b100;

  wire jump_done;

  reg [2:0] game_state;

  always @(posedge(clk)) begin
    if (!rst_n) begin
      game_state <= RESTART;
    end else begin
      case (game_state)
        RESTART: begin
          if      (game_tick[0] &&  button_up  ) game_state <= JUMPING;
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
        default: game_state <= RESTART;
      endcase
    end
  end

  player_physics u_player_physics (
    .clk(clk),
    .rst_n(rst_n),
    .game_tick(game_tick),
    .jump_pulse(jump_pulse),
    .button_down(button_down),
    .jump_done(jump_done),
    .position(player_position)
  );

  assign game_start_pulse = (game_state == RESTART   && game_tick[0] && button_up);
  assign game_over_pulse  = (game_state != GAME_OVER && game_tick[0] && button_up);
  assign jump_pulse       = (game_state == RUNNING   && game_tick[0] && button_up);

  assign jumping = (game_state == RUNNING);
  assign ducking = (game_state == DUCKING);

endmodule
