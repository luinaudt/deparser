import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock
from cocotb.scoreboard import Scoreboard
import logging
import axistream_driver
from axistream_driver import AXI4ST
import axistream_monitor
from axistream_monitor import AXI4ST as AXI4STMonitor

class axistream_fifo_TB(object):
    def __init__(self, dut):
        self.dut = dut
        self.stream_in = AXI4ST(dut, "stream_in", dut.clk)
        self.stream_out = AXI4STMonitor(dut, "stream_out", dut.clk, callback=self.print_trans)
        self.expected_output = []
        self.scoreboard = Scoreboard(dut, fail_immediately=False)
        self.scoreboard.add_interface(self.stream_out, self.expected_output)
        self.stream_in_recovered = AXI4STMonitor(dut, "stream_in", dut.clk, callback=self.model)

    def print_trans(self, transaction):
        print(transaction)
        
    def model(self, transaction):
        """ Model the expected output based on input
        """
        self.expected_output.append(transaction)
        print(self.expected_output)

    @cocotb.coroutine
    def async_rst(self):
        """ This function execute the reset_n for 40ns
        it also set all input signals to default value
        """
        self.dut._log.info("begin Rst")
        self.dut.reset_n<=0
        self.dut.stream_in_data <= 0;
        self.dut.stream_in_tlast <= 0;
        self.dut.stream_in_valid <= 0;
        self.dut.stream_out_ready <= 0;
        yield Timer(40, 'ns')
        self.dut.reset_n<=1;
        yield Timer(15, 'ns')
        self.dut._log.info("end Rst")


        
@cocotb.test()
def tst_insert_read_left1(dut):
    """ expected output : 5 6 7 8 9 895
    test when only one element left
    10 clock cycles wait before getting last element.
    """
    cocotb.fork(Clock(dut.clk,6.4,'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    for i in range(5):
        tb.stream_in.append(i+5)
    tb.stream_in.append(895,tlast=1)
    #test
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk,10)
    dut.stream_out_ready <= 1
    while dut.stream_out_data != 9:
        yield ClockCycles(dut.clk,1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk,10)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk,1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk,10)
        
@cocotb.test()
def tst_insert_read(dut):
    """ expected output : 5 6 7 8 9 895
    """
    cocotb.fork(Clock(dut.clk,6.4,'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    for i in range(5):
        tb.stream_in.append(i+5)
    tb.stream_in.append(895,tlast=1)
    #test
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk,20)
    dut.stream_out_ready <= 1
    while dut.stream_out_tlast == 0:
        yield ClockCycles(dut.clk,1)
    yield ClockCycles(dut.clk,10)
    
@cocotb.test()
def tst_AXI4STScoreboard(dut):
    """
    test of scoreboard
    """
    cocotb.fork(Clock(dut.clk,6.4,'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.stream_in.append(5)
    #test
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk,20)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk,10)

@cocotb.test()
def tst_AXI4STDriver(dut):
    cocotb.fork(Clock(dut.clk,6.4,'ns').start())
    yield async_rst(dut)
    yield ClockCycles(dut.clk,1)
    #data setup
    stream_in = AXI4ST(dut, "stream_in", dut.clk)
    stream_out = AXI4STMonitor(dut, "stream_out", dut.clk)
    stream_in.log.setLevel(logging.INFO)
    for i in range(700):
        stream_in.append(i+5)
    stream_in.append(895,tlast=1)
    #test
    dut.stream_out_ready <= 1
    yield RisingEdge(dut.stream_out_valid)
    yield ClockCycles(dut.clk,1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk,150)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk,4)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk,2)
    dut.stream_out_ready <= 1
    result = yield stream_out.wait_for_recv()
    dut._log.info("valeur recu : {}".format(result.integer));
    yield ClockCycles(dut.clk,1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk,3)
    dut.stream_out_ready <= 1
    while dut.stream_out_tlast == 0:
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
