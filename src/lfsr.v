// See https://nandland.com/lfsr-linear-feedback-shift-register/
`default_nettype none

module lfsr
  #(    parameter NUM_BITS = 8)
(
  input wire clk,
  input wire enable,
  output wire [NUM_BITS-1:0] lfsr_data
);
  reg [NUM_BITS:1] r_lfsr = {NUM_BITS/2{2'b01}}; // 010101 ...
  wire r_xnor;

  // Create Feedback Polynomials.  Based on Application Note:
  // http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
  generate
    case (NUM_BITS)
      3: begin : gen_poly assign r_xnor = r_lfsr[3] ^~ r_lfsr[2]; end
      4: begin : gen_poly assign r_xnor = r_lfsr[4] ^~ r_lfsr[3]; end
      5: begin : gen_poly assign r_xnor = r_lfsr[5] ^~ r_lfsr[3]; end
      6: begin : gen_poly assign r_xnor = r_lfsr[6] ^~ r_lfsr[5]; end
      7: begin : gen_poly assign r_xnor = r_lfsr[7] ^~ r_lfsr[6]; end
      8: begin : gen_poly assign r_xnor = r_lfsr[8] ^~ r_lfsr[6] ^~ r_lfsr[5] ^~ r_lfsr[4]; end
      9: begin : gen_poly assign r_xnor = r_lfsr[9] ^~ r_lfsr[5]; end
      10: begin : gen_poly assign r_xnor = r_lfsr[10] ^~ r_lfsr[7]; end
      11: begin : gen_poly assign r_xnor = r_lfsr[11] ^~ r_lfsr[9]; end
      12: begin : gen_poly assign r_xnor = r_lfsr[12] ^~ r_lfsr[6] ^~ r_lfsr[4] ^~ r_lfsr[1]; end
      13: begin : gen_poly assign r_xnor = r_lfsr[13] ^~ r_lfsr[4] ^~ r_lfsr[3] ^~ r_lfsr[1]; end
      14: begin : gen_poly assign r_xnor = r_lfsr[14] ^~ r_lfsr[5] ^~ r_lfsr[3] ^~ r_lfsr[1]; end
      15: begin : gen_poly assign r_xnor = r_lfsr[15] ^~ r_lfsr[14]; end
      16: begin : gen_poly assign r_xnor = r_lfsr[16] ^~ r_lfsr[15] ^~ r_lfsr[13] ^~ r_lfsr[4]; end
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

