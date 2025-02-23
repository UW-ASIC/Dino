// Portions taken from (C)2023 Will Green, open source software released under the MIT License

#include <stdio.h>
#include <SDL.h>
#include <verilated.h>
#include "Vtop_dino.h"

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

    int test = 0;

    // main loop
    while (1) {
        // cycle the clock
        top->clk = 1;
        top->eval();
        top->clk = 0;
        top->eval();

        // printf("x: %d y: %d vx: %d b: %d\n", vga.getX(), vga.getY(), top->hpos, top->ypos, (((top->uo_out & 0b01000000) << 0) | ((top->uo_out & 0b00000100) << 5)));

        vga.set_h_sync(!(top->uo_out & 0b10000000)); // our code expects active low, verilog provides active high
        vga.set_v_sync(!(top->uo_out & 0b00001000)); // our code expects active low, verilog provides active high


        // update pixel if not in blanking interval
        if (vga.getDisplayEnable()) {
            Pixel* p = &screenbuffer[vga.getY()*H_RES + vga.getX()];
            p->a = 0xFF;  // transparency
            p->b = (((top->uo_out & 0b01000000) << 0) | ((top->uo_out & 0b00000100) << 5));
            p->g = 0;
            // p->r = 0;
            // p->g = (((top->uo_out & 0b00100000) << 1) | ((top->uo_out & 0b00000010) << 6));
            p->r = (((top->uo_out & 0b00010000) << 2) | ((top->uo_out & 0b00000001) << 7));
        }

        // update texture once per frame (in blanking)
        if (vga.getY() == V_RES && vga.getX() == 0) {
            // check for quit event
            SDL_Event e;
            if (SDL_PollEvent(&e)) {
                if (e.type == SDL_QUIT) {
                    break;
                }
            }

            if (keyb_state[SDL_SCANCODE_Q]) break;  // quit if user presses 'Q'

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
