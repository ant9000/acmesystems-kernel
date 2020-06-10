#!/bin/bash

set -e
BASE=$(dirname $(realpath $0))
cd $BASE

# select board
BOARD=$1
if [ -z $BOARD ]; then
  echo "Usage: `basename $0` (roadrunner|acqua|aria|arietta|xterm-01|foxg20) [...]"
  exit 1
fi
shift

# select toolchain
TOOLCHAIN=arm-linux-gnueabi-
case "$BOARD" in
  roadrunner|acqua)
    TOOLCHAIN=arm-linux-gnueabihf-
    ;;
  aria|arietta|xterm-01|foxg20)
    ;;
  *)
    echo "Unsupported board '$BOARD'"
    exit 1
    ;;
esac

# prepend toolchain to path (unless compiler is already available)
if [ ! `which ${TOOLCHAIN}-gcc` ]; then
  export PATH=$PATH:$BASE/toolchains/gcc-linaro-4.9.4-2017.01-x86_64_${TOOLCHAIN%-}/bin/
fi

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
DTB_KERNEL=acme-${BOARD}.dtb
case "$BOARD" in
  roadrunner)
    DTB_KERNEL=acme-roadrunner-bertad2.dtb
    ;;
esac
make $MAKE_ARGS zImage modules $DTB_KERNEL

DEPLOY=$BASE/deploy/$BOARD
rm -rf $DEPLOY
make $MAKE_ARGS modules_install INSTALL_MOD_PATH=$DEPLOY
mkdir $DEPLOY/boot/
DTB_BOARD=$DTB_KERNEL
IMG_BOARD=zImage
case "$BOARD" in
  acqua)
    DTB_BOARD=at91-sama5d3_acqua.dtb
    ;;
  aria)
    DTB_BOARD=at91-ariag25.dtb
    ;;
  xterm-01)
    DTB_BOARD=acme-arietta.dtb
    ;;
  foxg20)
    DTB_BOARD=""
    IMG_BOARD=uImage
    ;;
  roadrunner)
    DTB_BOARD=acme-roadrunner.dtb
    ;;
esac
if [ ! -z $DTB_BOARD ]; then
  cp arch/arm/boot/zImage $DEPLOY/boot/$IMG_BOARD
  cp arch/arm/boot/dts/$DTB_KERNEL $DEPLOY/boot/$DTB_BOARD
else
  cat arch/arm/boot/zImage arch/arm/boot/dts/$DTB_KERNEL > $DEPLOY/boot/$IMG_BOARD
fi

make $MAKE_ARGS bindeb-pkg
mkdir $DEPLOY/root
cp ../linux-headers* ../linux-libc-dev* $DEPLOY/root/
