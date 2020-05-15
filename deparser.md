# deparser
The proposed deparser target Xilinx platform with AXI4stream.
Even if all analysis are done with Xilinx FPGA, The proposed implementation should be compatible with other vendors.
The main work would be in the consideration of inputs and outputs with conversion of bus to AXI4-stream.

## Hardware
The hardware code is given in "src/hw" folder.
Currently the code is hand-written however in the future the goal is to autogenerate part of the code.

The main element we are considering is that headers are byte align.
As a result we consider only byte based shift of bus.

The basic architecture is composed of mux for each output bits on the output_data_stream.
Those muxes are regrouped in Bytes. Each block of 8 multiplexers is control with a state machine.
The state Machine takes as input the valid headers information and generate the control signals at each cycles.

## Simulation
To simulate the deparser we have decided to use cocotb.
Cocotb is a Python framework which can send stimuli to simulate hardware through software interfaces.
In this work we consider Modelsim and GHDL.
Cocotb is compatible with other tools and we invite people to use them.

The interest for cocotb is to have the flexibility of Python.
And so be able to integrate other blocks in the future and simulate those blocks with the same framework.

## compilation
The goal is to be able to compile a P4 code and generate the deparser.
Currently we are working on finding the right elements to configure and the ones that will always be the same.
Basically we are trying to abstract the hardware for the deparser on FPGAs.

## FPGAs vs ASICs
Because we are using FPGAs. some elements can't be implemented in the same way they are implemented with ASICs.
First crossbar are not efficiently implemented on FPGAs, as a result we are using Multiplexers.
Also to reduce cost we decide to integrate only the valid connection.
This is viable since we consider that a P4 code must be resynthesised when it change.

# Compiler optimization
Currently with P4_16 no optimization exists for the deparser.
One goal of the current is to determine the interest of such optimization.

We have not work on this yet but we believe that a compiler should look at the graph and determine with headers can be activated at the same time.
The compiler should be conservative, for example if a header is activated depending on the runtime then the header should be consider active all the time.

Since synthesis can be long we consider that as long as the time of compilation is relatively small compared to the synthesis time, we can use optimizations.

The compiler should also output an estimate of the ressource consumption.
