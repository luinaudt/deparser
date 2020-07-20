#VHDL_SOURCES += $(PWD)/../hw/deparser_v1.vhdl
VHDL_SOURCES += $(PWD)/../hw/axiStream_fifo.vhdl
TOPLEVEL_LANG ?= vhdl
# the module name in your Verilog or VHDL file
TOPLEVEL=deparser
MODULE=deparser_v1 # the name of the Python test file
SIM=ghdl
GUI=0
WAVES=1
ifeq ($(SIM), modelsim)
	SIM_ARGS+= -t ps -voptargs=+acc -wlf $(PWD)/waveform.wlf -modelsimini $(PWD)/XilinxLibs/modelsim.ini
	COMPILE_ARGS+= -2008 -modelsimini $(PWD)/XilinxLibs/modelsim.ini
endif
ifeq ($(SIM), ghdl)
	SIM_ARGS= --vcd=$(PWD)/waveform.vcd
	COMPILE_ARGS= --ieee=synopsys --std=08
endif

include $(shell cocotb-config --makefiles)/Makefile.sim
