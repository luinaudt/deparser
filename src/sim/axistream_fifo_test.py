import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock

@cocotb.coroutine
def async_rst(dut):
    """ This function execute the reset_n for 40ns
    it also set all input signals to default value
    """
    dut._log.info("begin Rst")
    dut.reset_n<=0
    dut.data_s <= 0;
    dut.tlast_s <= 0;
    dut.valid_s <= 0;
    dut.ready_m <= 0;
    yield Timer(40, 'ns')
    dut.reset_n<=1;
    yield Timer(15, 'ns')
    dut._log.info("end Rst")

@cocotb.test()
def tst_reset(dut):
    cocotb.fork(Clock(dut.clk,6.4,'ns').start())
    yield async_rst(dut)
    yield ClockCycles(dut.clk,10)

    
@cocotb.test()
def tst_fill(dut):
    """
    This function test the comportement for the FIFO when we fill it
    """
    cocotb.fork(Clock(dut.clk,6.4,'ns').start())
    yield async_rst(dut)
    yield ClockCycles(dut.clk,10)
    dut.valid_s <= 1    
    for i in range(511):
        dut.data_s <= 5+i
        yield ClockCycles(dut.clk, 1)
    dut.valid_s <= 0
    yield ClockCycles(dut.clk, 15)
    dut.valid_s <= 1
    for i in range(101):
        dut.data_s <= 516+i
        yield ClockCycles(dut.clk, 1)
    dut.valid_s <= 0
    yield ClockCycles(dut.clk, 15)

@cocotb.test()
def tst_empty(dut):
    """ This function test the comportement of the FIFO when we empty it
    """
    cocotb.fork(Clock(dut.clk,6.4,'ns').start())
    yield async_rst(dut)
    yield ClockCycles(dut.clk,10)
    dut.valid_s <= 1
    for i in range(512):
        dut.data_s <= 5+i
        yield ClockCycles(dut.clk, 1)
    dut.valid_s <= 0
    yield ClockCycles(dut.clk, 1)
    dut._log.info("debut test lecture")
    dut.ready_m <= 1
    for i in range(600):
        yield ClockCycles(dut.clk, 1)
    dut.ready_m <= 0
    yield ClockCycles(dut.clk, 15)    
