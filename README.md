This repo contains the VHDL code ans the simulation element for a deparser.
The code is developped on fedora30.
Cocotb 1.3.1 is used and can be install using : `pip install cocotb`
Scapy 2.4.3 and bitstring 3.1.7 are used : `pip install -Iv scapy==2.4.3 bitstring==3.1.7`
ghdl0.37-dev : `sudo dnf install ghdl`

About cocotb :
https://github.com/cocotb/cocotb

# build docker
docker build . -t cocotb:v1

# build singularity
singularity build --fakeroot cocotb_v1.3.simg cocotb.def

# launch simulation
./runsimu.sh

# project organisation :
deparser.pod
open with projectlibre : https://www.projectlibre.com/
