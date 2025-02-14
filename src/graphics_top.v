`default_nettype none

module graphics_top #(parameter CONV = 0)(
  input wire clk,
  input wire reset,
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
  input wire i_color_score

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
    // TODO might be able to set display_on to always be on / cordinated with
    // only vsync
    reg display_on_r;

    // TODO create custom hsync
    hvsync_generator hvsync_gen (.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync), 
                                    .vpos(vpos), .hpos(hpos), .display_on(display_on)); 


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            hsync_r <= 1'b0;
            vsync_r <= 1'b0;
            display_on_r <= 1'b0;
        end else begin
            vsync_r <= vsync;
            hsync_r <= hsync;
            display_on_r <= display_on;
        end
    end

    always @(*) begin
       o_hsync = hsync_r;
       o_vsync = vsync_r;
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
    always @(posedge clk or posedge reset) begin
        if (reset) begin
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
        if (~display_on_r) begin
          o_blue = 2'b00;
          o_red = 2'b11;
          o_green = 2'b10;
        end else if (is_colored_r) begin
            o_blue = 2'b11;
            o_red = 2'b11;
            o_green = 2'b11;
        end 
        
    end

endmodule

