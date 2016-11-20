# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all verilog modules in makeboxmove.v to working dir;
# could also have multiple verilog files.
vlog makeboxmove.v

# Load simulation using mux as the top level simulation module.
vsim -L altera_mf_ver control

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# draw at (1,1)
force {clk} 0 0, 1 5  -r 10
force {reset_n} 0 0, 1 10
#force {counter} 0000 0, 0000 10,0001 20, 0010 30, 0011 40, 0100 50, 0101 60, 0110 70, 0111 80, 1000 90,1001 100, 1010 110, 1011 120, 1100 130,1101 140, 1110 150, 1111 160



run 800ps
