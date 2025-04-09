#!/bin/bash -e

DTS=$1
if [ -z "$DTS" ]; then
  echo "Usage: $(basename $0) <dts>"
  exit 1
fi

if [ ! -f "$DTS" ]; then
  echo "File '$DTS' not found."
  exit 1
fi

HERE=$(realpath $(dirname $0))
KERNEL=$HERE/linux-src
DTB=${DTS%.dts}.dtb

TMPFILE=$(mktemp)
trap "{ rm -f "${TMPFILE}" ; exit 255; }" SIGINT SIGTERM ERR EXIT

# resolve includes
cpp -nostdinc \
  -I $KERNEL/arch/arm/boot/dts/ \
  -I $KERNEL/include \
  -I $KERNEL/arch \
  -I $KERNEL/arch/arm/boot/dts/ \
  -I $KERNEL/arch/arm/boot/dts/ti/omap/ \
  -undef -x assembler-with-cpp \
  $DTS $TMPFILE

# compile
dtc -q -O dtb -o $DTB $TMPFILE
