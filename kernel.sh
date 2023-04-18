#!/bin/bash

set -e
BASE=$(dirname $(realpath $0))
cd $BASE

# select board
BOARD=$1
if [ -z $BOARD ]; then
  echo "Usage: `basename $0` (roadrunner|acqua|aria|arietta) [...]"
  exit 1
fi
shift

# select toolchain
case "$BOARD" in
  roadrunner|acqua)
    TOOLCHAIN=arm-linux-gnueabihf-
    ;;
  aria|arietta)
    TOOLCHAIN=arm-linux-gnueabi-
    ;;
  *)
    echo "Unsupported board '$BOARD'"
    exit 1
    ;;
esac

# compute default makefile arguments
MAKE_ARGS="ARCH=arm CROSS_COMPILE=$TOOLCHAIN"
CPU_COUNT=`grep -c processor /proc/cpuinfo || true`
if [ $CPU_COUNT -gt 0 ]; then
  MAKE_ARGS="-j$CPU_COUNT $MAKE_ARGS"
fi

# create default config for the board (unless it is already in place)
if [ ! -d $BASE/build/$BOARD/out ]; then
  mkdir -p $BASE/build/$BOARD/out
  cd $BASE/linux-src
  make mrproper
  make O=$BASE/build/$BOARD/out $MAKE_ARGS acme-${BOARD}_defconfig
fi

# if we have other arguments, pass them to kernel build system - then exit
cd $BASE/build/$BOARD/out
if [ ! -z $1 ]; then
  make $MAKE_ARGS $*
  exit 0
fi

# compile kernel, modules and dtb
make $MAKE_ARGS zImage modules acme-${BOARD}.dtb

DEPLOY=$BASE/deploy/$BOARD
rm -rf $DEPLOY
make $MAKE_ARGS modules_install INSTALL_MOD_PATH=$DEPLOY
mkdir $DEPLOY/boot/
cp arch/arm/boot/zImage $DEPLOY/boot/
cp arch/arm/boot/dts/acme-${BOARD}.dtb $DEPLOY/boot/
wget https://www.acmesystems.it/www/compile_kernel_5_15/acme-${BOARD}_cmdline.txt -O $DEPLOY/boot/cmdline.txt

make $MAKE_ARGS bindeb-pkg
mkdir $DEPLOY/root
for x in image headers libc-dev
do
  deb=$(ls -t ../linux-${x}*.deb|head -1)
  [ ! -z "$deb" ] && cp $deb $DEPLOY/root/
done
