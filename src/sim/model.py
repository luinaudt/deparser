"""This file contains utility function to simulate the compiler
The goal is to have golden model written in Python which generate signals.
The idea it that we should be able to have a toolchain that allow a
full Python description of the pipeline
"""

from math import ceil
import cocotb
from cocotb.binary import BinaryValue
from scapy.packet import Packet as scapy_packet
from scapy.all import raw, Ether
from bitstring import BitArray


def scapy_to_BinaryValue(pkt):
    """ take scapy packet as input, return binaryvalue
    """
    pkt_buf = BinaryValue()
    pkt_buf.binstr = BitArray(raw(pkt)).bin
    return pkt_buf


def BinaryValue_to_scapy(binvalue):
    """ take binaryvalue return Ether scapy packet
    """
    k = BitArray()
    k.bin = binvalue.binstr
    return Ether(k.bytes)


def PacketParser(dut: cocotb.handle, packet: scapy_packet, scapy_to_VHDL):
    """setUp interface of dut with packet info
    If process header recursively, if not on dut raise error.
    This function is the expected output of a packet parser
    """
    if not isinstance(packet, scapy_packet):
        raise TypeError("expected scapy Packet type")
    dut._log.info("debut parsage")
    for i in scapy_to_VHDL:
        signal_en = "{}_valid".format(scapy_to_VHDL[i][0])
        if signal_en in dut._sub_handles:
            dut._sub_handles[signal_en].value = 0
        if packet.haslayer(i):
            signal = "{}_bus".format(scapy_to_VHDL[i][0])
            if not (signal in dut._sub_handles):
                raise("unvalid header : {}_bus".format(scapy_to_VHDL[i][0]))
            val = BinaryValue()
            signal_width = int(scapy_to_VHDL[i][1]/8)
            val.binstr = BitArray(raw(packet.getlayer(i))[0:signal_width]).bin
            val.buff = val.buff[::-1]
            dut._sub_handles[signal].value = val
            dut._sub_handles[signal_en].value = 1
            dut._log.info("fin parser")


def PHVDeparser(PHV, busSize):
    """ model for the packet deparser
    From a PHV return an ordered list of expected output stream
    PHV : full binary value of headers
    busSize : width of the output bus in bits
    """
    stream = []
    nbFrame = ceil(len(PHV.binstr)/busSize)
    end = 0
    start = 0
    if nbFrame > 1:
        for i in range(nbFrame - 1):
            start = end
            end = start + busSize
            val = BinaryValue(n_bits=busSize)
            val.binstr = PHV.binstr[start:end]
            stream.append(val)
    start = end
    end = len(PHV.binstr)
    size = end - start
    val = BinaryValue(0, n_bits=size)
    if size != len(PHV.binstr):
        val.binstr = PHV.binstr[start:end]
    else:
        val.binstr = PHV.binstr[start:end]
    stream.append(val)
    return stream
