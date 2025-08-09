#!/bin/sh

set -eu

export TC=${TC:-~/.local/opt/MRS_Toolchain/RISC-V\ Embedded\ GCC12/bin}
export CC=riscv-wch-elf-gcc
export LD=riscv-wch-elf-gcc
export OBJC=riscv-wch-elf-objcopy
export FLAGS='-march=rv32ecxw -msmall-data-limit=0'
export LFLAGS='-lprintf'
export BUILD='build'

if [ "${1:-}" = "bear" ]; then
	mkdir -p "$BUILD"
	bear --append --output "$BUILD/compile_commands.json" -- "$0" # github.com/rizsotto/Bear
	exit 0
fi

./build.sh "$@"
