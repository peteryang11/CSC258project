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
force {x_coord} 00000001 0
force {y_coord} 0000001 0
force {counter} 0000 0, 0000 10,0001 20, 0010 30, 0011 40, 0100 50, 0101 60, 0110 70, 0111 80, 1000 90,1001 100, 1010 110, 1011 120, 1100 130,1101 140, 1110 150, 1111 160, 0000 170,0001 180, 0010 190, 0011 200, 0100 210, 0101 220, 0110 230, 0111 240, 1000 250,1001 260, 1010 270, 1011 280, 1100 290,1101 300, 1110 310, 1111 320 
force {ld_x} 0 0, 1 10
force {ld_y} 0 0, 1 10
force {color_in} 001 0
force {change_color} 0 0, 1 160, 0 170


run 400ps
