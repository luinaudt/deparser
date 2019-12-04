#!/bin/bash
docker run --rm -it -v $PWD:/home/workspace cocotb:v1 ./.run_sim.sh
