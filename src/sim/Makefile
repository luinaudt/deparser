VHDL_SOURCES = $(PWD)/../hw/testCocotb.vhdl
TOPLEVEL=cocotbtest  # the module name in your Verilog or VHDL file
MODULE=testCocotb  # the name of the Python test file
SIM=ghdl
COMPILE_ARGS= --ieee=synopsys
TOPLEVEL_LANG=vhdl
include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
