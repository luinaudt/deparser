VHDL_SOURCES = $(PWD)/../hw/axiStream_fifo.vhdl
TOPLEVEL= axi_stream  # the module name in your Verilog or VHDL file
MODULE=axistream_fifo_test  # the name of the Python test file
SIM=ghdl
SIM_ARGS= --wave=$(PWD)/waveform.ghw --vcd=$(PWD)/waveform.vcd
COMPILE_ARGS= --ieee=synopsys 
TOPLEVEL_LANG=vhdl
include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
