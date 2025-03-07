module jump_sound_player (
    input wire clk,             // 50 MHz clock
    input wire rst_n,          // Enable this module
    input wire sound_trigger,   // One-shot pulse signal to generate sound
    output reg wave_out         // Square wave output (registered)
);

    localparam [18:0] PWM_ARR_PERIOD = 19'd333333;

    // Decay stages
    localparam [18:0] DECAY_0   = 19'd166666;
    localparam [18:0] DECAY_1  = 19'd140522;
    localparam [18:0] DECAY_2  = 19'd118300;
    localparam [18:0] DECAY_3  = 19'd99999;
    localparam [18:0] DECAY_4  = 19'd84313;
    localparam [18:0] DECAY_5  = 19'd71241;
    localparam [18:0] DECAY_6  = 19'd60130;
    localparam [18:0] DECAY_7  = 19'd50326;
    localparam [18:0] DECAY_8  = 19'd42483;
    localparam [18:0] DECAY_9  = 19'd35947;
    localparam [18:0] DECAY_10 = 19'd30065;
    localparam [18:0] DECAY_11 = 19'd25490;
    localparam [18:0] DECAY_12 = 19'd21568;
    localparam [18:0] DECAY_13 = 19'd18300;
    localparam [18:0] DECAY_14 = 19'd15032;
    localparam [18:0] DECAY_15 = 19'd13071;
    localparam [18:0] DECAY_16 = 19'd10457;
    localparam [18:0] DECAY_17 = 19'd9150;
    localparam [18:0] DECAY_18 = 19'd7843;
    localparam [18:0] DECAY_19 = 19'd6535;
    localparam [18:0] DECAY_20 = 19'd5228;
    localparam [18:0] DECAY_21 = 19'd4575;
    localparam [18:0] DECAY_22 = 19'd3921;
    localparam [18:0] DECAY_23 = 19'd3267;
    localparam [18:0] DECAY_24 = 19'd2614;
    localparam [18:0] DECAY_25 = 19'd1960;
    localparam [18:0] DECAY_26 = 19'd1960;
    localparam [18:0] DECAY_27 = 19'd1307;
    localparam [18:0] DECAY_28 = 19'd1307;
    localparam [18:0] DECAY_29 = 19'd25;
    localparam [18:0] DECAY_30 = 19'd25;

    // State machine states
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        PLAY  = 2'b01,
        DONE  = 2'b10
    } state_t;

    state_t state = IDLE;
    state_t next_state = IDLE;
    
    reg [4:0]  stage_index = 0;  // Decay stage index
    reg [18:0] counter     = 0;  // PWM period counter
    reg        active      = 0;  // Active flag
    reg [18:0] decay_value;

    // State Register
    always @(posedge clk) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always@(*) begin
        case (state)
            IDLE: begin
                if (active)
                    next_state = PLAY;
                else
                    next_state = IDLE;
            end

            PLAY: begin
                if (stage_index== 30 )
                    next_state = DONE;
                else
                    next_state = PLAY;
            end

            DONE: begin
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // State Machine
    always @(posedge clk) begin
        if (!rst_n) begin
            active      <= 0;
            stage_index <= 0;
            wave_out    <= 0;
            wave_out    <= 0;
        end else if (sound_trigger) begin
            active      <= 1;
            counter     <= 0;
            stage_index <= 0;
            wave_out    <= 0;
        end else begin
            case (state)
                IDLE: begin
                    stage_index <= 0;
                    counter     <= 0;
                    wave_out    <= 0;
                end
                
                PLAY: begin
                    if (counter >= decay_value) begin
                        wave_out <= 0;  // Toggle waveform
                    end

                    if (counter >= PWM_ARR_PERIOD) begin  // Once we complete a full cycle
                            wave_out    <= 1;
                            counter     <= 0;
                            stage_index <= stage_index + 1;
                    end
                    else begin
                        counter <= counter + 1;
                    end

                    case (stage_index)
                        5'd0:  decay_value <= DECAY_0;
                        5'd1:  decay_value <= DECAY_1;
                        5'd2:  decay_value <= DECAY_2;
                        5'd3:  decay_value <= DECAY_3;
                        5'd4:  decay_value <= DECAY_4;
                        5'd5:  decay_value <= DECAY_5;
                        5'd6:  decay_value <= DECAY_6;
                        5'd7:  decay_value <= DECAY_7;
                        5'd8:  decay_value <= DECAY_8;
                        5'd9:  decay_value <= DECAY_9;
                        5'd10: decay_value <= DECAY_10;
                        5'd11: decay_value <= DECAY_11;
                        5'd12: decay_value <= DECAY_12;
                        5'd13: decay_value <= DECAY_13;
                        5'd14: decay_value <= DECAY_14;
                        5'd15: decay_value <= DECAY_15;
                        5'd16: decay_value <= DECAY_16;
                        5'd17: decay_value <= DECAY_17;
                        5'd18: decay_value <= DECAY_18;
                        5'd19: decay_value <= DECAY_19;
                        5'd20: decay_value <= DECAY_20;
                        5'd21: decay_value <= DECAY_21;
                        5'd22: decay_value <= DECAY_22;
                        5'd23: decay_value <= DECAY_23;
                        5'd24: decay_value <= DECAY_24;
                        5'd25: decay_value <= DECAY_25;
                        5'd26: decay_value <= DECAY_26;
                        5'd27: decay_value <= DECAY_27;
                        5'd28: decay_value <= DECAY_28;
                        5'd29: decay_value <= DECAY_29;
                        5'd30: decay_value <= DECAY_30;
                        default: decay_value <= 19'd25;
                    endcase
                end
                
                DONE: begin
                    wave_out <= 0;
                    active   <= 0;
                end
                
                default: begin
                    active <= 0;
                    counter     <= 0;
                    stage_index <= 0;
                    wave_out <= 0;
                end
            endcase
        end
    end
endmodule
