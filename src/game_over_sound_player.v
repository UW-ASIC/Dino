module game_over_sound_player (
    input wire clk,        // 50 MHz clock input
    input wire rst_n,      // reset on the negative edge
    input wire is_over,     // one period pulse to trigger the game over sound
    output reg wave_out    // Jump sound square wave output
);

    localparam [18:0] PERIOD = 19'd200000;   // Clock speed / Frequency -> 50MHz / 660Hz 

    // Distinct localparams for decay values
    localparam [18:0] DECAY_0  = 37878;
    localparam [18:0] DECAY_1  = 33842;
    localparam [18:0] DECAY_2  = 30208;
    localparam [18:0] DECAY_3  = 26940;
    localparam [18:0] DECAY_4  = 24008;
    localparam [18:0] DECAY_5  = 21383;
    localparam [18:0] DECAY_6  = 19043;
    localparam [18:0] DECAY_7  = 16966;
    localparam [18:0] DECAY_8  = 15135;
    localparam [18:0] DECAY_9  = 13530;
    localparam [18:0] DECAY_10 = 12132;
    localparam [18:0] DECAY_11 = 10924;
    localparam [18:0] DECAY_12 = 9879;
    localparam [18:0] DECAY_13 = 8932;
    localparam [18:0] DECAY_14 = 8076;
    localparam [18:0] DECAY_15 = 7300;

    localparam [1:0] IDLE  = 2'b00,
                    PLAY1 = 2'b01,
                    PLAY2 = 2'b10,
                    DONE  = 2'b11;

    reg [1:0] state = IDLE;
    reg [1:0] next_state = IDLE;

    reg [4:0] stage_index = 0;   // 16 stages of decay values
    reg [18:0] counter = 0;   // 19-bit counter for a maximum period of 333333
    reg active;
    reg [18:0] decay_value;

    always@(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always@(*) begin
        case (state)
            IDLE: begin
                if (active)
                    next_state = PLAY1;
                else
                    next_state = IDLE;
            end

            PLAY1: begin
                if (stage_index == 15) begin
                    next_state = PLAY2;
                end else
                    next_state = PLAY1;
            end

            PLAY2: begin
                if (stage_index == 31)
                    next_state = DONE;
                else
                    next_state = PLAY2;
            end

            DONE: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk ) begin
        if (!rst_n) begin // Detect negative level of rst_n
            stage_index <= 0;
            counter <= 0;
            active <= 0;
            wave_out <= 0;
        end else if (is_over) begin // Detect rising edge of is_over
            active <= 1;
            stage_index <= 0;
            counter <= 0;
            wave_out <= 0;
        end else begin  // running state
            case(state)
                IDLE: begin
                    stage_index <= 0;
                    counter     <= 0;
                    wave_out    <= 0;
                end

                PLAY1: begin
                    if ( counter >= decay_value) begin
                        wave_out <= 0;  // Toggle waveform
                    end 

                    if (counter >= PERIOD) begin  // Once we complete a full cycle
                            wave_out    <= 1;
                            counter     <= 0;
                            stage_index <= stage_index + 1;
                    end else begin
                        counter <= counter + 1;
                    end

                    // Use the distinct localparams instead of array lookup
                    case (stage_index)
                        5'd0:  decay_value<= DECAY_0;
                        5'd1:  decay_value<= DECAY_1;
                        5'd2:  decay_value<= DECAY_2;
                        5'd3:  decay_value<= DECAY_3;
                        5'd4:  decay_value<= DECAY_4;
                        5'd5:  decay_value<= DECAY_5;
                        5'd6:  decay_value<= DECAY_6;
                        5'd7:  decay_value<= DECAY_7;
                        5'd8:  decay_value<= DECAY_8;
                        5'd9:  decay_value<= DECAY_9;
                        5'd10: decay_value <= DECAY_10;
                        5'd11: decay_value <= DECAY_11;
                        5'd12: decay_value <= DECAY_12;
                        5'd13: decay_value <= DECAY_13;
                        5'd14: decay_value <= DECAY_14;
                        5'd15: decay_value <= DECAY_15;
                        default: decay_value<= DECAY_0;
                    endcase
                end

                PLAY2: begin
                    if ( counter >= decay_value) begin
                        wave_out <= 0;  // Toggle waveform
                    end 

                    if (counter >= PERIOD) begin  // Once we complete a full cycle
                            wave_out    <= 1;
                            counter     <= 0;
                            stage_index <= stage_index + 1;
                    end else begin
                        counter <= counter + 1;
                    end

                    // Use the distinct localparams instead of array lookup
                    case (stage_index - 15)
                        5'd0:  decay_value<= DECAY_0;
                        5'd1:  decay_value<= DECAY_1;
                        5'd2:  decay_value<= DECAY_2;
                        5'd3:  decay_value<= DECAY_3;
                        5'd4:  decay_value<= DECAY_4;
                        5'd5:  decay_value<= DECAY_5;
                        5'd6:  decay_value<= DECAY_6;
                        5'd7:  decay_value<= DECAY_7;
                        5'd8:  decay_value<= DECAY_8;
                        5'd9:  decay_value<= DECAY_9;
                        5'd10: decay_value <= DECAY_10;
                        5'd11: decay_value <= DECAY_11;
                        5'd12: decay_value <= DECAY_12;
                        5'd13: decay_value <= DECAY_13;
                        5'd14: decay_value <= DECAY_14;
                        5'd15: decay_value <= DECAY_15;
                    endcase
                end

                DONE: begin
                    active <= 0;
                    wave_out <= 0;
                end

                default: begin
                    stage_index <= 0;
                    counter <= 0;
                    active <= 0;
                    wave_out <= 0;
                end
            endcase
        end
    end

endmodule
