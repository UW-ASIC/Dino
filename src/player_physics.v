`default_nettype none

module player_physics #(
  // determined from pygame example
  parameter INITIAL_JUMP_VELOCITY = -7,
  parameter DOWNWARD_ACCELERATION =  1,
  parameter FASTDROP_VELOCITY     =  6
) (
  input clk,
  input rst_n,
  input [1:0] game_tick,     // enable for the FF that stores result of velocity [0] and position [1]
  input game_over,           // collision has occured -- freeze dino
  input jump_pulse,          // high for one clock cycle at start of jump (set initial velocity)
  input button_down,         // high if down button is pressed
  output reg [5:0] position, // -21..4
  output wire jump_done      // not(msb of adder) -- only sampled when game_tick[1] == 1
);

  reg  [3:0] velocity; // -7..6
  wire [3:0] active_vel;
  wire [3:0] adder_in1;
  wire [5:0] adder_in2, adder_res; // -21..4

  // If player presses down, override velocity calculated by gravity with FASTDROP_VELOCITY
  assign active_vel = (button_down) ? FASTDROP_VELOCITY : velocity;

  // game_tick[1] == 0 means calculating velocity, game_tick[1] == 1 means calculating position
  assign adder_in1 = (game_tick[1]) ? active_vel : DOWNWARD_ACCELERATION;
  assign adder_in2 = (game_tick[1]) ? position : { {2{velocity[3]}}, velocity };
  assign adder_res = { {2{velocity[3]}}, adder_in1 } + adder_in2;

  always @ (posedge clk) begin
    if (!rst_n) begin
      velocity <= 0;
      position <= 0; // Replace with ground position
    end else if (!game_over) begin
      if (game_tick[0]) begin
        if      (button_down) velocity <= 0;
        else if (jump_pulse)  velocity <= INITIAL_JUMP_VELOCITY;
        else if (position[5]) velocity <= adder_res[3:0];
      end else if (game_tick[1]) begin
        if (~adder_res[5]) begin
          velocity <= 0;
          position <= 0;
        end else begin
          position <= adder_res;
        end
      end
    end
  end

  // Only sampled when game_tick[1] == 1, so jump_done == 1 when calculated position overflows
  assign jump_done = ~adder_res[5];

endmodule
