/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none 
 
module tt_um_uwasic_dinogame (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // All output pins must be assigned. If not used, assign to 0.
    assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
    assign uio_out = 0;
    assign uio_oe  = 0;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, clk, rst_n, 1'b0};

    wire       game_tick_60hz;
    wire [1:0] game_tick_20hz; // two consecutive pulses generated ([0] and then [1]), enabling pipelining

    wire debounce_count_en; // pulse on rising edge of 5th vpos bit
    wire button_up;
    wire button_down;

    button_debounce button_up_debounce (
        .clk(clk),
        .rst_n(rst_n),
        .countdown_en(debounce_countdown_en),
        .button_in(ui_in[0]),
        .button_out(button_up)
    );

    button_debounce button_down_debounce (
      .clk(clk),
      .rst_n(rst_n),
      .countdown_en(debounce_countdown_en),
      .button_in(ui_in[1]),
      .button_out(button_down)
    );

    // GAME STATE SIGNALS
    wire crash; // set to 1'b1 by rendering when collision occurs
    wire [5:0] player_position;
    wire game_start_pulse;
    wire game_over_pulse;
    wire jump_pulse;
    wire jumping;
    wire ducking;

    wire [8:0] obstacle1_pos;
    wire [8:0] obstacle2_pos;
    wire [2:0] obstacle1_type;
    wire [2:0] obstacle2_type;
    wire [7:0] rng;

    player_controller player_constroller_inst (
        .clk(clk),
        .rst_n(rst_n),
        .game_tick(game_tick_20hz),
        .button_up(button_up),
        .button_down(button_down),
        .crash(crash),
        .player_position(player_position),
        .game_start_pulse(game_start_pulse),
        .game_over_pulse(game_over_pulse),
        .jump_pulse(jump_pulse),
        .jumping(jumping),
        .ducking(ducking)
    );

    obstacles #(.GEN_LINE(250)) obstacles_inst (
        .clk(game_tick_60hz),
        .rst_n(rst_n),
        .rng(rng),
        .obstacle1_pos(obstacle1_pos),
        .obstacle2_pos(obstacle2_pos),
        .obstacle1_type(obstacle1_type),
        .obstacle2_type(obstacle2_type)
    );

endmodule
