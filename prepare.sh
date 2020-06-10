#!/bin/bash

set -e
BASE=$(dirname $(realpath $0))
cd $BASE

# use latest 4.19 kernel
KERNEL_URL=$(curl -s https://www.kernel.org/|perl -ne '/"(.*linux-4\.19.*?)".*tarball/ && print $1,$/')
KERNEL_TGZ=`basename ${KERNEL_URL}`
KERNEL_DIR=${KERNEL_TGZ%\.t*}

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

if [ ! -f ${KERNEL_TGZ} ]; then
  wget ${KERNEL_URL}
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

if [ ! -d ${KERNEL_DIR} ]; then
  tar xvf downloads/${KERNEL_TGZ}
  cd ${KERNEL_DIR}
  patch -p1 < ../patches/linux-4.19.patch
  cd ..
fi

if [ -L linux-src ]; then
  rm linux-src
fi

ln -sf ${KERNEL_DIR} linux-src
