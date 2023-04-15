#!/bin/bash

./prepare.sh

for board in roadrunner acqua aria arietta
do
  ./kernel.sh ${board}
done
