FROM fedora:latest

ARG ICARUS_VERILOG_VERSION=10_3
ARG GHDL_VERSION=0.36

RUN dnf update
RUN dnf install -y g++ clang git make gperf flex bison \
	python3-devel python2-devel python2-pip python3-pip \
	python2-setuptools python3-setuptools python2-virtualenv \
	python3-virtualenv && dnf autoclean && && pip install --upgrade pip


# Icarus Verilog 
ENV ICARUS_VERILOG_VERSION=${ICARUS_VERILOG_VERSION} 
WORKDIR /usr/src/iverilog
RUN git clone https://github.com/steveicarus/iverilog.git --depth=1 --branch v${ICARUS_VERILOG_VERSION} . \
	&& sh autoconf.sh \
	&& ./configure \
	&& make -s ${MAKE_JOBS} \
	&& make -s install \
	&& rm -r /usr/src/iverilog

# cocotb
ENV GHDL_VERSION=${GHDL_VERSION} 
WORKDIR /usr/src/ghdl
RUN git clone https://github.com/ghdl/ghdl.git --depth=1 --branch v${GHDL_VERSION} . \
	&& ./configure --prefix=/usr/local \
	&& make \
	&& make install \
	&& rm -r /usr/src/ghdl

# cocotb
WORKDIR /root/
RUN pip install cocotb


