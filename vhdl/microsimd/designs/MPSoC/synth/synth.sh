#!/bin/bash

ghdl --synth --work=microsimd --workdir=/home/deboehse/VLSI/projects/microsimd/build/microsimd/ghdl -P/home/deboehse/VLSI/projects/microsimd/build/general/ghdl -P/home/deboehse/VLSI/projects/microsimd/build/hibi/ghdl -P/home/deboehse/VLSI/projects/microsimd/build/microsimd/ghdl -P/home/deboehse/VLSI/projects/microsimd/build/osvvm/ghdl -P/home/deboehse/VLSI/projects/microsimd/build/tech/ghdl -P/home/deboehse/VLSI/projects/microsimd/build/tools/ghdl --std=08 -fexplicit -frelaxed --ieee=synopsys --out=verilog -gnr_cpus_g=1 msmp | sed '/^module sky130/,/^endmodule/d' > msmp_ghdl_synth.v

./add_power_ports.pl msmp_ghdl_synth.v vccd1 vssd1 > msmp_with_power_ports.v
iverilog -s msmp sky130_sram_2kbyte_1rw1r_32x512_8.v msmp_with_power_ports.v -o msmp_with_power_ports

