module bg_objects
  #(    parameter CONV = 0, parameter GEN_LINE = 250)
(
    input wire clk,
    input wire rst_n,
    input wire [7:0] rng,
    output reg [9:CONV] bg_object1_pos,
    output reg [9:CONV] bg_object2_pos
);
    reg bg_object1_cross_gen_line_reg;
    reg bg_object2_cross_gen_line_reg;
    always @(posedge clk) begin
        if (!rst_n) begin
            bg_object1_pos <= 0;
            bg_object2_pos <= 0;
            bg_object1_cross_gen_line_reg <= 0;
            bg_object2_cross_gen_line_reg <= 1;
        end else begin
            if (bg_object1_pos != 0) bg_object1_pos <= bg_object1_pos - 1;
            if (bg_object2_pos != 0) bg_object2_pos <= bg_object2_pos - 1;
            
            if (bg_object1_pos == GEN_LINE) bg_object1_cross_gen_line_reg <= 1;
            if (bg_object2_pos == GEN_LINE) bg_object2_cross_gen_line_reg <= 1;
            
            if (bg_object1_pos == 0 && bg_object2_cross_gen_line_reg) begin
                bg_object1_pos <= {1'b1, {(4-CONV){1'b1}}, rng[6:2]};
                bg_object2_cross_gen_line_reg <= 0;
            end
            if (bg_object2_pos == 0 && bg_object1_cross_gen_line_reg) begin
                bg_object2_pos <= {1'b1, {(4-CONV){1'b1}}, rng[6:2]};
                bg_object1_cross_gen_line_reg <= 0;
            end
        end
    end
endmodule