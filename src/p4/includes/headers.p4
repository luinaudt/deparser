typedef bit<48>     MacAddress;
typedef bit<32>     ip4Addr_t;
typedef bit<128>    IPv6Address;


header ethernet_h {
    MacAddress          dst;
    MacAddress          src;
    bit<16>             type;
}
header ipv6_h {
    bit<4>              version;
    bit<8>              tc;
    bit<20>             fl;
    bit<16>             plen;
    bit<8>              nh;
    bit<8>              hl;
    IPv6Address         src;
    IPv6Address         dst;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}


header tcp_h {
    bit<16>             sport;
    bit<16>             dport;
    bit<32>             seq;
    bit<32>             ack;
    bit<4>              dataofs;
    bit<4>              reserved;
    bit<8>              flags;
    bit<16>             window;
    bit<16>             chksum;
    bit<16>             urgptr;
}
header udp_h {
        bit<16> srcPort;
        bit<16> dstPort;
        bit<16> hdrLength;
        bit<16> chksum;
}

header icmp_h{ // ICMP and ICMPv6 same header
    bit<8> h_type;
    bit<8> code;
    bit<16> checksum;
}


header vlan_h{
    bit<3> pri;
    bit<1> cfi;
    bit<12> vid;
    bit<16> etherType;
}

header mpls_h{
    bit<20> label;
    bit<3> exp;
    bit<1> bos;
    bit<8> ttl;
    }
