import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock
import logging
import axistream_driver
from axistream_driver import AXI4ST
import axistream_monitor
from axistream_monitor import AXI4ST as AXI4STMonitor

@cocotb.coroutine
def async_rst(dut):
    """ This function execute the reset_n for 40ns
    it also set all input signals to default value
    """
    dut._log.info("begin Rst")
    dut.reset_n<=0
    dut.stream_in_data <= 0;
    dut.stream_in_tlast <= 0;
    dut.stream_in_valid <= 0;
    dut.stream_out_ready <= 0;
    yield Timer(40, 'ns')
    dut.reset_n<=1;
    yield Timer(15, 'ns')
    dut._log.info("end Rst")

@cocotb.test()
def tst_AXI4STDriver(dut):
    cocotb.fork(Clock(dut.clk,6.4,'ns').start())
    yield async_rst(dut)
    yield ClockCycles(dut.clk,1)
    stream_in = AXI4ST(dut, "stream_in", dut.clk)
    stream_out = AXI4STMonitor(dut, "stream_out", dut.clk)
    stream_in.log.setLevel(logging.INFO)
    
    for i in range(700):
        stream_in.append(i+5)
        
    stream_in.append(895,tlast=1)
    yield ClockCycles(dut.clk,535)
    dut.stream_out_ready <= 1
    result = yield stream_out.wait_for_recv()
    dut._log.info("valeur recu : {}".format(result));
    yield ClockCycles(dut.clk,1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk,3)
    dut.stream_out_ready <= 1
    for i in range(700):
        result = yield stream_out.wait_for_recv()
        dut._log.info("valeur recu : {}".format(result.integer));
        yield ClockCycles(dut.clk,1)
    yield ClockCycles(dut.clk,10)
    
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
    dut.stream_in_valid <= 1    
    for i in range(511):
        dut. stream_in_data <= 5+i
        yield ClockCycles(dut.clk, 1)
    dut.stream_in_valid <= 0
    yield ClockCycles(dut.clk, 15)
    dut.stream_in_valid <= 1
    for i in range(101):
        dut.stream_in_data <= 516+i
        yield ClockCycles(dut.clk, 1)
    dut.stream_in_valid <= 0
    yield ClockCycles(dut.clk, 15)

@cocotb.test()
def tst_empty(dut):
    """ This function test the comportement of the FIFO when we empty it
    """
    cocotb.fork(Clock(dut.clk,6.4,'ns').start())
    yield async_rst(dut)
    yield ClockCycles(dut.clk,10)
    dut.stream_in_valid <= 1
    for i in range(512):
        dut.stream_in_data <= 5+i
        yield ClockCycles(dut.clk, 1)
    dut.stream_in_valid <= 0
    yield ClockCycles(dut.clk, 1)
    dut._log.info("debut test lecture")
    dut.stream_out_ready <= 1
    for i in range(600):
        yield ClockCycles(dut.clk, 1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 15)    
