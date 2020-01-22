import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock

@cocotb.test()
def test_simp(dut):
    """ test with eth+IPv4+TCP+Payload"""
    cocotb.fork(Clock(dut.clk,6.4,'ns').start())
    dut._log.info("Running test")
    dut.reset_n<=0
    dut.valid_s <= 0;
    dut.ready_m <= 0;
    yield ClockCycles(dut.clk,10)
    dut.reset_n<=1
    dut._log.info("end Rst")
    dut.valid_s <= 1;
    dut.ready_m <= 0;
    yield ClockCycles(dut.clk,1)

    
    for i in range(0,255):
        dut.data_s <= i;
        dut.tlast_s <= 0;
        yield ClockCycles(dut.clk,1)
    dut.ready_m<=1;
    for i in range(256,312):
        dut.data_s <= i;
        dut.tlast_s <= 0;
        yield ClockCycles(dut.clk,1)
    dut.ready_m<=0;
    for i in range(313,611):
        dut.data_s <= i;
        dut.tlast_s <= 0;
        yield ClockCycles(dut.clk,1)
    dut.data_s <= 512;
    dut.tlast_s <= 1;
    yield ClockCycles(dut.clk,1)

    yield ClockCycles(dut.clk,15)
    dut._log.info("end Test")
