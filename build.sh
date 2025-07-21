#!/bin/sh

set -eu

CC=${CC:-riscv-none-elf-gcc}
LD=${LD:-riscv-none-elf-gcc}
OBJC=${OBJCOPY:-riscv-none-elf-objcopy}
CMD=${1:-}
BUILD="build"
BIN="$BUILD/firmware.bin"
FLAGS='-march=rv32ec_zicsr -mabi=ilp32e -msave-restore -nostartfiles -nodefaultlibs -nostdlib -T hal/Link_CH32V00x.ld'
CFLAGS='-std=c99 -fasm -Wall -Wextra -pedantic -Isrc/ -Ihal/ -fdata-sections -ffunction-sections -msmall-data-limit=8'
LFLAGS='-Wl,--gc-sections -Wl,--print-memory-usage -Wl,-Bstatic -lgcc'
SOURCES="src/main.c hal/startup_ch32v00x.S hal/debug.c hal/core_riscv.c hal/system_ch32v00x.c hal/ch32v00x_adc.c hal/ch32v00x_dbgmcu.c hal/ch32v00x_dma.c hal/ch32v00x_exti.c hal/ch32v00x_flash.c hal/ch32v00x_gpio.c hal/ch32v00x_i2c.c hal/ch32v00x_iwdg.c hal/ch32v00x_misc.c hal/ch32v00x_opa.c hal/ch32v00x_pwr.c hal/ch32v00x_rcc.c hal/ch32v00x_spi.c hal/ch32v00x_tim.c hal/ch32v00x_usart.c hal/ch32v00x_wwdg.c"
OBJECTS="$(echo "$SOURCES" | sed "s|\([^ ]*\)\.c|$BUILD/\1.c.o|g")"
MAYBE_WAIT=""

PATH="$(realpath toolchain/main/bin):$PATH"
CCACHE_DIR="$BUILD/.ccache"

export PATH CCACHE_DIR
mkdir -p $BUILD $CCACHE_DIR

if [ "$(uname -s)" = "Windows_NT" ] || [ "$(uname -o)" = "Cygwin" ]; then
	# On BusyBox.exe, It seems to run out of memory if too many commands are spawned.
	# So we just wait it out.
	MAYBE_WAIT="wait"
fi

if [ "$CMD" = "clean" ]; then
	rm -rf $BIN $BUILD
	exit 0
elif [ "$CMD" = "bear" ]; then
	bear --append --output "$BUILD/compile_commands.json" -- "$0" # github.com/rizsotto/Bear
	exit 0
elif [ "$CMD" = "release" ]; then
	CFLAGS="$CFLAGS -O3 -DBUILD_RELEASE=1"
elif [ "$CMD" = "" ]; then
	CFLAGS="$CFLAGS -O0 -g3 -DBUILD_DEBUG=1"
elif [ "$CMD" ]; then
	echo "Invalid command '$CMD', Available commands are: clean/bear/assets/release or none to just build in debug mode."
	exit 1
fi

if ! [ -x "$(command -v ccache)" ]; then CCACHE=""; else CCACHE="ccache"; fi

echo "$SOURCES 0" | tr ' ' '\n' | while read -r source; do
	if [ "$source" = "0" ]; then wait; exit 0; fi
	echo "Compiling $source"
	mkdir -p "$(dirname "$BUILD/$source.o")"

	$CCACHE $CC $FLAGS $CFLAGS -c "$source" -o "$BUILD/$source.o" &
	$MAYBE_WAIT
done

echo "  Linking $BIN.elf"
$CCACHE $LD $OBJECTS $FLAGS $LFLAGS -o "$BIN.elf"

echo "  Objcopy $BIN"
$CCACHE $OBJC -O binary "$BIN.elf" "$BIN"
