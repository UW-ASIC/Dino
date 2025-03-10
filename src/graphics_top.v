`default_nettype none

module graphics_top #(parameter CONV = 0)(
  input wire clk,
  input wire rst,
  output reg o_hsync,
  output reg o_vsync,
  output reg [1:0] o_blue,
  output reg [1:0] o_red,
  output reg [1:0] o_green,
  output reg [9:CONV] o_hpos,
  output reg [9:CONV] o_vpos,
  input wire i_color_obstacle,
  input wire i_color_player,
  input wire i_color_background,
  input wire i_color_score,
  input wire i_game_start_pulse,

  output reg o_game_tick_60hz,
  output reg o_game_tick_20hz,
  output reg o_game_tick_20hz_r,
  output reg o_collision
);
    // ============== HVSYNC =============
    // TODO can change hpos to increment by 2 to reduce bits
    reg [9:0] hpos;
    reg [9:0] vpos;
    reg display_on;
    // TODO can remove this pipeline stage if we don't need it
    reg hsync;
    reg vsync;
    reg hsync_r;
    reg vsync_r;
    reg hsync_r_r;
    reg vsync_r_r;
    reg display_on_r;
    reg display_on_r_r;

    // TODO create custom hsync
    hvsync_generator hvsync_gen (
        .clk(clk),
        .reset(rst),
        .hsync(hsync),
        .vsync(vsync), 
        .vpos(vpos),
        .hpos(hpos),
        .display_on(display_on)
    ); 


    always @(posedge clk) begin
        if (rst) begin
            hsync_r <= 1'b0;
            vsync_r <= 1'b0;
            vsync_r_r <= 1'b0;
            hsync_r_r <= 1'b0;
            display_on_r <= 1'b0;
            display_on_r_r <= 1'b0;
        end else begin
            vsync_r <= vsync;
            hsync_r <= hsync;
            vsync_r_r <= vsync_r;
            hsync_r_r <= hsync_r;
            display_on_r <= display_on;
            display_on_r_r <= display_on_r;
        end
    end

    always @(*) begin
       o_hsync = hsync_r_r;
       o_vsync = vsync_r_r;
    end

    always @(*) begin
      o_hpos = hpos[9:CONV];
      o_vpos = vpos[9:CONV];
    end

    // ============== COMPARE =============
    reg is_colored;
    reg is_colored_r;
    always @(*) begin
        is_colored = i_color_obstacle ||
                     i_color_player ||
                     i_color_background ||
                     i_color_score;
    end
    always @(posedge clk) begin
        if (rst) begin
          is_colored_r <= 0;
        end else begin
          is_colored_r <= is_colored;
        end
    end
    
    // ============ GENERATE RGB / TRANSFORM ============
    // TODO stage can be merged with "CONVOLUTION" stage
    always @(*) begin
        o_blue = 2'b00;
        o_red  = 2'b00;
        o_green = 2'b00;

        // DEBUG remove after
        if (~display_on_r_r) begin
          o_blue = 2'b00;
          o_red = 2'b00;
          o_green = 2'b00;
        end else if (is_colored_r) begin
            o_blue = 2'b11;
            o_red = 2'b11;
            o_green = 2'b11;
        end 
        
    end
    
    // ============ Other outputs ============
    // TODO probably can merge game_tick_r logic with frame_counter
    reg [1:0] frame_counter;
    reg game_tick_r;
    reg collision;

    always @(*) begin
        o_game_tick_60hz = (vpos == 0) && (hpos == 0);
        o_game_tick_20hz = frame_counter == 1 && o_game_tick_60hz;
        o_game_tick_20hz_r = game_tick_r;
        o_collision = collision;
    end

    always @(posedge clk) begin
        if (rst) begin
            frame_counter <= 0; 
            game_tick_r <= 0;
            collision <= 0;
        end else begin
            if (o_game_tick_60hz) begin
                frame_counter <= frame_counter + 1; 
                if (frame_counter == 2) begin
                    frame_counter <= 0;
                end
            end
            game_tick_r <= o_game_tick_20hz;
            if (i_game_start_pulse) begin
                collision <= 1'b0;
            end else if (i_color_obstacle && i_color_player && display_on_r) begin
                collision <= 1'b1;
            end
        end
    end

endmodule

