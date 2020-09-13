
#include <core.p4>
#include <v1model.p4>
#include "includes/headers.p4"


struct headers {
    ethernet_h          ethernet;
    ipv4_t              ipv4;
    ipv6_h              ipv6;
    udp_h               udp;
    tcp_h               tcp;
}

struct metadata {
    /* empty */
}
//@Xilinx_MaxPacketRegion(1518*8)  // in bits
parser MyParser(packet_in pkt,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.type) {
            0x800  : parse_ipv4;
	    0x86DD    : parse_ipv6;
            default : accept;
        }
    }
    state parse_ipv6 {
        pkt.extract(hdr.ipv6);
        transition select(hdr.ipv6.nh) {
            0x11      : parse_udp;
            6       : parse_tcp;
            default : accept;
        }
    }
    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            6       : parse_tcp;
	    0x11      : parse_udp;
            default : accept;
        }
    }
    state parse_udp {
        pkt.extract(hdr.udp);
        transition accept;
    }
    state parse_tcp {
        pkt.extract(hdr.tcp);
        transition accept;
    }

}

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action forwardPacket(bit<9> value) {
        standard_metadata.egress_port = value;
    }
    action dropPacket() {
        standard_metadata.egress_port = 0xF;
    }

    //@Xilinx_ExternallyConnected
    table forwardIPv4 {
        key             = { hdr.ipv4.dstAddr : lpm; }
        actions         = { forwardPacket; dropPacket; }
        size            = 65535;
        default_action  = dropPacket;
    }

    apply {
        if (hdr.ipv4.isValid())
            //forwardIPv4.apply();
            forwardPacket(0x1);
        else
            dropPacket();
    }
}


control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
     apply {
	update_checksum(
	    hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	      hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}

//@Xilinx_MaxPacketRegion(1518*8)  // in bits
control MyDeparser(packet_out pkt, in headers hdr) {
    apply {
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.ipv4);
	pkt.emit(hdr.ipv6);
        pkt.emit(hdr.tcp);
	pkt.emit(hdr.udp);
    }
}

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;