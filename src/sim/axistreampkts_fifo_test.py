import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock
from cocotb.scoreboard import Scoreboard
from cocotb.binary import BinaryValue
import logging
from axistream_driver import AXI4STPKts as AXI4ST_driver
from axistream_monitor import AXI4STPKts as AXI4STMonitor
from scapy.all import IP, TCP, Ether
from scapy.packet import Packet as scapy_pkt
from model import BinaryValue_to_scapy, scapy_to_BinaryValue

class axistream_fifo_TB(object):
    def __init__(self, dut):
        self.dut = dut
        self.stream_in = AXI4ST_driver(dut, "stream_in", dut.clk)
        #self.stream_in.log.setLevel(logging.DEBUG)
        self.stream_out = AXI4STMonitor(dut, "stream_out", dut.clk,
                                        callback=self.print_trans)
        self.expected_output = []
        self.overrideModel = False # temp help to differentiate scapy to other send
        self.scoreboard = Scoreboard(dut, fail_immediately=False)
        self.scoreboard.add_interface(self.stream_out, self.expected_output)
        self.stream_in_recovered = AXI4STMonitor(dut, "stream_in", dut.clk,
                                                 callback=self.model)

    def print_trans(self, transaction):
#        pkt = BinaryValue_to_scapy(transaction)
        print("received transaction {}".format(transaction))
#        pkt_buf = scapy_to_BinaryValue(pkt)
#        print("from packet {}".format(pkt_buf))
#        pkt.display()

    def model(self, transaction):
        """ Model the expected output based on input
        """
        if not self.overrideModel:
            self.expected_output.append(transaction)
    
    def send(self, pkt):
        if isinstance(pkt, scapy_pkt):
            self.overrideModel = True
            self.expected_output.append(scapy_to_BinaryValue(pkt))
        self.stream_in.append(pkt)
        self.overrideModel = False
        
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
def tst_1small(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.stream_in.append("25")
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 10)
    
@cocotb.test()
def tst_1insert_1read(dut):
    """Insert one value base test
    """
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.stream_in.append(456)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 10)
   
@cocotb.test()
def tst_1string_1read(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.stream_in.append('abcd')
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_1longString_1read(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.stream_in.append('abcdef')
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_1hugeInteger_1read(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    tb.stream_in.append(456789745647989)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 10)


@cocotb.test()
def tst_1EtherXil(dut):
    """Send same eth frame as the one frome Xilinx
    simulation in 40G/50G IP :
    dst : FF_FF_FF_FF_FF_FF
    src : 14_FE_B5_DD_9A_82;
    type : 06_00
    """
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    pkt = Ether(src="14:fe:B5:dd:9A:82",
                dst="ff:ff:ff:ff:ff:ff",
                type=0x0600)
    tb.stream_in.append(pkt)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 80)


@cocotb.test()
def tst_1packet(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    pkt = Ether(src="aa:aa:aa:aa:aa:aa",
                dst='11:22:33:44:55:66',
                type="IPv4") / IP(
                    src="192.168.1.1",
                    dst="192.168.1.2") / TCP(
                        sport=80,
                        dport=12000) / "DEADBEEFHHHH"
    tb.send(pkt)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 10)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 80)
    
@cocotb.test()
def tst_1LongPacket(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    pkt = Ether(src="aa:aa:aa:aa:aa:aa",
                dst='11:22:33:44:55:66',
                type="IPv4") / IP(
                    src="192.168.1.1",
                    dst="192.168.1.2") / TCP(
                        sport=80,
                        dport=12000) / """DEADBEEF Packet vraiment long 
                        pour remplir une fifo cela est très intéressant et 
                        devrais permettre de tester le bon fonctionnement 
                        d'une transaction. On envoie plusieurs fois ce paquet pour
                        remplir la FIFO"""
    for i in range(45):
        tb.stream_in.append(pkt)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 1024)
    dut.stream_out_ready <= 1
    yield ClockCycles(dut.clk, 2048)


@cocotb.test()
def tst_2packets(dut):
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    tb = axistream_fifo_TB(dut)
    yield tb.async_rst()
    pkt = Ether(src="aa:aa:aa:aa:aa:aa",
                dst='11:22:33:44:55:66',
                type="IPv4") / IP(
                    src="192.168.1.1",
                    dst="192.168.1.2") / TCP(
                        sport=80,
                        dport=12000) / "DEADBEEF"
    tb.stream_in.append(pkt)
    pkt = Ether(src="aa:aa:aa:aa:aa:aa",
                dst='55:dd:ee:32:45:63',
                type="IPv4") / IP(
                    src="192.168.15.1",
                    dst="192.168.1.25") / TCP(
                        sport=80,
                        dport=12000) / "DEADBEEF"
    tb.stream_in.append(pkt)
    dut.stream_out_ready <= 0
    yield ClockCycles(dut.clk, 80)
