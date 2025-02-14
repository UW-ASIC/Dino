`default_nettype none

module button_debounce( 
    input       clk,
    input       reset,
    input       countdown_en,
    input       button_in,
    output      button_out,  
);
    reg [3:0] cnt;

    always @ ( posedge clk ) begin
        if ( reset )                        cnt <= 0;
        else if ( button_in )               cnt <= 4'b1111;
        else if ( countdown_en && cnt != 0) cnt <= cnt - 1;
    end

    assign button_out = (cnt != 0);
    
endmodule