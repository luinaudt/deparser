"""This file contains utility function to simulate the compiler
The goal is to have golden model written in Python which generate signals.
The idea it that we should be able to have a toolchain that allow a
full Python description of the pipeline
"""

import cocotb
from cocotb.binary import BinaryValue
from scapy.packet import Packet as scapy_packet
from scapy.all import raw
from bitstring import BitArray


def scap_to_PHV(dut: cocotb.handle, packet: scapy_packet, scapy_to_VHDL):
    """setUp interface of dut with packet info
    If process header recursively, if not on dut raise error.
    This function is the expected output of a packet parser
    """
    if not isinstance(packet, scapy_packet):
        raise TypeError("expected scapy Packet type")
    dut._log.info("debut parsage")
    for i in scapy_to_VHDL:
        if packet.haslayer(i):
            signal = "{}_bus".format(scapy_to_VHDL[i][0])
            signal_en = "{}_valid".format(scapy_to_VHDL[i][0])
            if not (signal in dut._sub_handles):
                raise("unvalid header : {}_bus".format(scapy_to_VHDL[i][0]))
            val = BinaryValue()
            signal_width = int(scapy_to_VHDL[i][1]/8)
            val.binstr = BitArray(raw(packet.getlayer(i))[0:signal_width]).bin
            dut._sub_handles[signal].value = val
            dut._sub_handles[signal_en].value = 1
            dut._log.info("fin parser")
