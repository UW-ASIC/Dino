module obstacles
  #(    parameter GEN_LINE = 250)
(
    input wire clk,
    input wire rst_n,
    input wire [7:0] rng,
    output reg [8:0] obstacle1_pos,
    output reg [8:0] obstacle2_pos,
    output reg [2:0] obstacle1_type,
    output reg [2:0] obstacle2_type
);
    reg obstacle1_cross_gen_line_reg;
    reg obstacle2_cross_gen_line_reg;
    always @(posedge clk) begin
        if (!rst_n) begin
            obstacle1_pos <= 0;
            obstacle2_pos <= 0;
            obstacle1_type <= 0;
            obstacle2_type <= 0;
            obstacle1_cross_gen_line_reg <= 0;
            obstacle2_cross_gen_line_reg <= 1;
        end else begin
            if (obstacle1_pos != 0) obstacle1_pos <= obstacle1_pos - 1;
            if (obstacle2_pos != 0) obstacle2_pos <= obstacle2_pos - 1;
            
            if (obstacle1_pos == GEN_LINE) obstacle1_cross_gen_line_reg <= 1;
            if (obstacle2_pos == GEN_LINE) obstacle2_cross_gen_line_reg <= 1;
            
            if (obstacle1_pos == 0 && obstacle2_cross_gen_line_reg) begin
                obstacle1_pos <= {4'b1111, rng[4:0]};
                obstacle1_type <= rng[7:5];
                obstacle2_cross_gen_line_reg <= 0;
            end
            if (obstacle2_pos== 0 && obstacle1_cross_gen_line_reg) begin
                obstacle2_pos <= {4'b1111, rng[4:0]};
                obstacle2_type <= rng[7:5];
                obstacle1_cross_gen_line_reg <= 0;
            end
        end
    end
endmodule