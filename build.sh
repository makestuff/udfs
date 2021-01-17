#!/bin/sh

CONFIG=Debug
if [ $# -ge 1 ]; then
  CONFIG=$1
fi

# Maybe configure
if [ ! -e build ]; then
  mkdir build
  cd build
  cmake \
    -DCMAKE_BUILD_TYPE=${CONFIG} \
    -DBUILD_TESTING=1 \
    -DCMAKE_VERBOSE_MAKEFILE=0 \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_INSTALL_RPATH=\$ORIGIN/../lib \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    ..
  cd ..
fi

# Maybe build
if [ $# -lt 2 ] || [ $2 != "-nobuild" ]; then
  cmake --build build
  echo 'You can install with "sudo cmake --build build --target install"'
fi
