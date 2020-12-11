#include <core.p4>
#include <v1model.p4>
#include "includes/headers.p4"
#include "includes/constant.p4"


struct headers {
    ethernet_h          ethernet;
    ipv4_t              ipv4;
    ipv6_h              ipv6;
    vlan_h              vlan1;
    vlan_h              vlan2;
    mpls_h              mpls1;
    mpls_h              mpls2;
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
	    0x8100 &&& 0xEFFF : parse_vlan1;
        0x0800            : parse_ipv4;
	    0x86DD            : parse_ipv6;
	    ETHERTYPE_MPLS    : parse_mpls1;
            default : accept;
        }
    }
    state parse_vlan1{
	pkt.extract(hdr.vlan1);
        transition select(hdr.vlan1.etherType) {
	    0x8100         : parse_vlan2;
            0x0800         : parse_ipv4;
	    ETHERTYPE_MPLS : parse_mpls1;
	    0x86DD         : parse_ipv6;
            default : accept;
        }
    }
    state parse_vlan2{
	pkt.extract(hdr.vlan2);
        transition select(hdr.vlan2.etherType) {
            0x0800 : parse_ipv4;
	    0x86DD : parse_ipv6;
	    ETHERTYPE_MPLS : parse_mpls1;
            default : accept;
        }
    }
    
    state parse_mpls1{
	pkt.extract(hdr.mpls1);
	transition select(hdr.mpls1.bos){
	    0 : parse_mpls2;
	    1 : parse_mpls_bos;
	}
    }
    state parse_mpls2{
	pkt.extract(hdr.mpls2);
	transition parse_mpls_bos;
    }
    state parse_mpls_bos{
	transition select(pkt.lookahead<bit<4>>()){
	    4: parse_ipv4;
	    6: parse_ipv6;
	    default: accept;
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
extern packet_out(){
    extern emit()
}
control MyDeparser(packet_out pkt, in headers hdr) {
    apply {
         
        if hdr.ethernet.isValid(){
            pkt.insert(hdr.ethernet);
            if hdr.ipv4.isValid()
                pkt.insert(hdr.ipv4);
                if hdr.tcp.isValid()
                    pkt.inseert(hdr.tcp)
            else if hdr.ipv6.isValid(){
                pkt.insert(hdr.ipv6);
                if hdr.tcp.isValid()
                    pkt.inseert(hdr.tcp)
            }
        }
	
    // pkt.emit(hdr.ethernet);
    // pkt.emit(hdr.ipv4);
	// pkt.emit(hdr.ipv6);
    
    
    pkt.emit(hdr.vlan1);
	pkt.emit(hdr.vlan2);
	pkt.emit(hdr.mpls1);
	pkt.emit(hdr.mpls2);
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