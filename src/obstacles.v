module obstacles
  #(    parameter CONV = 0, parameter GEN_LINE = 250)
(
    input wire clk,
    input wire rst_n,
    input wire game_frozen,
    input wire game_start,
    input wire game_tick,
    input wire [7:0] rng,
    output reg [9:CONV] obstacle1_pos,
    output reg [9:CONV] obstacle2_pos,
    output reg [2:0] obstacle1_type,
    output reg [2:0] obstacle2_type
);
    reg obstacle1_cross_gen_line_reg;
    reg obstacle2_cross_gen_line_reg;
    always @(posedge clk) begin
        if (!rst_n || game_start) begin
            obstacle1_pos <= 0;
            obstacle2_pos <= 0;
            obstacle1_type <= 0;
            obstacle2_type <= 0;
            obstacle1_cross_gen_line_reg <= 0;
            obstacle2_cross_gen_line_reg <= 1;
        end else begin
          if (!game_frozen && game_tick) begin
                if (obstacle1_pos != 0) obstacle1_pos <= obstacle1_pos - 1;
                if (obstacle2_pos != 0) obstacle2_pos <= obstacle2_pos - 1;
                
                if (obstacle1_pos == GEN_LINE) obstacle1_cross_gen_line_reg <= 1;
                if (obstacle2_pos == GEN_LINE) obstacle2_cross_gen_line_reg <= 1;
                
                if (obstacle1_pos == 0 && obstacle2_cross_gen_line_reg) begin
                    obstacle1_pos <= {2'b10, {(3-CONV){1'b1}}, rng[4:0]};
                    obstacle1_type <= rng[7:5];
                    obstacle2_cross_gen_line_reg <= 0;
                end
                if (obstacle2_pos== 0 && obstacle1_cross_gen_line_reg) begin
                    obstacle2_pos <= {2'b10, {(3-CONV){1'b1}}, rng[4:0]};
                    obstacle2_type <= rng[7:5];
                    obstacle1_cross_gen_line_reg <= 0;
                end
            end
        end
    end
endmodule
