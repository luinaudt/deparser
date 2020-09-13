#include <core.p4>
#include <v1model.p4>
#include "includes/headers.p4"


struct headers {
    ethernet_h          ethernet;
    ipv4_t              ipv4;
    ipv6_h              ipv6;
    icmp_h              icmp;
    icmp_h              icmp6;
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
	    0x86DD : parse_ipv6;
            default : accept;
        }
    }
    state parse_ipv6 {
        pkt.extract(hdr.ipv6);
        transition select(hdr.ipv6.nh) {
	    58      : parse_icmp6;
            0x11    : parse_udp;
            6       : parse_tcp;
            default : accept;
        }
    }
    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
	    1       : parse_icmp;
            6       : parse_tcp;
	    0x11    : parse_udp;
            default : accept;
        }
    }
    state parse_icmp{
	pkt.extract(hdr.icmp);
	transition accept;
    }
    state parse_icmp6{
	pkt.extract(hdr.icmp6);
	transition accept;
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

    apply {
    }
}


control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
     apply {
    }
}

//@Xilinx_MaxPacketRegion(1518*8)  // in bits
control MyDeparser(packet_out pkt, in headers hdr) {
    apply {
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.ipv4);
	pkt.emit(hdr.ipv6);
	pkt.emit(hdr.icmp);
	pkt.emit(hdr.icmp6);
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