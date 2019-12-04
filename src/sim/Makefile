#VHDL_SOURCES = $(PWD)/../hw/deparser_v2.vhdl
TOPLEVEL=deparser  # the module name in your Verilog or VHDL file
MODULE=deparser_v1  # the name of the Python test file
SIM=ghdl
SIM_ARGS= --vcd=waveform.vcd
COMPILE_ARGS= --ieee=synopsys 
TOPLEVEL_LANG=vhdl
include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
