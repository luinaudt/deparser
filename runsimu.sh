#!/bin/tcsh

## virtual env
#singularity run cocotb_v1.3 ./.run_sim.sh $@
#docker run --rm -it -v $PWD:/home/workspace cocotb:v1 ./.run_sim.sh $@
set SIM=ghdl
#grm
if (-d "/CMC") then #check if on CMC machine
    printf "Exécution sur une machine du grm\n"
    if (! -d ".env_cocotb") then
	    printf "cocotb virtualenv directory does not exist\n"
	if (`where virtualenv` == "") then
	    printf "virtualenv command doesn't not exist\n"
	    printf "Install it using \n"
	    printf "\t pip3 install --user virtualenv \n"
	    printf "and add it to your path : \n"
	    printf "\t echo 'setenv PATH \044PATH\:/users/$USER/.local/bin/' >> ~/.cshrc \n"
	    printf "reload your env : source ~/.cshrc\n "
	    exit -1
	else
	    printf "creating directory for virtualenv .env_cocotb\n"
	    mkdir .env_cocotb
	    printf "creating virtualenv in .env_cocotb\n"
	    stpython37
	    virtualenv .env_cocotb
	    printf "installing dependencies in virtual env \n"
	    source ./.env_cocotb/bin/activate.csh
	    # install dependencies
	    pip install cocotb
	    deactivate   # leave virtual env to keep script stable
	endif
    endif
    stmodelt
    stpython37
    source ./.env_cocotb/bin/activate.csh
endif
if (`where ghdl` != "") then
    printf "ghdl trouvé\n"
    set SIM=ghdl
else if (`where vsim` != "") then
    printf "on utilise vsim\n"
    set SIM=modelsim
else
    printf "aucun simulateur trouvé\n"
    exit -1
endif

#we pass specific arguments
if ($argv == "") then
    set argv="empty"
    set argsToPass = ""
else
    set argsToPass = "$*"
endif

foreach name ( $argv )
    if ("$name" !~ "SIM="*) then
	set argsToPass = "$argsToPass SIM=$SIM"
    endif
end
echo $argsToPass
./.run_sim.sh "$argsToPass"

