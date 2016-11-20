# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all verilog modules in makeboxmove.v to working dir;
# could also have multiple verilog files.
vlog makeboxmove.v

# Load simulation using mux as the top level simulation module.
vsim -L altera_mf_ver datapath

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# draw at (1,1)
force {clock} 0 0, 1 5  -r 10
force {reset_n} 0 0, 1 10

force {drawcounter} 0000 0, 0000 10,0001 20, 0010 30, 0011 40, 0100 50, 0101 60, 0110 70, 0111 80, 1000 90,1001 100, 1010 110, 1011 120, 1100 130,1101 140, 1110 150, 1111 160, 0000 200,0001 210, 0010 220, 0011 230, 0100 240, 0101 250, 0110 260, 0111 270, 1000 280,1001 290, 1010 300, 1011 310, 1100 320,1101 330, 1110 340, 1111 350, 0000 420,0001 430, 0010 440, 0011 450, 0100 460, 0101 470, 0110 480, 0111 490, 1000 500,1001 510, 1010 520, 1011 530, 1100 540,1101 550, 1110 560, 1111 570
force {ld_x} 0 0, 1 10
force {ld_y} 0 0, 1 10
force {color_in} 001 10, 010 200
force {updateenable} 0 0, 1 420, 0 430


run 600ps
