vlib work
vlog Object.v
vsim -L altera_mf_ver datapath
log {/*}
add wave {/*}

force {refresh_clock} 0 0ns, 1 50ns, 0 100ns
force {clock_50} 0 0ns, 1 1ns -repeat 2ns
force {resetn} 0 0ns, 1 3ns
run 200ns
