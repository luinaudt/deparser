
from cocotb.triggers import ClockCycles
from cocotb.scoreboard import Scoreboard
from cocotb.clock import Clock, Timer
from cocotb import coroutine, test, fork
from cocotb.binary import BinaryValue

from scapy.all import Ether, IP, TCP, raw

from model import PacketParser as scap_to_PHV
from model import scapy_to_BinaryValue, PHVDeparser, BinaryValue_to_scapy
from axistream_monitor import AXI4ST as AXI4STMonitor


class deparser_TB(object):
    def __init__(self, dut, clkperiod=6.4):
        self.dut = dut
        dut._discover_all()  # scan all signals on the design
        dut._log.setLevel(30)
        fork(Clock(dut.clk, clkperiod, 'ns').start())
        self.stream_out = AXI4STMonitor(dut, "packet_out", dut.clk,
                                        callback=self.print_trans)
        self.scoreboard = Scoreboard(dut, fail_immediately=False)
        self.expected_output = []
        self.scoreboard.add_interface(self.stream_out, self.expected_output)
        self.nb_frame = 0
        self.packet = BinaryValue()

    """
    Dictionnary to convert scapy name to VHDL.
    structure : scapyName: [VHDLname, length in bits]
    """
    name_to_VHDL = {
        "Ether": ["ether", 112],
        "IP": ["ipv4", 160],
        "TCP": ["tcp", 160]
    }

    @coroutine
    def async_rst(self):
        """ This function execute the reset_n for 40ns
        it also set all input signals to default value
        """
        self.dut._log.info("begin Rst")
        for i in self.dut._sub_handles:
            self.dut._sub_handles[i].value = 0
        yield Timer(40, 'ns')
        self.dut.reset_n <= 1
        yield Timer(15, 'ns')
        self.dut._log.info("end Rst")

    def print_trans(self, transaction):
        self.dut._log.info("Frame : {}, {}B:{}".format(self.nb_frame,
                                                       len(transaction.buff),
                                                       transaction))
        self.packet.buff += transaction.buff
        self.nb_frame += 1
        if self.dut.packet_out_tlast == 1:
            print(raw(BinaryValue_to_scapy(self.packet)))
            #BinaryValue_to_scapy(self.packet).display()
            # self.dut._log.info("received {}B : {}".format(
            #    len(self.packet.buff),
            #    self.packet.binstr))

    def set_PHV(self, pkt):
        """ set PHV for deparser
        """
        scap_to_PHV(self.dut, pkt, self.name_to_VHDL)
        full_hdr = scapy_to_BinaryValue(pkt)
        print(raw(pkt))
        self.dut._log.info("send {}B : {}".format(len(full_hdr.buff),
                                                  full_hdr.binstr))
        new_output = PHVDeparser(full_hdr, len(self.dut.packet_out_tdata))
        self.expected_output.extend(new_output)


@test()
def parser(dut):
    tb = deparser_TB(dut)
    yield tb.async_rst()
    dut._log.info("Running test")
    pkt = Ether(src="aa:aa:aa:aa:aa:aa",
                dst='11:11:11:11:11:11',
                type="IPv4") / IP(
                    src="192.168.1.1",
                    dst="192.168.1.2") / TCP(
                        sport=80,
                        dport=12000)
    tb.set_PHV(pkt)
    nbCycle = int(len(raw(pkt))/(len(dut.packet_out_tdata)/8))
    dut.packet_out_tready <= 1
    yield ClockCycles(dut.clk, 1)
    dut.en_deparser <= 1
    yield ClockCycles(dut.clk, 1)
    dut.en_deparser <= 0
    yield ClockCycles(dut.clk, nbCycle + 5)


@test(skip=True)
def testAll(dut):
    """ test with eth+IPv4+TCP+Payload"""
    fork(Clock(dut.clk, 6.4, 'ns').start())
    dut._log.info("Running test")
    dut.reset_n <= 0
    dut.ethBus <= 0
    dut.IPv4Bus <= 0
    dut.payload_in_data <= 0
    dut.tcpBus <= 0
    yield ClockCycles(dut.clk, 10)
    dut.reset_n <= 1
    dut._log.info("end Rst")
    dut.ethBus <= int.from_bytes(raw(Ether(src="aa:aa:aa:aa:aa:aa",
                                           dst='11:11:11:11:11:11',
                                           type="IPv4")), 'little')
    dut.IPv4Bus <= int.from_bytes(raw(IP(src="192.168.1.1",
                                         dst="192.168.1.2")), 'little')
    dut.tcpBus <= int.from_bytes(raw(TCP(sport=80, dport=12000)), 'little')
    dut.payload_in_data <= int(0xDEADBEEFDEADBEEF)
    yield ClockCycles(dut.clk, 15)
    yield ClockCycles(dut.clk, 1)
    yield ClockCycles(dut.clk, 15)
    dut._log.info("end Test")


@coroutine
def sendPacket(packet, dut):
    pass
