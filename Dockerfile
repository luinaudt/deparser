FROM fedora:latest

ARG ICARUS_VERILOG_VERSION=10_3
ARG GHDL_VERSION=0.36
ARG MAKE_JOBS=4

RUN dnf -y update
RUN dnf install -y g++ clang git make gperf flex bison \
	python3-devel python2-devel python2-pip python3-pip \
	python2-setuptools python3-setuptools python3-virtualenv \
	&& dnf clean all && pip install --upgrade pip


# Icarus Verilog 
ENV ICARUS_VERILOG_VERSION=${ICARUS_VERILOG_VERSION} 
WORKDIR /usr/src/iverilog
RUN git clone https://github.com/steveicarus/iverilog.git --depth=1 --branch v${ICARUS_VERILOG_VERSION} . \
	&& dnf install -y autoconf \
	&& autoconf \
	&& ./configure \
	&& make -j ${MAKE_JOBS} \
	&& make install \
	&& rm -r /usr/src/iverilog

# cocotb
ENV GHDL_VERSION=${GHDL_VERSION} 
WORKDIR /usr/src/ghdl
RUN dnf install -y gcc-gnat zlib-ada-devel zlib zlib-devel
RUN git clone https://github.com/ghdl/ghdl.git --depth=1 --branch v${GHDL_VERSION} .\
	&& ./configure --prefix=/usr/local \
	&& make -j ${MAKE_JOBS} \
	&& make install \
	&& rm -r /usr/src/ghdl

# cocotb
WORKDIR /root/
RUN yum install -y which
RUN pip install cocotb

# custom dependencies
RUN pip install scapy

# WORKDIR
WORKDIR /home/workspace


