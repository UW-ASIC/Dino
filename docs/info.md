<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Dino is a VGA-based side-scrolling runner where a dinosaur must dodge obstacles while a score accumulates. The game state (running, jumping, ducking, or game over) responds to a player controller with jump and duck inputs. Graphics are rendered using ROM-based sprites and synchronized by a VGA timing generator.

## How to test

Attach a VGA monitor via the VGA PMOD and connect button inputs to ui_in[0] for jump and ui_in[1] for duck. Reset the board to start the game and use the buttons to test gameplay. 

## External hardware

A VGA monitor is required along with a player input controller.  
