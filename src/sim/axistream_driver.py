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

""" Driver for amba4 axi4-Stream interfaces
AMBA 4 AXI4-Stream ProtocolVersion: 1.0
Specs : https://static.docs.arm.com/ihi0051/a/IHI0051A_amba4_axi4_stream_v1_0_protocol_spec.pdf
"""

import cocotb
from cocotb.triggers import RisingEdge, ReadOnly, Lock
from cocotb.triggers import ReadOnly
from cocotb.drivers import BusDriver
from cocotb.result import ReturnValue
from cocotb.binary import BinaryValue
from cocotb.decorators import coroutine

class AXI4ST(BusDriver):
    """AXI4 Streaming interfaces
    
    """
    _signals = ["valid", "ready",
                "data"]
    _optional_signals = ["tid", "tdest",
                         "tstrb", "keep", 
                         "tuser", "tlast"]
    
    def __init__(self, entity, name, clock, **kwargs):
        config = kwargs.pop('config', {})
        BusDriver.__init__(self, entity, name, clock, **kwargs)
        self.bus.valid  <= 0
        self.bus.data  <= 0
        self._keep = False
        if hasattr(self.bus, "keep"):
            self.bus.keep <= 0
            self._keep = True

    @coroutine
    def _driver_send(self, value, sync=True, tlast=0):
        """Send a value on the bus
        """
        self.log.debug("sending value: %r", value)
        self.bus.valid <= 0
        if sync:
            yield RisingEdge(self.clock)
        if self._keep:
            self.bus.keep <= -1
        self.bus.tlast <= tlast
        self.bus.data <= value
        self.bus.valid <= 1
        yield self._wait_ready()
        yield RisingEdge(self.clock)
        self.bus.valid <= 0

    @coroutine
    def _wait_ready(self):
        """Wait for the bus to be ready
        """
        yield ReadOnly()
        while not self.bus.ready.value:
            yield RisingEdge(self.clock)
            yield ReadOnly()

