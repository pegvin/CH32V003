#!/bin/sh

set -eu

export TC=${TC:-~/.local/opt/MRS_Toolchain/RISC-V\ Embedded\ GCC12/bin}
export CC=riscv-wch-elf-gcc
export LD=riscv-wch-elf-gcc
export OBJC=riscv-wch-elf-objcopy
export FLAGS='-march=rv32ecxw'

./build.sh "$@"
