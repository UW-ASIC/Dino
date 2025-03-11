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
  output reg o_vpos_5_r,
  output reg o_collision
);
    // ============== HVSYNC =============
    // TODO can change hpos to increment by 2 to reduce bits
    reg [9:0] hpos;
    reg [9:0] vpos;
    reg vpos_5_r;
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
            vpos_5_r <= 1'b0;
            display_on_r <= 1'b0;
            display_on_r_r <= 1'b0;
        end else begin
            vsync_r <= vsync;
            hsync_r <= hsync;
            vsync_r_r <= vsync_r;
            hsync_r_r <= hsync_r;
            vpos_5_r <= vpos[5];
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
    priority_encoder_4_2 pe_4_2_inst (
        .I0(i_color_background),
        .I1(i_color_obstacle),
        .I2(i_color_player),
        .I3(i_color_score),
        .O0(O0),
        .O1(O1),
        .V(is_colored)
    );
    wire is_colored;
    wire O0;
    wire O1;
    reg is_colored_r;
    reg O0_r;
    reg O1_r;
    always @(posedge clk) begin
        if (rst) begin
            is_colored_r <= 0;
            O0_r <= 0;
            O1_r <= 0;
        end else begin
            is_colored_r <= is_colored;
            O0_r <= O0;
            O1_r <= O1;
        end
    end

    wire [1:0] R;
    wire [1:0] G;
    wire [1:0] B;
    color_decoder_2_6 color_decoder_inst (
        .is_colored(is_colored_r),
        .layer({O1_r, O0_r}),
        .rgb_scheme(1'b0),
        .invert(1'b0),
        .R(R),
        .G(G),
        .B(B)
    );

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
        end else begin
            o_blue = B;
            o_red = R;
            o_green = G;
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
        o_vpos_5_r = (vpos[5] == 1) && (vpos_5_r == 0);
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

