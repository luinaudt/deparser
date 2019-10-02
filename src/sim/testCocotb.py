import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

@cocotb.test()
def testCocotb(dut):
    """Try accessing the design."""
    cocotb.fork(Clock(dut.clk,10,'ns').start())
    dut._log.info("Running test!")
    val1=0
    val2=0
    for val1 in range(256):
        dut.valueIn1 <= val1
        for val2 in range(256):
            dut.valueIn2 <= val2
            yield RisingEdge(dut.clk)
    dut._log.info("Running test!")

