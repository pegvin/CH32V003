#!/bin/sh

set -eu

export TC=${TC:-"$(realpath ~/.local/opt/MRS_Toolchain/RISC-V\ Embedded\ GCC12/bin)"}
export CC="$TC/riscv-wch-elf-gcc"
export LD="$TC/riscv-wch-elf-gcc"
export OBJC="$TC/riscv-wch-elf-objcopy"
export FLAGS='-march=rv32ecxw'

./build.sh $@
