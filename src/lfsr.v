// See https://nandland.com/lfsr-linear-feedback-shift-register/
`default_nettype none

module lfsr
  #(    parameter NUM_BITS = 8)
(
  input wire clk,
  input wire enable,
  output [NUM_BITS-1:0] lfsr_data
);
  reg [NUM_BITS:1] r_lfsr = {NUM_BITS/2{2'b01}}; // 010101 ...
  wire r_xnor;

  // Create Feedback Polynomials.  Based on Application Note:
  // http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
  generate
    case (NUM_BITS)
      3: assign r_xnor = r_lfsr[3] ^~ r_lfsr[2];
      4: assign r_xnor = r_lfsr[4] ^~ r_lfsr[3];
      5: assign r_xnor = r_lfsr[5] ^~ r_lfsr[3];
      6: assign r_xnor = r_lfsr[6] ^~ r_lfsr[5];
      7: assign r_xnor = r_lfsr[7] ^~ r_lfsr[6];
      8: assign r_xnor = r_lfsr[8] ^~ r_lfsr[6] ^~ r_lfsr[5] ^~ r_lfsr[4];
      9: assign r_xnor = r_lfsr[9] ^~ r_lfsr[5];
      10: assign r_xnor = r_lfsr[10] ^~ r_lfsr[7];
      11: assign r_xnor = r_lfsr[11] ^~ r_lfsr[9];
      12: assign r_xnor = r_lfsr[12] ^~ r_lfsr[6] ^~ r_lfsr[4] ^~ r_lfsr[1];
      13: assign r_xnor = r_lfsr[13] ^~ r_lfsr[4] ^~ r_lfsr[3] ^~ r_lfsr[1];
      14: assign r_xnor = r_lfsr[14] ^~ r_lfsr[5] ^~ r_lfsr[3] ^~ r_lfsr[1];
      15: assign r_xnor = r_lfsr[15] ^~ r_lfsr[14];
      16: assign r_xnor = r_lfsr[16] ^~ r_lfsr[15] ^~ r_lfsr[13] ^~ r_lfsr[4];
    endcase // case (NUM_BITS)
  endgenerate

  always @(posedge clk) begin
    if (enable == 1'b1)
      r_lfsr <= {r_lfsr[NUM_BITS-1:1], r_xnor};
    else
      r_lfsr <= {NUM_BITS/2{2'b01}};
  end

  assign lfsr_data = r_lfsr[NUM_BITS:1];
endmodule

