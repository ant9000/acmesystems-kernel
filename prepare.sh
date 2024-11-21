#!/bin/bash

set -e
BASE=$(dirname $(realpath $0))
cd $BASE

# use latest 5.15 LTS kernel
KERNEL_URL=$(curl -s https://www.kernel.org/|perl -ne '/"(.*linux-6\.1\..*?)".*tarball/ && print $1,$/')
KERNEL_TGZ=`basename ${KERNEL_URL}`
KERNEL_DIR=${KERNEL_TGZ%\.t*}

if [ ! -d downloads ]; then
  mkdir downloads
fi

(
  cd downloads
  if [ ! -f ${KERNEL_TGZ} ]; then
    wget ${KERNEL_URL}
  fi
)

if [ ! -d ${KERNEL_DIR} ]; then
  tar xvf downloads/${KERNEL_TGZ}
  (
    cd ${KERNEL_DIR}
    for board in foxd27 roadrunner acqua aria arietta
    do
      wget https://www.acmesystems.it/www/compile_kernel_6_1/acme-${board}_defconfig \
        -O arch/arm/configs/acme-${board}_defconfig
      wget https://www.acmesystems.it/www/compile_kernel_6_1/acme-${board}.dts \
        -O arch/arm/boot/dts/acme-${board}.dts
    done
  )
fi

if [ -L linux-src ]; then
  rm linux-src
fi

ln -s ${KERNEL_DIR} linux-src

if [ ! `which arm-none-eabi-gcc` ]; then
  sudo apt install gcc-arm-none-eabi
fi
