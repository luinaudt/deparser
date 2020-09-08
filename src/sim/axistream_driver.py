###############################################################################
# Copyright (c) 2019 Thomas Luinaud
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL POTENTIAL VENTURES LTD BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###############################################################################

""" Driver for amba4 axi4-Stream interfaces
AMBA 4 AXI4-Stream ProtocolVersion: 1.0
Specs :
https://static.docs.arm.com/ihi0051/a/IHI0051A_amba4_axi4_stream_v1_0_protocol_spec.pdf
"""

from math import ceil as ceil
from cocotb.triggers import RisingEdge, ReadOnly
from cocotb.drivers import BusDriver
from cocotb.result import TestError
from cocotb.binary import BinaryValue
from cocotb.decorators import coroutine
from scapy.packet import Packet as scapy_packet
from scapy.all import raw
from bitstring import BitArray


class AXI4ST(BusDriver):
    """AXI4 Streaming interfaces
    """
    _signals = ["tvalid", "tready",
                "tdata"]
    _optional_signals = ["tid", "tdest",
                         "tstrb", "tkeep",
                         "tuser", "tlast"]

    def __init__(self, entity, name, clock, **kwargs):
        # config = kwargs.pop('config', {})
        BusDriver.__init__(self, entity, name, clock, **kwargs)
        self.bus.tvalid <= 0
        self.bus.tdata <= 0
        self._keep = False
        if hasattr(self.bus, "keep"):
            self.bus.tkeep <= 0
            self._keep = True

    @coroutine
    def _driver_send(self, value, sync=True, tlast=0):
        """Send a value on the bus
        """
        self.log.debug("sending value: {}".format(value))
        self.bus.tvalid <= 0
        if sync:
            yield RisingEdge(self.clock)
        if self._keep:
            self.bus.tkeep <= -1
        self.bus.tlast <= tlast
        self.bus.tdata <= value
        self.bus.tvalid <= 1
        yield self._wait_ready()
        yield RisingEdge(self.clock)
        self.bus.tvalid <= 0

    @coroutine
    def _wait_ready(self):
        """Wait for the bus to be ready
        """
        yield ReadOnly()
        while not self.bus.tready.value:
            yield RisingEdge(self.clock)
            yield ReadOnly()


class AXI4STPKts(BusDriver):
    """AXI4 Streaming interfaces
    Packet sendPacket
    """
    _signals = ["tvalid", "tready",
                "tdata"]
    _optional_signals = ["tid", "tdest",
                         "tstrb", "tkeep",
                         "tuser", "tlast"]

    def __init__(self, entity, name, clock, callback=None, **kwargs):
        # config = kwargs.pop('config', {})
        BusDriver.__init__(self, entity, name, clock, **kwargs)
        self.bus.tvalid <= 0
        self.bus.tdata <= 0
        self.width = len(self.bus.tdata)
        self._keep = False
        self._callback = callback
        if hasattr(self.bus, "tkeep"):
            self.bus.tkeep <= 0
            self._keep = True

    @coroutine
    def _wait_ready(self):
        """Wait for the bus to be ready
        """
        yield ReadOnly()
        while not self.bus.tready.value:
            yield RisingEdge(self.clock)
            yield ReadOnly()

    @coroutine
    def _send_frame(self, data, tlast=0, keep=-1):
        """ Send a single frame
        """
        self.log.debug("sending frame: {:x}".format(data.get_value()))
        if self._keep:
            self.bus.tkeep <= keep
        self.bus.tlast <= tlast
        self.bus.tdata <= data
        self.bus.tvalid <= 1
        yield self._wait_ready()
        yield RisingEdge(self.clock)
        self.bus.tvalid <= 0
        self.bus.tlast <= 0

    @coroutine
    def _send_integer(self, pkt):
        """Send huge intger on the bus
        """
        value = BinaryValue(n_bits=self.width)
        value.buff = str(pkt)
        self.log.debug("sending value: %r", value)
        self.bus.tvalid <= 0
        yield RisingEdge(self.clock)
        if self._keep:
            self.bus.tkeep <= -1
        self.bus.tlast <= 0
        self.bus.tdata <= value
        self.bus.tvalid <= 1
        yield self._wait_ready()
        yield RisingEdge(self.clock)
        self.bus.tvalid <= 0

    @coroutine
    def _send_binary_string(self, pkt):
        """ Send string based information
        """
        self.log.debug("sending packet: {}".format(pkt))
        value = BinaryValue(n_bits=self.width, bigEndian=False)
        nb_frame = ceil(len(pkt)/(self.width/8))
        end = 0
        if nb_frame > 1:
            for i in range(nb_frame-1):
                start = int(ceil(i*(self.width/8)))
                end = int(ceil((i+1)*(self.width/8)))
                self.log.debug("index start:{}, end:{}".format(start, end))
                value.binstr = BitArray(pkt[start:end][::-1], len=self.width).bin
                self.log.debug("sending value:{}".format(pkt[start:end]))
                yield self._send_frame(value)
        value.binstr = BitArray(pkt[end:][::-1], len=self.width).bin
        self.log.debug("sending value:{}".format(pkt[end:]))
        keep = (1 << len(pkt[end:])) - 1
        self.log.debug("sending keep:{:x}".format(keep))
        yield self._send_frame(value, 1, keep)

    @coroutine
    def _driver_send(self, pkt, sync=True):
        """Send a packet over the bus.
        Args:
            pkt (scapy packet): Packet to drive onto the bus.
        If ``pkt`` is a scapy packet, we simply send it word by word
        """
        self.bus.tvalid <= 0
        if sync:
            yield RisingEdge(self.clock)
        if self._callback:
            self._callback(pkt)
        if isinstance(pkt, scapy_packet):
            yield self._send_binary_string(raw(pkt))
        elif isinstance(pkt, str):
            yield self._send_binary_string(bytes(pkt, 'utf-8'))
        elif isinstance(pkt, int):
            yield self._send_integer(pkt)
        else:
            raise TestError("unsupported type")
