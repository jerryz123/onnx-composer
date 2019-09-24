#!/usr/bin/env bash

set -e
set -o pipefail


# Build riscv tools
(cd rocket-tools && ./build.sh)

# Build LLVM
(cd llvm-project && mkdir -p build && cd build && \
                    cmake -DCMAKE_BUILD_TYPE="Release" \
                          -DLLVM_ENABLE_PROJECTS=clang \
                          -DBUILD_SHARED_LIBS=False \
                          -DLLVM_USE_SPLIT_DWARF=True \
                          -DCMAKE_INSTALL_PREFIX="$RISCV" \
                          -DLLVM_OPTIMIZED_TABLEGEN=True \
                          -DLLVM_BUILD_TESTS=False \
                          -DDEFAULT_SYSROOT="$RISCV/riscv64-unknown-elf" \
                          -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf" \
                          -DLLVM_TARGETS_TO_BUILD="RISCV" \
                          ../llvm)
(cd llvm-project/build && make -j16 install)

# Build Halide
(cd Halide && make -j16 install PREFIX=$RISCV)

# Install python dependencies
python3 -m pip install numpy protobuf

# Build onnx
(cd onnx && git submodule update --init --recursive && \
            python3 setup.py install)

# Install onnx-halide base
python3 -m pip install -e onnx-halide
