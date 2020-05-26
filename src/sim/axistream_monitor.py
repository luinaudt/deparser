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
    _signals = ["tvalid", "tready",
                "tdata"]
    _optional_signals = ["tid", "tdest",
                         "tstrb", "tkeep",
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
            if hasattr(self.bus, "tready"):
                return self.bus.tvalid.value and self.bus.tready.value
            return self.bus.tvalid.value

        # NB could yield on valid here more efficiently?
        while True:
            yield falledge
            yield rdonly
            if valid():
                vec = BinaryValue()
                data = self.bus.tdata.value
                self.log.debug("received data : {}".format(data.binstr))
                if hasattr(self.bus, "tkeep"):
                    keep = self.bus.tkeep.value
                    if 'U' in keep.binstr:
                        self.log.warning(
                            "received keep contains U value :{}, data : {}"
                            .format(keep.binstr, data.binstr))
                    self.log.debug("received keep : {}".format(keep.binstr))
                    for i, v in enumerate(keep.binstr[::-1]):
                        if v in '1U':
                            vec.buff += data.buff[::-1][i]
                    self.log.debug("recomposed data : {}".format(vec.binstr))
                else:
                    vec = data
                self._recv(vec)


class AXI4STPKts(BusMonitor):
    """ AXI4 Streaming packet monitor
    """
    _signals = ["tvalid", "tready", "tlast",
                "tdata"]
    _optional_signals = ["tid", "tdest",
                         "tstrb", "tkeep",
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
        rdonly = ReadOnly()
        pkt = BinaryValue()

        def valid():
            if hasattr(self.bus, "tready"):
                return self.bus.tvalid.value and self.bus.tready.value
            return self.bus.tvalid.value

        # NB could yield on valid here more efficiently?
        while True:
            yield clkedge
            yield rdonly
            if valid():
                vec = self.bus.tdata.value
                keep = BinaryValue(n_bits=int(len(self.bus.tdata)/8))
                keep = -1
                if hasattr(self.bus, "tkeep"):
                    keep = self.bus.tkeep.value
                    if 'U' in keep.binstr:
                        self.log.warning(
                            "received keep contains U value :{}, data : {}"
                            .format(keep.binstr, vec.binstr))
                for i, v in enumerate(keep.binstr[::-1]):
                    if v in '1U':
                        pkt.buff += vec.buff[::-1][i]
                self.log.debug("received frame : {}".format(hex(vec)))
                if self.bus.tlast.value == 1:
                    self.log.debug("received packet : {}".format(hex(pkt)))
                    self._recv(pkt)
                    pkt = BinaryValue()
