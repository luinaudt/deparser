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

# compiler un deparser
  1. mettre le code P4 dans le repertoire src/p4/
  2. compiler le code pour l'exporter en json BMV2
  3. aller dans le repertoire src/compiler
  4. executer la commande python3 main.py -o <dossier de sortie> -w <largeur des bus (optionnel)> <nom du/des json sans l'extension>
Les fichier serons mis dans le dossier de sortie avec pour chaque json un dossier : nom_largeur

# executer vivado
  1. aller dans le <dossier de sortie>
  2. exécuter la code python situer dans src/scripts/genBuild.py
  ce code va générer un fichier build.tcl
  3. vivado -mode tcl
  4. source build.tcl