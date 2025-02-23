/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none 
 
module tt_um_uwasic_dinogame (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:8] uio_in,   // IOs: Input path
    output wire [7:8] uio_out,  // IOs: Output path
    output wire [7:8] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // All output pins must be assigned. If not used, assign to 0.
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

    // VGA signals
    wire hsync;
    wire vsync;
    wire [1:0] R;
    wire [1:0] G;
    wire [1:0] B;
  
    // graphics/rendering signals
    wire [9:CONV] hpos;
    wire [9:CONV] vpos;
    wire color_dino;
    wire color_obs;
    wire obs_color;
    wire dino_color;
    wire score_color;
    wire [5:0] dino_rom_counter;
    wire [2:0] obs_rom_counter;
    wire [3:0] score_rom_address;
    wire [9:0] score_rom_output;
 
    dino_rom dino_rom_inst (.clk(clk), .rst(~rst_n), .i_rom_counter(dino_rom_counter), .o_sprite_color(dino_color));
    obs_rom obs_rom_inst (.clk(clk), .rst(~rst_n), .i_rom_counter(obs_rom_counter), .o_sprite_color(obs_color));
    score_rom score_rom_inst (.clk(clk), .rst(~rst_n), .address(score_rom_address), .data(score_rom_output));
  
    score_render #(.CONV(CONV)) score_inst (.clk(clk), .rst(~rst_n), .num(), .i_hpos(hpos), .i_vpos(vpos), .o_score_color(score_color));
    dino_render #(.CONV(CONV)) dino_inst  (.clk(clk), .rst(~rst_n), .i_hpos(hpos), .i_vpos(vpos), .o_color_dino(color_dino), .o_rom_counter(dino_rom_counter), .i_sprite_color(dino_color));
    obs_render #(.CONV(CONV)) obs_inst  (.clk(clk), .rst(~rst_n), .i_hpos(hpos), .i_vpos(vpos), .o_color_obs(color_obs), .o_rom_counter(obs_rom_counter), .i_sprite_color(obs_color));
  
    graphics_top #(.CONV(CONV)) graphics_inst  (.clk(clk), .reset(~rst_n), .o_hsync(hsync), .o_vsync(vsync), 
    .o_blue(B), .o_green(G), .o_red(R), 
    .i_color_background(1'b0), .i_color_obstacle(color_obs),
    .i_color_player(color_dino), .i_color_score(score_color),
    .o_hpos(hpos), .o_vpos(vpos));
  
    // TinyVGA PMOD
    assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

endmodule
