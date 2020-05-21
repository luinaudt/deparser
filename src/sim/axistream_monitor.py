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
#     * Neither the name of Potential Ventures Ltd,
#       SolarFlare Communications Inc nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
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

""" monitor for amba4 axi4-Stream interfaces
AMBA 4 AXI4-Stream ProtocolVersion: 1.0
Specs : https://static.docs.arm.com/ihi0051/a/IHI0051A_amba4_axi4_stream_v1_0_protocol_spec.pdf
"""

from cocotb.decorators import coroutine
from cocotb.monitors import BusMonitor
from cocotb.triggers import RisingEdge, ReadOnly, FallingEdge
from cocotb.binary import BinaryValue


class AXI4ST(BusMonitor):
    """AXI4 streaming bus
    """
    _signals = ["valid", "ready",
                "data"]
    _optional_signals = ["tid", "tdest",
                         "tstrb", "keep",
                         "tuser", "tlast"]

    def __init__(self, entity, name, clock, **kwargs):
        config = kwargs.pop('config', {})
        BusMonitor.__init__(self, entity, name, clock, **kwargs)

    @coroutine
    def _monitor_recv(self):
        """Watch the pins and reconstruct transactions.
        We monitor on falling edge to support post synthesis simulations
        """

        # Avoid spurious object creation by recycling
        clkedge = RisingEdge(self.clock)
        falledge = FallingEdge(self.clock)
        rdonly = ReadOnly()

        def valid():
            if hasattr(self.bus, "ready"):
                return self.bus.valid.value and self.bus.ready.value
            return self.bus.valid.value

        # NB could yield on valid here more efficiently?
        while True:
            yield falledge
            yield rdonly
            if valid():
                vec = self.bus.data.value
                self._recv(vec)


class AXI4STPKts(BusMonitor):
    """ AXI4 Streaming packet monitor
    """
    _signals = ["valid", "ready", "tlast",
                "data"]
    _optional_signals = ["tid", "tdest",
                         "tstrb", "keep",
                         "tuser"]

    def __init__(self, entity, name, clock, **kwargs):
        config = kwargs.pop('config', {})
        BusMonitor.__init__(self, entity, name, clock, **kwargs)

    @coroutine
    def _monitor_recv(self):
        """Watch the pins and reconstruct transactions.
        We monitor on falling edge to support post synthesis simulations
        """

        # Avoid spurious object creation by recycling
        clkedge = RisingEdge(self.clock)
        falledge = FallingEdge(self.clock)
        rdonly = ReadOnly()
        pkt = BinaryValue()

        def valid():
            if hasattr(self.bus, "ready"):
                return self.bus.valid.value and self.bus.ready.value
            return self.bus.valid.value

        # NB could yield on valid here more efficiently?
        while True:
            yield clkedge
            yield rdonly
            if valid():
                vec = BinaryValue()
                vec = self.bus.data.value
                keep = self.bus.keep.value
                print(len(pkt.buff))
                for i, v in enumerate(keep.binstr[::-1]):
                    if v == '1':
                        pkt.buff += vec.buff[::-1][i]
                    else:
                        print("t {}".format(i))
                print(len(pkt.buff))
                if self.bus.tlast.value == 1:
                    self.log.info("received packet : {}".format(hex(pkt)))
                    self._recv(pkt)
                    pkt = BinaryValue()
