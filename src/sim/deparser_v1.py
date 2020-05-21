import cocotb
from cocotb.triggers import ClockCycles
from cocotb.clock import Clock, Timer
from axistream_monitor import AXI4ST as AXI4STMonitor
from cocotb import coroutine, test
from scapy.all import Ether, IP, TCP, raw
from model import PacketParser as scap_to_PHV
from t0_sdnet_packet import packet1


class deparser_TB(object):
    def __init__(self, dut, clkperiod=6.4):
        self.dut = dut
        dut._discover_all()
        cocotb.fork(Clock(dut.clk, clkperiod, 'ns').start())
        self.stream_out = AXI4STMonitor(dut, "packet_out", dut.clk,
                                        callback=self.print_trans)
        self.nb_frame = 0
        self.expected_output = []

    """
    Dictionnary to convert scapy name to VHDL.
    structure : scapyName: [VHDLname, length in bits]
    """
    name_to_VHDL = {
        "Ether": ["ether", 112],
        "IP": ["ipv4", 160],
        "TCP": ["tcp", 160]
    }

    @cocotb.coroutine
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
        print("transcation numero {} : {}".format(self.nb_frame, transaction))
        self.nb_frame += 1

    def set_PHV(self, pkt):
        """ set PHV for deparser
        """
        scap_to_PHV(self.dut, pkt, self.name_to_VHDL)


@test()
def parser(dut: cocotb.handle):
    tb = deparser_TB(dut)
    yield tb.async_rst()
    dut.packet_out_ready <= 1
    dut._log.info("Running test")
    pkt = Ether(src="aa:aa:aa:aa:aa:aa",
                dst='11:22:33:44:55:66',
                type="IPv4") / IP(
                    src="192.168.1.1",
                    dst="192.168.1.2") / TCP(
                        sport=80,
                        dport=12000) / "DEADBEEF"
    packet1.payload.options.clear()
    tb.set_PHV(pkt)
    nbCycle = int(len(raw(pkt))/(len(dut.packet_out_data)/8))
    yield ClockCycles(dut.clk, nbCycle + 5)


@test()
def testAll(dut):
    """ test with eth+IPv4+TCP+Payload"""
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
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
