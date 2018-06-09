#!/bin/bash

./prepare.sh

for board in roadrunner acqua aria arietta xterm-01 foxg20
do
  ./kernel.sh ${board}
done
