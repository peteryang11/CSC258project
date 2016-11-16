# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all verilog modules in makeboxmove.v to working dir;
# could also have multiple verilog files.
vlog makeboxmove.v

# Load simulation using mux as the top level simulation module.
vsim -L altera_mf_ver ratedivider

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# draw at (1,1)
force {Clock_50} 0 0, 1 5 -r 10
force {reset_n} 0 0, 1 10


run 100ps
