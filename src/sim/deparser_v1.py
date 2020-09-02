
from cocotb.triggers import ClockCycles
from cocotb.scoreboard import Scoreboard
from cocotb.clock import Clock, Timer
from cocotb import coroutine, test, fork, handle
from cocotb.binary import BinaryValue

from scapy.all import Ether, IP, TCP, UDP, raw

from model import PacketParser as scap_to_PHV
from model import scapy_to_BinaryValue, PHVDeparser, BinaryValue_to_scapy
from axistream_driver import AXI4STPKts
from axistream_monitor import AXI4ST as AXI4STMonitor


class deparser_TB(object):
    def __init__(self, dut, clkperiod=6.4):
        self.dut = dut
        dut._discover_all()  # scan all signals on the design
        dut._log.setLevel(30)
        fork(Clock(dut.clk, clkperiod, 'ns').start())
        self.payload_in = AXI4STPKts(dut, "payload_in", dut.clk)
        self.stream_out = AXI4STMonitor(dut, "packet_out", dut.clk,
                                        callback=self.print_trans)
        self.scoreboard = Scoreboard(dut, fail_immediately=True)
        self.expected_output = []
        self.scoreboard.add_interface(self.stream_out, self.expected_output)
        self.nb_frame = 0
        self.packet = BinaryValue()

    """
    Dictionnary to convert scapy name to VHDL.
    structure : scapyName: [VHDLname, length in bits]
    """
    name_to_VHDL = {
        "Ether": ["ethernet", 112],
        "IP": ["ipv4", 160],
        "TCP": ["tcp", 160],
        "UDP": ["udp", 64],
        "IPv6": ["ipv6", 320]}

    @coroutine
    def async_rst(self):
        """ This function execute the reset_n for 40ns
        it also set all input signals to default value
        """
        self.dut._log.info("begin Rst")
        for n, t in self.dut._sub_handles.items():
            if isinstance(t, handle.ModifiableObject):
                t.value = 0
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
            if len(self.packet.binstr) < 6*8:
                self.dut._log.warning("received packet lesser than 6Bytes\n"
                                      "received :‌\n {}".format(self.packet.binstr))
            else:
                print("received :‌\n {}".format(raw(BinaryValue_to_scapy(self.packet))))
            self.packet = BinaryValue()
            # BinaryValue_to_scapy(self.packet).display()
            # self.dut._log.info("received {}B : {}".format(
            #    len(self.packet.buff),
            #    self.packet.binstr))

    def set_PHV(self, pkt):
        """ set PHV for deparser
        """
        payload = scap_to_PHV(self.dut, pkt, self.name_to_VHDL)
        full_hdr = scapy_to_BinaryValue(pkt)
        print("emitted \n {}".format(raw(pkt)))
        self.dut._log.info("send {}B : {}".format(len(full_hdr.buff),
                                                  full_hdr.binstr))
        new_output = PHVDeparser(full_hdr, len(self.dut.packet_out_tdata))
        self.expected_output.extend(new_output)


@test(skip=False)
def parser(dut):
    tb = deparser_TB(dut)
    yield tb.async_rst()
    dut._log.info("Running test")
    pkt = []
    pkt.append(Ether(src="aa:aa:aa:aa:aa:aa",
                     dst='11:11:11:11:11:11',
                     type="IPv4") / IP(
                         src="192.168.1.1",
                         dst="192.168.1.2") / TCP(
                             sport=80,
                             dport=12000))
    pkt.append(Ether(src="aa:aa:aa:aa:aa:aa",
                     dst='11:11:11:11:11:11',
                     type="IPv4") / IP(
                         src="192.168.1.1",
                         dst="192.168.1.2") / UDP(
                             sport=5,
                             dport=7))
    for p in pkt:
        tb.set_PHV(p)
        nbCycle = int(len(raw(p))/(len(dut.packet_out_tdata)/8))
        dut.packet_out_tready <= 1
        yield ClockCycles(dut.clk, 1)
        dut.en_deparser <= 1
        yield ClockCycles(dut.clk, 1)
        dut.en_deparser <= 0
        yield ClockCycles(dut.clk, nbCycle + 5)


@test(skip=False)
def readyChange(dut):
    tb = deparser_TB(dut)
    yield tb.async_rst()
    dut._log.info("Running test")
    pkt = []
    pkt.append(Ether(src="aa:aa:aa:aa:aa:aa",
                     dst='11:11:11:11:11:11',
                     type="IPv4") / IP(
                         src="192.168.1.1",
                         dst="192.168.1.2") / TCP(
                             sport=80,
                             dport=12000))
    pkt.append(Ether(src="aa:aa:aa:aa:aa:aa",
                     dst='11:11:11:11:11:11',
                     type="IPv4") / IP(
                         src="192.168.1.1",
                         dst="192.168.1.2") / UDP(
                             sport=5,
                             dport=7))
    for p in pkt:
        tb.set_PHV(p)
        nbCycle = int(len(raw(p))/(len(dut.packet_out_tdata)/8))
        dut.packet_out_tready <= 1
        yield ClockCycles(dut.clk, 1)
        dut.en_deparser <= 1
        yield ClockCycles(dut.clk, 1)
        dut.en_deparser <= 0
        for i in range(nbCycle * 2 + 8):
            dut.packet_out_tready <= 1
            yield ClockCycles(dut.clk, 1)
            dut.packet_out_tready <= 0
            yield ClockCycles(dut.clk, 1)


@test(skip=False)
def test_payload(dut):
    tb = deparser_TB(dut)
    yield tb.async_rst()
    dut._log.info("Running test")
    pkt = []
    pkt.append(Ether(src="aa:aa:aa:aa:aa:aa",
                     dst='11:11:11:11:11:11',
                     type="IPv4") / IP(
                         src="192.168.1.1",
                         dst="192.168.1.2") / TCP(
                             sport=80,
                             dport=12000) / "PAYLOAD TEST")
    pkt.append(Ether(src="aa:aa:aa:aa:aa:aa",
                     dst='11:11:11:11:11:11',
                     type="IPv4") / IP(
                         src="192.168.1.1",
                         dst="192.168.1.2") / UDP(
                             sport=5,
                             dport=7) / "PAYLOAD TEST")
    for p in pkt:
        tb.set_PHV(p)
        tb.payload_in.append("PAYLOAD TEST")
        nbCycle = int(len(raw(p))/(len(dut.packet_out_tdata)/8))
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
