#!/bin/sh

# Installs riscv-none-elf-gcc toolchain in toolchain/main

set -eu

if ! [ -x "$(command -v wget)" ]; then echo "# wget not found!"; exit 1; fi

ver=${TOOLCHAIN_VERSION:-'14.2.0-3'}
tc="xpack-riscv-none-elf-gcc-$ver"
tc_tar="$tc-linux-x64.tar.gz"
tc_url="https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v$ver/$tc_tar"

mkdir -p toolchain
cd toolchain/

if ! [ -e "$tc_tar" ]; then
	echo "# Download $tc_tar"
	wget -q --show-progress "$tc_url" -O "$tc_tar"
fi

if ! [ -d "main" ]; then
	echo "# Extract $tc_tar"
	tar -xf "$tc_tar"
	mv $tc main/
fi
