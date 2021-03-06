#!/usr/bin/env bash
#
# Copyright 2016-2018, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#
#     * Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#
# run-build.sh - is called inside a Docker container; prepares the environment
#                and starts a build of libpmemobj-cpp.
#

set -e

cd $WORKDIR
INSTALL_DIR=/tmp/pmdk-convert

mkdir $INSTALL_DIR

cp /opt/pmdk/*.tar.gz .

# -----------------------------------------
# gcc & Debug

mkdir build
cd build

CC=gcc \
cmake .. -DCMAKE_BUILD_TYPE=Debug \
	-DDEVELOPER_MODE=1 \
	-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
	-DTRACE_TESTS=1 \
	-DMAX_VERSION=1.5

make -j2
ctest --output-on-failure

make install
make uninstall

cd ..
rm -r build

# -----------------------------------------
# gcc & Release

mkdir build
cd build

CC=gcc \
cmake .. -DCMAKE_BUILD_TYPE=Release \
	-DDEVELOPER_MODE=1 \
	-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
	-DTRACE_TESTS=1 \
	-DMAX_VERSION=1.5

make -j2
ctest --output-on-failure

cd ..
rm -r build

# -----------------------------------------
# Clang & Debug

mkdir build
cd build

CC=clang \
cmake .. -DCMAKE_BUILD_TYPE=Debug \
	-DDEVELOPER_MODE=1 \
	-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
	-DTRACE_TESTS=1 \
	-DMAX_VERSION=1.5

make -j2
ctest --output-on-failure

cd ..
rm -r build

# -----------------------------------------
# Clang & Release

mkdir build
cd build

CC=clang \
cmake .. -DCMAKE_BUILD_TYPE=Release \
	-DDEVELOPER_MODE=1 \
	-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
	-DTRACE_TESTS=1 \
	-DMAX_VERSION=1.5

make -j2
ctest --output-on-failure

cd ..
rm -r build

# -----------------------------------------
# Coverage
if [[ $COVERAGE -eq 1 ]] ; then
	mkdir build
	cd build

	CC=gcc \
	cmake .. -DCMAKE_BUILD_TYPE=Debug \
		-DTRACE_TESTS=1 \
		-DMAX_VERSION=1.5 \
		-DCMAKE_C_FLAGS=-coverage

	make -j2
	ctest --output-on-failure
	bash <(curl -s https://codecov.io/bash) -c

	cd ..

	rm -r build
fi
# -----------------------------------------
# deb & rpm

#mkdir build
#cd build

#cmake .. -DCMAKE_INSTALL_PREFIX=/usr \
#		-DCPACK_GENERATOR=$PACKAGE_MANAGER \
#		-DMAX_VERSION=1.5

#make -j2
#ctest --output-on-failure

#make package

#if [ $PACKAGE_MANAGER = "deb" ]; then
#	sudo dpkg -i pmdk-convert*.deb
#elif [ $PACKAGE_MANAGER = "rpm" ]; then
#	sudo rpm -i pmdk-convert*.rpm
#fi

#cd ..
#rm -rf build

# Verify installed package
# pmdk-convert ...

rm -r $INSTALL_DIR
