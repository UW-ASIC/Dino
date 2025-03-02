// Portions taken from (C)2023 Will Green, open source software released under the MIT License

#include <stdio.h>
#include <SDL.h>
#include <verilated.h>
#include "verilated_vpi.h"
#include "Vtop_dino.h"
#include <atomic>

double sc_time_stamp() { return 0; }

// screen dimensions
const int H_RES = 640;
const int V_RES = 480;

// declarations for TV-simulator sync parameters
// horizontal constants
const int H_SYNC          =  96; // horizontal sync width
const int H_BACK          =  48; // horizontal left border (back porch)
const int H_DISPLAY       = 640; // horizontal display width
const int H_FRONT         =  16; // horizontal right border (front porch)
// vertical constants
const int V_SYNC          =   2; // vertical sync # lines
const int V_BOTTOM        =  10; // vertical bottom border
const int V_DISPLAY       = 480; // vertical display height
const int V_TOP           =  33; // vertical top border
// derived constants
const int H_SYNC_START    = H_DISPLAY + H_FRONT;
const int H_SYNC_END      = H_DISPLAY + H_FRONT + H_SYNC;
const int H_MAX           = H_DISPLAY + H_BACK + H_FRONT + H_SYNC;
const int V_SYNC_START    = V_DISPLAY + V_BOTTOM;
const int V_SYNC_END      = V_DISPLAY + V_BOTTOM + V_SYNC;
const int V_MAX           = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC;


typedef struct Pixel {  // for SDL texture
    uint8_t a;  // transparency
    uint8_t b;  // blue
    uint8_t g;  // green
    uint8_t r;  // red
} Pixel;

class VGAController {
    private:
    bool h_sync = 1;
    bool v_sync = 1;
    int x = 0;
    int y = 0;

    public:
    void set_h_sync(bool h) {
        if (h_sync == 0 && h == 0) {
            h_sync = 0;
            x++;
        } else if (h_sync == 0 && h == 1) {
            x++;
            if (x != H_SYNC_END) {
                printf("Weird hsync value (1): %d\n", x);
            }
            h_sync = 1;
            x = H_SYNC_END;
        } else if (h_sync == 1 && h == 0) {
            x++;
            if (x != H_SYNC_START) {
                printf("Weird hsync value (2): %d\n", x);
            }
            h_sync = 0;
            x = H_SYNC_START;
        } else if (h_sync == 1 && h == 1) {
            h_sync = 1;
            if (x == H_MAX - 1) {
                x = 0;
            } else {
                x++;
            }
        }
    }
    void set_v_sync(bool v) {
        if (v_sync == 0 && v == 0) {
            v_sync = 0;
            y++;
        } else if (v_sync == 0 && v == 1) {
            y++;
            if (y != V_SYNC_END*H_MAX) {
                printf("Weird vsync value (1): %d\n", y);
            }
            v_sync = 1;
            y = V_SYNC_END*H_MAX;
        } else if (v_sync == 1 && v == 0) {
            y++;
            if (y != V_SYNC_START*H_MAX) {
                printf("Weird vsync value (2): %d\n", y);
            }
            v_sync = 0;
            y = V_SYNC_START*H_MAX;
        } else if (v_sync == 1 && v == 1) {
            v_sync = 1;
            if (y == V_MAX*H_MAX - 1) {
                y = 0;
            } else {
                y++;
            }
        }
    }

    int getX() {
        return x;
    }

    int getY() {
        return y/H_MAX;
    }

    bool getDisplayEnable() {
        return (x >= 0 && y >= 0 && x < H_DISPLAY && y < V_DISPLAY*H_MAX) ? true : false;
    }

};

std::atomic<bool> running(true);  // Shared flag for program state

int EventThread(void* data) {
    SDL_Event e;
    while (SDL_WaitEvent(&e)) {
        if (e.type == SDL_QUIT) {
            running = false;
            break;
        }
    }
    return 0;
}

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL init failed.\n");
        return 1;
    }

    Pixel screenbuffer[H_RES*V_RES];

    SDL_Window*   sdl_window   = NULL;
    SDL_Renderer* sdl_renderer = NULL;
    SDL_Texture*  sdl_texture  = NULL;

    sdl_window = SDL_CreateWindow("Bounce", SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED, H_RES, V_RES, SDL_WINDOW_SHOWN);
    if (!sdl_window) {
        printf("Window creation failed: %s\n", SDL_GetError());
        return 1;
    }

    sdl_renderer = SDL_CreateRenderer(sdl_window, -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!sdl_renderer) {
        printf("Renderer creation failed: %s\n", SDL_GetError());
        return 1;
    }

    sdl_texture = SDL_CreateTexture(sdl_renderer, SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_TARGET, H_RES, V_RES);
    if (!sdl_texture) {
        printf("Texture creation failed: %s\n", SDL_GetError());
        return 1;
    }

    SDL_Thread* eventThread = SDL_CreateThread(EventThread, "EventThread", NULL);

    // reference SDL keyboard state array: https://wiki.libsdl.org/SDL_GetKeyboardState
    const Uint8 *keyb_state = SDL_GetKeyboardState(NULL);

    printf("Simulation running. Press 'Q' in simulation window to quit.\n\n");

    // initialize Verilog module
    Vtop_dino* top = new Vtop_dino;


    VGAController vga{};


    // reset
    top->ena = 1;
    top->rst_n = 0;
    top->clk = 0;
    top->eval();
    top->clk = 1;
    top->eval();
    top->rst_n = 1;
    top->clk = 0;
    top->eval();

    // initialize frame rate
    uint64_t start_ticks = SDL_GetPerformanceCounter();
    uint64_t frame_count = 0;



    // https://verilator.org/guide/latest/connecting.html#vpi-example
    // get handle to game_state signal
    vpiHandle game_state_vh = vpi_handle_by_name((PLI_BYTE8*)"TOP.top_dino.top.player_constroller_inst.game_state", NULL);
    if (!game_state_vh) vl_fatal(__FILE__, __LINE__, "sim_main", "No handle found");
    const char* game_state_name = vpi_get_str(vpiName, game_state_vh);
    const char* game_state_type = vpi_get_str(vpiType, game_state_vh);
    const int game_state_size = vpi_get(vpiSize, game_state_vh);
    printf("register name: %s, type: %s, size: %d\n", game_state_name, game_state_type, game_state_size); 
    s_vpi_value game_state_val;
    game_state_val.format = vpiIntVal;

    int game_state_val_old = -1;

    // get handle to generic 1 signal
    vpiHandle g1_vh = vpi_handle_by_name((PLI_BYTE8*)"TOP.top_dino.top.player_constroller_inst.player_position", NULL);
    if (!g1_vh) vl_fatal(__FILE__, __LINE__, "sim_main", "No handle found");
    const char* g1_name = vpi_get_str(vpiName, g1_vh);
    const char* g1_type = vpi_get_str(vpiType, g1_vh);
    const int g1_size = vpi_get(vpiSize, g1_vh);
    printf("register name: %s, type: %s, size: %d\n", g1_name, g1_type, g1_size); 
    s_vpi_value g1_val;
    g1_val.format = vpiIntVal;

    int g1_old = -1;

    // get handle to obs_pos_1 signal
    vpiHandle obstacle1_pos_vh = vpi_handle_by_name((PLI_BYTE8*)"TOP.top_dino.top.obstacle1_pos", NULL);
    if (!obstacle1_pos_vh) vl_fatal(__FILE__, __LINE__, "sim_main", "No handle found");
    const char* obstacle1_pos_name = vpi_get_str(vpiName, obstacle1_pos_vh);
    const char* obstacle1_pos_type = vpi_get_str(vpiType, obstacle1_pos_vh);
    const int obstacle1_pos_size = vpi_get(vpiSize, obstacle1_pos_vh);
    printf("register name: %s, type: %s, size: %d\n", obstacle1_pos_name, obstacle1_pos_type, obstacle1_pos_size); 
    s_vpi_value obstacle1_pos_val;
    obstacle1_pos_val.format = vpiIntVal;

    int obstacle1_pos_old = -1;
    // get handle to obs_pos_2 signal
    vpiHandle obstacle2_pos_vh = vpi_handle_by_name((PLI_BYTE8*)"TOP.top_dino.top.obstacle2_pos", NULL);
    if (!obstacle2_pos_vh) vl_fatal(__FILE__, __LINE__, "sim_main", "No handle found");
    const char* obstacle2_pos_name = vpi_get_str(vpiName, obstacle2_pos_vh);
    const char* obstacle2_pos_type = vpi_get_str(vpiType, obstacle2_pos_vh);
    const int obstacle2_pos_size = vpi_get(vpiSize, obstacle2_pos_vh);
    printf("register name: %s, type: %s, size: %d\n", obstacle2_pos_name, obstacle2_pos_type, obstacle2_pos_size); 
    s_vpi_value obstacle2_pos_val;
    obstacle2_pos_val.format = vpiIntVal;

    int obstacle2_pos_old = -1;

    // get handle to obs_pos_1 signal
    vpiHandle bg_object1_pos_vh = vpi_handle_by_name((PLI_BYTE8*)"TOP.top_dino.top.bg_object1_pos", NULL);
    if (!bg_object1_pos_vh) vl_fatal(__FILE__, __LINE__, "sim_main", "No handle found");
    const char* bg_object1_pos_name = vpi_get_str(vpiName, bg_object1_pos_vh);
    const char* bg_object1_pos_type = vpi_get_str(vpiType, bg_object1_pos_vh);
    const int bg_object1_pos_size = vpi_get(vpiSize, bg_object1_pos_vh);
    printf("register name: %s, type: %s, size: %d\n", bg_object1_pos_name, bg_object1_pos_type, bg_object1_pos_size); 
    s_vpi_value bg_object1_pos_val;
    bg_object1_pos_val.format = vpiIntVal;

    int bg_object1_pos_old = -1;
    // get handle to obs_pos_2 signal
    vpiHandle bg_object2_pos_vh = vpi_handle_by_name((PLI_BYTE8*)"TOP.top_dino.top.bg_object2_pos", NULL);
    if (!bg_object2_pos_vh) vl_fatal(__FILE__, __LINE__, "sim_main", "No handle found");
    const char* bg_object2_pos_name = vpi_get_str(vpiName, bg_object2_pos_vh);
    const char* bg_object2_pos_type = vpi_get_str(vpiType, bg_object2_pos_vh);
    const int bg_object2_pos_size = vpi_get(vpiSize, bg_object2_pos_vh);
    printf("register name: %s, type: %s, size: %d\n", bg_object2_pos_name, bg_object2_pos_type, bg_object2_pos_size); 
    s_vpi_value bg_object2_pos_val;
    bg_object2_pos_val.format = vpiIntVal;

    int bg_object2_pos_old = -1;

    long long clk_count = 0;
    // main loop
    while (running) {

        vpi_get_value(game_state_vh, &game_state_val);

        if (game_state_val.value.integer != game_state_val_old) {
            game_state_val_old = game_state_val.value.integer;
            printf("state value: %d, clock: %lld\n", game_state_val_old, clk_count);
        }

        vpi_get_value(g1_vh, &g1_val);

        if (g1_val.value.integer != g1_old) {
            g1_old = g1_val.value.integer;
            printf("g1 value: %d, clock: %lld\n", g1_old, clk_count);
        }

        vpi_get_value(obstacle1_pos_vh, &obstacle1_pos_val);

        if (obstacle1_pos_val.value.integer != obstacle1_pos_old) {
            obstacle1_pos_old = obstacle1_pos_val.value.integer;
            printf("obstacle1_pos value: %d, clock: %lld\n", obstacle1_pos_old, clk_count);
        }

        vpi_get_value(obstacle2_pos_vh, &obstacle2_pos_val);

        if (obstacle2_pos_val.value.integer != obstacle2_pos_old) {
            obstacle2_pos_old = obstacle2_pos_val.value.integer;
            printf("obstacle2_pos value: %d, clock: %lld\n", obstacle2_pos_old, clk_count);
        }

        vpi_get_value(bg_object1_pos_vh, &bg_object1_pos_val);

        if (bg_object1_pos_val.value.integer != bg_object1_pos_old) {
            bg_object1_pos_old = bg_object1_pos_val.value.integer;
            printf("bg_object1_pos value: %d, clock: %lld\n", bg_object1_pos_old, clk_count);
        }

        vpi_get_value(bg_object2_pos_vh, &bg_object2_pos_val);

        if (bg_object2_pos_val.value.integer != bg_object2_pos_old) {
            bg_object2_pos_old = bg_object2_pos_val.value.integer;
            printf("bg_object2_pos value: %d, clock: %lld\n", bg_object2_pos_old, clk_count);
        }

        // cycle the clock
        top->clk = 1;
        top->eval();
        top->clk = 0;
        top->eval();
        clk_count ++;

        // printf("x: %d y: %d vx: %d b: %d\n", vga.getX(), vga.getY(), top->hpos, top->ypos, (((top->uo_out & 0b01000000) << 0) | ((top->uo_out & 0b00000100) << 5)));

        vga.set_h_sync(!(top->uo_out & 0b10000000)); // our code expects active low, verilog provides active high
        vga.set_v_sync(!(top->uo_out & 0b00001000)); // our code expects active low, verilog provides active high


        // update pixel if not in blanking interval
        if (vga.getDisplayEnable()) {
            Pixel* p = &screenbuffer[vga.getY()*H_RES + vga.getX()];
            p->a = 0xFF;  // transparency
            p->b = (((top->uo_out & 0b01000000) << 0) | ((top->uo_out & 0b00000100) << 5));
            // p->g = 0;
            // p->r = 0;
            p->g = (((top->uo_out & 0b00100000) << 1) | ((top->uo_out & 0b00000010) << 6));
            p->r = (((top->uo_out & 0b00010000) << 2) | ((top->uo_out & 0b00000001) << 7));
        }

        // update texture once per frame (in blanking)
        if (vga.getY() == V_RES && vga.getX() == 0) {

            // update keyboard state
            top->ui_in = keyb_state[SDL_SCANCODE_UP];
            top->ui_in = top->ui_in | keyb_state[SDL_SCANCODE_DOWN] << 1;

            SDL_UpdateTexture(sdl_texture, NULL, screenbuffer, H_RES*sizeof(Pixel));
            SDL_RenderClear(sdl_renderer);
            SDL_RenderCopy(sdl_renderer, sdl_texture, NULL, NULL);
            SDL_RenderPresent(sdl_renderer);
            frame_count++;
        }
    }

    // calculate frame rate
    uint64_t end_ticks = SDL_GetPerformanceCounter();
    double duration = ((double)(end_ticks-start_ticks))/SDL_GetPerformanceFrequency();
    double fps = (double)frame_count/duration;
    printf("Frames per second: %.1f\n", fps);

    top->final();  // simulation done

    SDL_DestroyTexture(sdl_texture);
    SDL_DestroyRenderer(sdl_renderer);
    SDL_DestroyWindow(sdl_window);
    SDL_Quit();
    return 0;
}
