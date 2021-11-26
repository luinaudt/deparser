
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb_bus.scoreboard import Scoreboard
from cocotb.clock import Clock, Timer
from cocotb import coroutine, test, fork, handle
from cocotb.binary import BinaryValue

from scapy.all import Ether, IP, TCP, UDP, raw, IPv6

from model import PacketParser as scap_to_PHV
from model import scapy_to_BinaryValue, PHVDeparser, BinaryValue_to_scapy
from axistream_driver import AXI4STPKts
from axistream_monitor import AXI4ST as AXI4STMonitor


class deparser_TB(object):
    def __init__(self, dut, clkperiod=6.4):
        self.dut = dut
        dut._discover_all()  # scan all signals on the design
        dut._log.setLevel(30)
        fork(Clock(dut.clk, clkperiod, 'ns').start())
        self.payload_in = AXI4STPKts(dut, "payload_in", dut.clk)
        self.stream_out = AXI4STMonitor(dut, "packet_out", dut.clk,
                                        callback=self.print_trans)
        #self.scoreboard = Scoreboard(dut, fail_immediately=False)
        self.expected_output = []
        #self.scoreboard.add_interface(self.stream_out, self.expected_output)
        self.nb_frame = 0
        self.packet = BinaryValue()

    """
    Dictionnary to convert scapy name to VHDL.
    structure : scapyName: [VHDLname, length in bits]
    """

    @coroutine
    def async_rst(self):
        """ This function execute the reset_n for 40ns
        it also set all input signals to default value
        """
        self.dut._log.info("begin Rst")
        for n, t in self.dut._sub_handles.items():
            if isinstance(t, handle.ModifiableObject):
                t.value = 0
        yield Timer(40, 'ns')
        self.dut.reset_n.value = 1
        yield Timer(15, 'ns')
        self.dut._log.info("end Rst")

    def print_trans(self, transaction):
        self.dut._log.info("Frame : {}, {}B:{}".format(self.nb_frame,
                                                       len(transaction.buff),
                                                       transaction))
        self.packet.buff += transaction.buff
        self.nb_frame += 1
        if self.dut.packet_out_tlast == 1:
            print(self.packet.buff)
            if len(self.packet.binstr) < 6*8:
                self.dut._log.warning("received packet lesser than 6Bytes\n"
                                      "received :‌\n{}".format(self.packet.binstr))
            else:
                print("received :‌\n{}".format(raw(BinaryValue_to_scapy(self.packet))))
            self.packet = BinaryValue()
            # BinaryValue_to_scapy(self.packet).display()
            # self.dut._log.info("received {}B : {}".format(
            #    len(self.packet.buff),
            #    self.packet.binstr))

    def set_PHV(self, pkt, payload=None):
        """ set PHV for deparser
        """
        scap_to_PHV(self.dut, pkt, self.name_to_VHDL)
        full_hdr = scapy_to_BinaryValue(pkt)
        print("emitted {} bytes : \n {}".format(len(raw(pkt)), raw(pkt)))
        self.dut._log.info("send {}B : {}".format(len(full_hdr.buff),
                                                  full_hdr.binstr))
        new_output = PHVDeparser(len(self.dut.packet_out_tdata),
                                 full_hdr)
        self.expected_output.extend(new_output)


@test(skip=False)
def latency(dut):
    tb = deparser_TB(dut, clkperiod=1)
    yield tb.async_rst()
    dut.packet_out_tready.value = 1
    dut.phv_val.value = -1
    dut.phv_bus.value = 0
    yield ClockCycles(dut.clk, 10)
    dut._log.info("end Rst")
    yield ClockCycles(dut.clk, 10)
    dut.en_deparser.value = 1
    nbCycle = 1
    yield ClockCycles(dut.clk, 1)
    dut.en_deparser.value = 0
    while dut.packet_out_tlast == 0 and nbCycle < 250:
        nbCycle += 1
        yield ClockCycles(dut.clk, 1)
    print("total cycles = {}".format(nbCycle))
    with open("resultLatency.txt",'a') as f:
        f.write("test : {} , {}," 
                "total cycles = {}\n".format(len(dut.packet_out_tdata),
                                             int(len(dut.phv_bus)/8),
                                             nbCycle))
