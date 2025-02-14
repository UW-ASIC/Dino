`default_nettype none

module button_debounce( 
  input  clk,
  input  reset,
  input  countdown_en,
  input  button_in,
  output button_out
);

  reg [3:0] counter;

  always @(posedge clk) begin
      if      (reset)                      counter <= 0;
      else if (button_in)                  counter <= 15;
      else if (countdown_en && count != 0) counter <= counter - 1;
  end

  assign button_out = (counter != 0);
    
endmodule
