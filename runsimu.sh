#!/bin/bash
singularity run cocotb_v1.3 ./.run_sim.sh $@
#docker run --rm -it -v $PWD:/home/workspace cocotb:v1 ./.run_sim.sh $@


