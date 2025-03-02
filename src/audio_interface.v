module audio_interface(
    input wire clk,
    input wire rst_n,
    input wire game_is_over,
    input wire jump_pulse,
    output reg sound
);
    wire jump_sound;
    wire game_over_sound;

    // Pipeline registers
    reg jump_sound_reg;
    reg game_over_sound_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            jump_sound_reg <= 0;
            game_over_sound_reg <= 0;
            sound <= 0;
        end else begin
            jump_sound_reg <= jump_sound;
            game_over_sound_reg <= game_over_sound;
            sound <= jump_sound_reg | game_over_sound_reg;
        end
    end

    jump_sound_player i_jump(
        .clk(clk),
        .rst_n(rst_n),
        .sound_trigger(jump_pulse),
        .wave_out(jump_sound)
    );

    game_over_sound_player i_over(
        .clk(clk),
        .rst_n(rst_n),
        .is_over(game_is_over),
        .wave_out(game_over_sound)
    );

endmodule