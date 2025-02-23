`default_nettype none

module score_rom (
  input  wire       clk,      // clock
  input  wire       rst, 
  input  wire [3:0] address,
  output reg [9:0] data
);

reg [9:0] rom [0:27];

always @(posedge clk or posedge rst) begin
  if (rst) begin
    rom[0]  <= 10'b1111111110; // 0
    rom[1]  <= 10'b0110000110; // 1
    rom[2]  <= 10'b1101101101; // 2
    rom[3]  <= 10'b1111001111; // 3
    rom[4]  <= 10'b0110011111; // 4
    rom[5]  <= 10'b1011011111; // 5
    rom[6]  <= 10'b1011111111; // 6
    rom[7]  <= 10'b1110000110; // 7
    rom[8]  <= 10'b1111111111; // 8
    rom[9]  <= 10'b1111011111; // 9
    rom[10] <= 10'b0000000000; // blank
    rom[11] <= 10'b0000000000; // blank
    rom[12] <= 10'b0000000000; // blank
    rom[13] <= 10'b0000000000; // blank
    rom[14] <= 10'b0000000000; // blank
    rom[15] <= 10'b0000000000; // blank
    rom[16] <= 10'b0000000000; // blank
    rom[17] <= 10'b0000000000; // blank
    rom[18] <= 10'b0000000000; // blank
    rom[19] <= 10'b0000000000; // blank
    rom[20] <= 10'b0000000000; // blank
    rom[21] <= 10'b0000000000; // blank
    rom[22] <= 10'b0000000000; // blank
    rom[23] <= 10'b0000000000; // blank
    rom[24] <= 10'b0000000000; // blank
    rom[25] <= 10'b0000000000; // blank
    rom[26] <= 10'b0000000000; // blank
    rom[27] <= 10'b0000000000; // blank
  end else begin
    data <= rom[address];
  end
end

endmodule
