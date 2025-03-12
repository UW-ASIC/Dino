module button_debounce( 
  input wire clk,
  input wire rst_n,
  input wire countdown_en,
  input wire button_in,
  output wire button_out
);

  reg [3:0] counter;

  always @(posedge clk) begin
      if      (~rst_n)                       counter <= 0;
      else if (button_in)                    counter <= 15;
      else if (countdown_en && counter != 0) counter <= counter - 1;
  end

  assign button_out = (counter != 0);
    
endmodule
