#!/bin/bash

set -e
BASE=$(dirname $(realpath $0))
cd $BASE

if [ ! -d downloads ]; then
  mkdir downloads
fi

(
cd downloads
if [ ! -f gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi.tar.xz ]; then
  wget http://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabi/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi.tar.xz
fi
if [ ! -f gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf.tar.xz ]; then
  wget http://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabihf/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf.tar.xz
fi

if [ ! -f linux-4.19.123.tar.xz ]; then
  wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.123.tar.xz
fi
)

if [ ! -d toolchains ]; then
  mkdir toolchains
fi

(
cd toolchains
if [ ! -d gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi ]; then
  tar xvf ../downloads/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi.tar.xz
fi

if [ ! -d gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf ]; then
  tar xvf ../downloads/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf.tar.xz
fi
)

if [ ! -d linux-4.19.123 ]; then
  tar xvf downloads/linux-4.19.123.tar.xz
  cd linux-4.19.123
  patch -p1 < ../patches/linux-4.19.patch
  cd ..
fi

ln -sf linux-4.19.123 linux-src
