#!/bin/sh
#
# Copyright 2020-2025 The OpenSSL Project Authors. All Rights Reserved.
#
# Licensed under the Apache License 2.0 (the "License").  You may not use
# this file except in compliance with the License.  You can obtain a copy
# in the file LICENSE in the source distribution or at
# https://www.openssl.org/source/license.html

#
# OpenSSL external testing using the GOST provider from gost-engine
#
set -eu

PWD="$(pwd)"

SRCTOP="$(cd "$SRCTOP"; pwd)"
BLDTOP="$(cd "$BLDTOP"; pwd)"

if [ "$SRCTOP" != "$BLDTOP" ] ; then
    echo "Out of tree builds not supported with gost_engine test!"
    exit 1
fi

GOST_DIR="$SRCTOP/gost-engine"
BUILD_DIR="$GOST_DIR/build"
O_EXE="$BLDTOP/apps"
O_LIB="$BLDTOP"

if [ ! -f "$GOST_DIR/CMakeLists.txt" ] ; then
    echo "gost-engine sources not available at $GOST_DIR"
    exit 1
fi

if [ -d "$SRCTOP/.git" ] ; then
    git -C "$SRCTOP" submodule update --init --recursive gost-engine
fi

unset OPENSSL_CONF

export PATH="$O_EXE:$PATH"
export LD_LIBRARY_PATH="$O_LIB${LD_LIBRARY_PATH+:$LD_LIBRARY_PATH}"
export DYLD_LIBRARY_PATH="$O_LIB${DYLD_LIBRARY_PATH+:$DYLD_LIBRARY_PATH}"
export OPENSSL_ROOT_DIR="$BLDTOP"
export CTEST_OUTPUT_ON_FAILURE=1

OPENSSL_VERSION="$(openssl version | cut -f 2 -d ' ')"

echo "------------------------------------------------------------------"
echo "Testing OpenSSL using GOST provider from gost-engine:"
echo "   CWD:                  $PWD"
echo "   SRCTOP:               $SRCTOP"
echo "   BLDTOP:               $BLDTOP"
echo "   GOST_DIR:             $GOST_DIR"
echo "   OPENSSL_ROOT_DIR:     $OPENSSL_ROOT_DIR"
echo "   OpenSSL version:      $OPENSSL_VERSION"
echo "------------------------------------------------------------------"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake "$GOST_DIR" \
    -DOPENSSL_ROOT_DIR="$OPENSSL_ROOT_DIR" \
    -DOPENSSL_ENGINES_DIR="$OPENSSL_ROOT_DIR/engines" \
    -DGOST_BUILD_ENGINE=OFF \
    -DTLS13_PATCHED_OPENSSL=1

make
make test
make tcl_tests_provider
