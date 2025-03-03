module bg_object
  #(    parameter CONV = 0)
(
    input wire clk,
    input wire rst_n,
    input wire [7:0] rng,
    output reg [9:CONV] bg_object_pos
);
    reg bg_object_cross_gen_line_reg;
    always @(posedge clk) begin
        if (!rst_n) begin
            bg_object_pos <= 0;
        end else begin
            if (bg_object_pos != 0) bg_object_pos <= bg_object_pos - 1;
            if (bg_object_pos == 0) begin
                bg_object_pos <= {{(5-CONV){1'b1}}, rng[6:2]};
            end
        end
    end
endmodule