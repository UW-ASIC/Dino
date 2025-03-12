`default_nettype none

module player_controller (
  input wire clk,
  input wire rst_n,
  input wire [1:0] game_tick,
  input wire button_start,
  input wire button_up,
  input wire button_down,
  input wire crash,
  output wire [5:0] player_position,
  output wire game_frozen,
  output wire game_start_pulse,
  output wire game_over_pulse,
  output wire jump_pulse,
  output reg [2:0] game_state
);

  localparam RESTART   = 3'b000;
  localparam JUMPING   = 3'b001;
  localparam RUNNING1  = 3'b010;
  localparam RUNNING2  = 3'b011;
  localparam DUCKING   = 3'b100;
  localparam GAME_OVER = 3'b101;

  wire running;
  wire jump_done;
  wire physics_rst_n;
  wire game_over;

  always @(posedge(clk)) begin
    if (!rst_n) begin
      game_state <= RESTART;
    end else begin
      case (game_state)
        RESTART: begin
          if      (game_tick[0] &&  button_start) game_state <= JUMPING;
          else                                    game_state <= RESTART;
        end
        JUMPING: begin
          if      (crash                        ) game_state <= GAME_OVER;
          else if (game_tick[1] &&  jump_done   ) game_state <= RUNNING1;
          else                                    game_state <= JUMPING;
        end
        RUNNING1: begin
          if      (crash                        ) game_state <= GAME_OVER;
          else if (game_tick[0] &&  button_down ) game_state <= DUCKING;
          else if (game_tick[0] &&  button_up   ) game_state <= JUMPING;
          else if (game_tick[0]                 ) game_state <= RUNNING2;
          else                                    game_state <= RUNNING1;
        end
        RUNNING2: begin
          if      (crash                        ) game_state <= GAME_OVER;
          else if (game_tick[0] &&  button_down ) game_state <= DUCKING;
          else if (game_tick[0] &&  button_up   ) game_state <= JUMPING;
          else if (game_tick[0]                 ) game_state <= RUNNING1;
          else                                    game_state <= RUNNING2;
        end
        DUCKING: begin
          if      (crash                        ) game_state <= GAME_OVER;
          else if (game_tick[0] && !button_down ) game_state <= RUNNING1;
          else                                    game_state <= DUCKING;
        end
        GAME_OVER: begin
          if      (game_tick[0] &&  button_start) game_state <= RUNNING1;
          else                                    game_state <= GAME_OVER;
        end
        default: game_state <= RESTART;
      endcase
    end
  end

  assign physics_rst_n = rst_n && !(game_state == GAME_OVER && game_tick[0] && button_start);
  assign game_over = (game_state == GAME_OVER);

  player_physics u_player_physics (
    .clk(clk),
    .rst_n(physics_rst_n),
    .game_tick(game_tick),
    .game_over(game_over),
    .jump_pulse(jump_pulse),
    .button_down(button_down),
    .jump_done(jump_done),
    .position(player_position)
  );

  assign running = (game_state == RUNNING1 || game_state == RUNNING2);

  assign game_frozen      = (game_state == RESTART || game_state == GAME_OVER);
  assign game_start_pulse = (game_frozen             && game_tick[0] && button_start);
  assign game_over_pulse  = (game_state != GAME_OVER && game_tick[0] && crash    );
  assign jump_pulse       = (running                 && game_tick[0] && button_up);


endmodule
