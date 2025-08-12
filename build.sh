#!/bin/sh

set -eu

TC=${TC:-./toolchain/main/bin}
CC=${CC:-riscv-none-elf-gcc}
LD=${LD:-riscv-none-elf-gcc}
OBJC=${OBJC:-riscv-none-elf-objcopy}

FLAGS=${FLAGS:-'-march=rv32ec_zifencei_zicsr -msmall-data-limit=8'}
FLAGS="$FLAGS -mabi=ilp32e -msave-restore -nostartfiles -nodefaultlibs -nostdlib --specs=nano.specs --specs=nosys.specs"

CFLAGS=${CFLAGS:-}
CFLAGS="$CFLAGS -std=c99 -fasm -Wall -Wextra -pedantic -Isrc/ -Ihal/Core/ -Ihal/Debug -Ihal/Peripheral/inc -Ihal/User -fdata-sections -ffunction-sections"
CFLAGS="$CFLAGS -DNO_WCH_TOOLCHAIN=1 -DHSE_VALUE=((uint32_t)24000000) -DSDI_PRINT=SDI_PR_OPEN -DDEBUG=DEBUG_UART1_NoRemap -DINTSYSCR_INEST=INTSYSCR_INEST_EN"

LFLAGS=${LFLAGS:-}
LFLAGS="$LFLAGS -T hal/Ld/Link.ld -Wl,--gc-sections -Wl,--print-memory-usage -lgcc"

CMD=${1:-}
BUILD=${BUILD:-"build"}
BIN="$BUILD/firmware.bin"
SOURCES="src/main.c $(ls hal/*/*.S hal/*/*.c hal/*/*/*.c)"
OBJECTS="$(echo "$SOURCES" | sed "s|\([^ ]*\)\.c|$BUILD/\1.c.o|g")"

PATH="$TC:$PATH"
export PATH CCACHE_DIR="$BUILD/.ccache"
mkdir -p $BUILD $CCACHE_DIR

if [ "$CMD" = "clean" ]; then
	rm -rf $BIN $BUILD
	exit 0
elif [ "$CMD" = "bear" ]; then
	bear --append --output "$BUILD/compile_commands.json" -- "$0" # github.com/rizsotto/Bear
	exit 0
elif [ "$CMD" = "flash" ]; then
	wlink flash --enable-sdi-print --chip CH32V003 "$BIN"
	exit 0
elif [ "$CMD" = "serial" ]; then
	cat /dev/ttyACM0
	exit 0
elif [ "$CMD" = "release" ]; then
	CFLAGS="$CFLAGS -DBUILD_RELEASE=1"
elif [ "$CMD" = "" ]; then
	CFLAGS="$CFLAGS -DBUILD_DEBUG=1"
elif [ "$CMD" ]; then
	echo "Invalid command '$CMD', Available commands are: clean/bear/flash/serial/release or none to just build in debug mode."
	exit 1
fi

if ! [ -x "$(command -v ccache)" ]; then CCACHE=""; else CCACHE="ccache"; fi

echo "$SOURCES 0" | tr ' ' '\n' | while read -r source; do
	if [ "$source" = "0" ]; then wait; exit 0; fi
	echo "Compiling $source"
	mkdir -p "$(dirname "$BUILD/$source.o")"

	$CCACHE $CC $FLAGS $CFLAGS -c "$source" -o "$BUILD/$source.o" &
done

echo "  Linking $BIN.elf"
$CCACHE $LD $OBJECTS $FLAGS $LFLAGS -o "$BIN.elf"

echo "  Objcopy $BIN"
$CCACHE $OBJC -O binary "$BIN.elf" "$BIN"
