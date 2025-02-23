## Project F: Racing the Beam - Verilator Sim Makefile
## (C)2023 Will Green, open source hardware released under the MIT License
## Learn more at https://projectf.io/posts/racing-the-beam/

VFLAGS = -O3 --x-assign fast --x-initial fast --noassert -Wno-TIMESCALEMOD --public --vpi --top-module top_dino
# -O3 --x-assign fast --x-initial fast --noassert -Wno-TIMESCALEMOD  --vpi
SDL_CFLAGS = `sdl2-config --cflags`
SDL_LDFLAGS = `sdl2-config --libs`
SRC_FOLDER = -Isrc
# Find all Verilog files in src/
VERILOG_SRCS = $(wildcard ../src/*.v)

dino: dino.exe

%.exe: %.mk
	make -C ./obj_dir -f Vtop_$<

%.mk: top_%.v
	verilator ${VFLAGS} -I.. ${SRC_FOLDER} \
	    -cc $< $(filter-out $<, $(VERILOG_SRCS)) --exe main_$(basename $@).cpp -o $(basename $@) \
		-CFLAGS "${SDL_CFLAGS}" -LDFLAGS "${SDL_LDFLAGS}"

%.mk: top_%.sv
	verilator ${VFLAGS} -I.. ${SRC_FOLDER} \
	    -cc $< $(filter-out $<, $(VERILOG_SRCS)) --exe main_$(basename $@).cpp -o $(basename $@) \
		-CFLAGS "${SDL_CFLAGS}" -LDFLAGS "${SDL_LDFLAGS}"

all: dino

clean:
	rm -rf ./obj_dir

.PHONY: all clean
