import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock
import scapy
from scapy.all import Ether, IP, TCP

@cocotb.test()
def testAll(dut):
    """ test with eth+IPv4+TCP+Payload"""
    cocotb.fork(Clock(dut.clk,6.4,'ns').start())
    dut._log.info("Running test")
    dut.rst<=0
    dut.ethBus <= 0
    dut.IPv4Bus <= 0
    yield ClockCycles(dut.clk,10)
    dut.rst<=1
    dut._log.info("end Rst")
    dut.ethBus <= int.from_bytes(raw(Ether(src="12:34:56:78:90:23",dst="10:23:65:78:94:10", type="IPv4")), 'little')
    dut.IPv4Bus <= int.from_bytes(raw(IP(src="192.168.1.1", dst="192.168.1.2")) , 'little')
    
    yield ClockCycles(dut.clk,15)
    dut._log.info("end Test")
