import cocotb
from cocotb.triggers import ClockCycles
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
from cocotb import coroutine, test
from scapy.all import Ether, IP, TCP, raw
from scapy.packet import Packet as scapy_packet
from bitstring import BitArray

"""
Dictionnary to convert scapy name to VHDL.
structure : scapyName: [VHDLname, length in bits]
"""
scapy_to_VHDL = {
    "Ether": ["ether", 112],
    "IP": ["ipv4", 160],
    "TCP": ["tcp", 160],
    "UDP": ["udp", 160]
    }


def scap_to_PHV(dut: cocotb.handle, packet: scapy_packet):
    """setUp interface of dut with packet info
    If process header recursively, if not on dut raise error.
    This function is the expected output of a packet parser
    """
    if not isinstance(packet, scapy_packet):
        raise TypeError("expected scapy Packet type")
    for i in scapy_to_VHDL:
        if packet.haslayer(i):
            signal = "{}_bus".format(scapy_to_VHDL[i][0])
            if not (signal in dut._sub_handles):
                raise("unvalid header : {}_bus".format(scapy_to_VHDL[i][0]))
            val = BinaryValue()
            val.binstr=BitArray(raw(packet.getlayer(i))[0:int(scapy_to_VHDL[i][1]/8)]).bin
            dut._sub_handles[signal].value = val
    dut._log.info("fin parser")


@test()
def parser(dut: cocotb.handle):
    dut._discover_all()
    print("debut test {}".format(dut.__dict__))
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    dut._log.info("Running test")
    pkt = Ether(src="aa:aa:aa:aa:aa:aa",
                dst='11:22:33:44:55:66',
                type="IPv4") / IP(
                    src="192.168.1.1",
                    dst="192.168.1.2") / TCP(
                        sport=80,
                        dport=12000) / "DEADBEEF"
    scap_to_PHV(dut, pkt)
    yield ClockCycles(dut.clk, 15)


@test()
def testAll(dut):
    """ test with eth+IPv4+TCP+Payload"""
    cocotb.fork(Clock(dut.clk, 6.4, 'ns').start())
    dut._log.info("Running test")
    dut.rst <= 0
    dut.ethBus <= 0
    dut.IPv4Bus <= 0
    dut.payload_in_data <= 0
    dut.tcpBus <= 0
    yield ClockCycles(dut.clk, 10)
    dut.rst <= 1
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
