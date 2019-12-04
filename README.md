This repo contains the VHDL code ans the simulation element for a deparser.
The code is developped on fedora30.
Cocotb 1.2 is used and can be install using : `pip install cocotb`
ghdl0.37-dev : `sudo dnf install ghdl`

About cocotb :
https://github.com/cocotb/cocotb

# build docker
docker build . -t cocotb:v1

# launch simulation
./runsimu.sh

# deparser
