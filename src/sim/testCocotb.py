import cocotb
from cocotb.triggers import Timer

@cocotb.test()
def testCocotb(dut):
    """Try accessing the design."""

    dut._log.info("Running test!")
    for cycle in range(10):
        dut.clk = 0
        yield Timer(1000)
        dut.clk = 1
        yield Timer(1000)
    dut._log.info("Running test!")
