
import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock
from cocotb.scoreboard import Scoreboard
import logging
from axistream_driver import AXI4ST
from axistream_monitor import AXI4ST as AXI4STMonitor


class axistream_fifo_TB(object):
    def __init__(self, dut):
        self.dut = dut
        self.stream_in = AXI4ST(dut, "stream_in", dut.clk)
        self.stream_out = AXI4STMonitor(dut, "stream_out", dut.clk,
                                        callback=self.print_trans)
        self.expected_output = []
        self.scoreboard = Scoreboard(dut, fail_immediately=True)
        self.scoreboard.add_interface(self.stream_out, self.expected_output)
        self.stream_in_recovered = AXI4STMonitor(dut, "stream_in", dut.clk,
                                                 callback=self.model)

    def print_trans(self, transaction):
        # print(transaction)
        pass

    def model(self, transaction):
        """ Model the expected output based on input
        """
        self.expected_output.append(transaction)
        # print(self.expected_output)

    def insertContinuousBatch(self, nb, base):
        """
        Insert nb element in the stream_in with base as first value
        """
        for i in range(nb):
            self.stream_in.append(base+i)

    @cocotb.coroutine
    def async_rst(self):
        """ This function execute the reset_n for 40ns
        it also set all input signals to default value
        """
        self.dut._log.info("begin Rst")
        self.dut.reset_n <= 0
        self.dut.stream_in_data <= 0
        self.dut.stream_in_tlast <= 0
        self.dut.stream_in_valid <= 0
        self.dut.stream_out_ready <= 0
        yield Timer(40, 'ns')
        self.dut.reset_n <= 1
        yield Timer(15, 'ns')
        self.dut._log.info("end Rst")


@cocotb.test()
def tst_1insert_1read(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.stream_in.append(456)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_1insert_1read_alternate(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    dut.stream_out_ready <= 1
    for i in range(4):
        tb.stream_in.append(456+i)
        yield ClockCycles(dut.clk, 10)
    yield ClockCycles(dut.clk, 25)
    for i in range(4):
        tb.stream_in.append(456+i)
        yield ClockCycles(dut.clk, 3)
    yield ClockCycles(dut.clk, 25)
    for i in range(4):
        tb.stream_in.append(456+i)
        yield ClockCycles(dut.clk, 3)


@cocotb.test()
def tst_1insert_1read_alternate10C(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    dut.stream_out_ready <= 1
    for i in range(4):
        tb.stream_in.append(456+i)
        yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_1insert_1read_alternate3C(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    dut.stream_out_ready <= 1
    for i in range(4):
        tb.stream_in.append(456+i)
        yield ClockCycles(dut.clk, 3)
    yield ClockCycles(dut.clk, 25)


@cocotb.test()
def tst_1insert_1read_alternate2C(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    dut.stream_out_ready <= 1
    for i in range(4):
        tb.stream_in.append(456+i)
        yield ClockCycles(dut.clk, 2)
    yield ClockCycles(dut.clk, 25)


@cocotb.test()
def tst_2insert_2read(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.stream_in.append(456)
    tb.stream_in.append(856)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_insert_read_instant(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.insertContinuousBatch(25, 90)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 50)


@cocotb.test()
def tst_insert_read_full(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    # insert one element and read
    tb.stream_in.append(456)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 10)
    dut.stream_out_ready <= 0
    # prepare transaction
    tb.insertContinuousBatch(256, 97)
    yield ClockCycles(dut.clk, 300)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 200)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 10)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 54)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 1)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 1)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 2)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 35)
    tb.insertContinuousBatch(1024, 898)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 1024)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 200)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 15)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 1024)


@cocotb.test()
def tst_insert(dut):
    """ Only write into the fifo
    """
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.insertContinuousBatch(5, 5)
    tb.stream_in.append(895, tlast=1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_insert_read_left1(dut):
    """ expected output : 5 6 7 8 9 895
    test when only one element left
    10 clock cycles wait before getting last element.
    """
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.insertContinuousBatch(5, 5)
    tb.stream_in.append(895, tlast=1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 10)
    dut.stream_out_ready <= 1
    while dut.stream_out_data != 9:
        yield ClockCycles(dut.clk, 1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 10)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_insert_read(dut):
    """ expected output : 5 6 7 8 9 895
    """
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.insertContinuousBatch(5, 5)
    tb.stream_in.append(895, tlast=1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 20)
    dut.stream_out_ready <= 1
    while dut.stream_out_tlast == 0:
        yield ClockCycles(dut.clk, 1)
    yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_AXI4STScoreboard(dut):
    """
    test of scoreboard
    """
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.stream_in.append(5)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 20)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_AXI4STDriver(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    yield ClockCycles(dut.clk, 1)
    # data setup
    dut._log.setLevel(logging.INFO)
    tb.insertContinuousBatch(700, 5)
    tb.stream_in.append(895, tlast=1)
    # test
    dut.stream_out_ready <= 1
    yield RisingEdge(dut.stream_out_valid)
    yield ClockCycles(dut.clk, 1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 150)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 4)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 2)
    dut.stream_out_ready <= 1
    result = yield tb.stream_out.wait_for_recv()
    dut._log.debug("valeur recu : {}".format(result.integer))
    yield ClockCycles(dut.clk, 1)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 3)
    dut.stream_out_ready <= 1
    while dut.stream_out_tlast == 0:
        result = yield tb.stream_out.wait_for_recv()
        dut._log.debug("valeur recu : {}".format(result.integer))
        yield ClockCycles(dut.clk, 1)
    yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_reset(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    yield async_rst(dut)
    yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_fill(dut):
    """
    This function test the comportement for the FIFO when we fill it
    Complety fill the fifo
    """
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    yield async_rst(dut)
    yield ClockCycles(dut.clk, 10)
    dut.stream_in_valid <= 1
    for i in range(510):
        dut. stream_in_data <= 5+i
        yield ClockCycles(dut.clk, 1)
    dut. stream_in_data <= 515
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
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    yield async_rst(dut)
    yield ClockCycles(dut.clk, 10)
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
    dut.reset_n <= 0
    dut.stream_in_data <= 0
    dut.stream_in_tlast <= 0
    dut.stream_in_valid <= 0
    dut.stream_out_ready <= 0
    yield Timer(40, 'ns')
    dut.reset_n <= 1
    yield Timer(15, 'ns')
    dut._log.info("end Rst")
