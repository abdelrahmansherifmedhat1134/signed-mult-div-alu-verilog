# Compile the RTL and testbenches, then run one testbench.
#   GUI with waves : vsim -do run_sim.do
#   other testbench: vsim -do "set TB tb_top_signed_mult_div8; do run_sim.do"
#   batch mode     : vsim -c -do "do run_sim.do; quit -f"
if {![info exists TB]} { set TB tb_top_signed_mult_div16 }

vlib work
vlog rtl/top_signed_mult_div.v rtl/multiplier.v rtl/division_non.v
vlog tb/$TB.v
vsim -voptargs=+acc work.$TB

if {![batch_mode]} {
    add wave -group Testbench /$TB/*
    add wave -group DUT       /$TB/DUT/*
}
run -all
if {![batch_mode]} { wave zoom full }
