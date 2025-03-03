/*
 * Copyright (c) 2025 UW ASIC
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none 
 
module tt_um_uwasic_dinogame #(parameter CONV = 2) (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire       game_tick_60hz;
    wire [1:0] game_tick_20hz; // two consecutive pulses generated ([0] and then [1]), enabling pipelining

    wire debounce_countdown_en; // pulse on rising edge of 5th vpos bit
    wire button_up; 
    wire button_down; 

    // button_debounce button_up_debounce (
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .countdown_en(debounce_countdown_en),
    //     .button_in(ui_in[0]),
    //     .button_out(button_up)
    // );
    
    // button_debounce button_down_debounce (
    //   .clk(clk),
    //   .rst_n(rst_n),
    //   .countdown_en(debounce_countdown_en),
    //   .button_in(ui_in[1]),
    //   .button_out(button_down)
    // );

    // GAME STATE SIGNALS
    wire crash; // set to 1'b1 by rendering when collision occurs
    wire [5:0] player_position;
    wire game_start_pulse;
    wire game_over_pulse;
    wire game_frozen;
    wire jump_pulse;
    wire [2:0] game_state;

    wire [9:CONV] obstacle1_pos /* verilator public */;
    wire [9:CONV] obstacle2_pos /* verilator public */;
    wire [2:0] obstacle1_type;
    wire [2:0] obstacle2_type;

    wire [7:0] rng;

    lfsr #(.NUM_BITS(8)) lfsr_inst (
        .clk(clk),
        .enable(ena),
        .lfsr_data(rng)
    );

    player_controller player_constroller_inst (
        .clk(clk),
        .rst_n(rst_n),
        .game_tick(game_tick_20hz),
        .button_start(button_up),
        .button_up(button_up),
        .button_down(button_down),
        .crash(crash),
        .player_position(player_position),
        .game_frozen(game_frozen),
        .game_start_pulse(game_start_pulse),
        .game_over_pulse(game_over_pulse),
        .jump_pulse(jump_pulse),
        .game_state(game_state)
    );

    obstacles #(.GEN_LINE(70), .CONV(CONV)) obstacles_inst (
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
    wire color_obs_1;
    wire color_obs_2;
    wire obs_color_1;
    wire obs_color_2;
    wire dino_color;
    wire score_color_1;
    wire score_color_2;
    wire score_color_3;
    wire score_color_4;
    wire [5:0] dino_rom_counter;
    wire [7:0] obs_rom_counter_1;
    wire [7:0] obs_rom_counter_2;
 
    dino_rom dino_rom_inst (.clk(clk), .rst(~rst_n), .i_rom_counter(dino_rom_counter), .i_player_state(game_state), .o_sprite_color(dino_color));
    obs_rom obs_rom_inst_1 (.clk(clk), .rst(~rst_n), .i_rom_counter(obs_rom_counter_1), .i_obs_type(obstacle1_type), .o_sprite_color(obs_color_1));
    obs_rom obs_rom_inst_2 (.clk(clk), .rst(~rst_n), .i_rom_counter(obs_rom_counter_2), .i_obs_type(obstacle2_type), .o_sprite_color(obs_color_2));
  
    wire [15:0] score;

    score_render #(.CONV(CONV), .OFFSET(120)) score_inst_1 (
        .clk(clk),
        .rst(~rst_n),
        .num(score[3:0]),
        .i_hpos(hpos),
        .i_vpos(vpos),
        .o_score_color(score_color_1)
    );

    score_render #(.CONV(CONV), .OFFSET(110)) score_inst_2 (
        .clk(clk),
        .rst(~rst_n),
        .num(score[7:4]),
        .i_hpos(hpos),
        .i_vpos(vpos),
        .o_score_color(score_color_2)
    );

    score_render #(.CONV(CONV), .OFFSET(100)) score_inst_3 (
        .clk(clk),
        .rst(~rst_n),
        .num(score[11:8]),
        .i_hpos(hpos),
        .i_vpos(vpos),
        .o_score_color(score_color_3)
    );

    score_render #(.CONV(CONV), .OFFSET(90)) score_inst_4 (
        .clk(clk),
        .rst(~rst_n),
        .num(score[15:12]),
        .i_hpos(hpos),
        .i_vpos(vpos),
        .o_score_color(score_color_4)
    );

    dino_render #(.CONV(CONV)) dino_inst  (
        .clk(clk),
        .rst(~rst_n),
        .i_hpos(hpos),
        .i_vpos(vpos),
        .o_color_dino(color_dino),
        .o_rom_counter(dino_rom_counter),
        .i_sprite_color(dino_color),
        .i_ypos(player_position)
    );
    obs_render #(.CONV(CONV)) obs_inst_1  (
        .clk(clk),
        .rst(~rst_n),
        .i_hpos(hpos),
        .i_vpos(vpos),
        .o_color_obs(color_obs_1),
        .o_rom_counter(obs_rom_counter_1),
        .i_sprite_color(obs_color_1),
        .i_xpos(obstacle1_pos)
    );

    obs_render #(.CONV(CONV)) obs_inst_2  (
        .clk(clk),
        .rst(~rst_n),
        .i_hpos(hpos),
        .i_vpos(vpos),
        .o_color_obs(color_obs_2),
        .o_rom_counter(obs_rom_counter_2),
        .i_sprite_color(obs_color_2),
        .i_xpos(obstacle2_pos)
    );
  
    graphics_top #(.CONV(CONV)) graphics_inst  (
        .clk(clk),
        .rst(~rst_n),
        .o_hsync(hsync),
        .o_vsync(vsync), 
        .o_blue(B),
        .o_green(G),
        .o_red(R), 
        .i_color_background(1'b0),
        .i_color_obstacle(color_obs_1 | color_obs_2),
        .i_color_player(color_dino),
        .i_color_score(score_color_1 | score_color_2 | score_color_3 | score_color_4),
        .o_hpos(hpos),
        .o_vpos(vpos),
        .o_game_tick_60hz(game_tick_60hz),
        .o_game_tick_20hz(game_tick_20hz[0]),
        .o_game_tick_20hz_r(game_tick_20hz[1]),
        .o_vpos_5_r(debounce_countdown_en),
        .o_collision(crash)
    );

    ScoreModule score_module_inst (
        .game_start(game_start_pulse),     
        .game_frozen(game_frozen),      
        .game_tick(game_tick_60hz),     
        .clk(clk),            // clock
        .rst_n(rst_n),          // reset_n - low to reset
        .score(score)    
    );

    audio_interface audio_inst (
        .clk(clk),
        .rst_n(rst_n),
        .game_is_over(game_over_pulse),
        .jump_pulse(jump_pulse),
        .sound(uio_out[7])
    );

// input clk,
//   input rst_n,
//   input [9:CONV] obstacle1_pos,
//   input [9:CONV] obstacle2_pos,
//   input crash,
//   output reg button_up,
//   output reg crash_out

    ai_controller #(.CONV(CONV)) ai_controller_inst(
        .clk(clk),
        .rst_n(rst_n),
        .obstacle1_pos(obstacle1_pos),
        .obstacle2_pos(obstacle2_pos),
        .crash(crash),
        .button_up(button_up),
        .crash_out(crash_out)
    );
  
    // TinyVGA PMOD
    assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    // All output pins must be assigned. If not used, assign to 0.
    assign uio_out[6:0] = 0;
    assign uio_oe  = 8'b10000000;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, ui_in[7:2], uio_in, 1'b0, crash_out};
    wire crash_out;

endmodule
