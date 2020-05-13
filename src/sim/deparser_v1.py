import cocotb
from cocotb.triggers import ClockCycles
from cocotb.clock import Clock
from scapy.all import Ether, IP, TCP, raw


@cocotb.test()
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


@cocotb.coroutine
def sendPacket(packet, dut):
    pass
