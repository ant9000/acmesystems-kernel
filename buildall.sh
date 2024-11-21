#!/bin/bash

./prepare.sh

for board in foxd27 roadrunner acqua aria arietta
do
  ./kernel.sh ${board}
done
