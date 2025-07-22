#!/bin/sh

set -eu

TC=${TC:-"$(realpath ./toolchain/main/bin/)"}
CC=${CC:-"$TC/riscv-none-elf-gcc"}
LD=${LD:-"$TC/riscv-none-elf-gcc"}
OBJC=${OBJC:-"$TC/riscv-none-elf-objcopy"}

FLAGS=${FLAGS:-'-march=rv32ec_zifencei_zicsr'}
FLAGS="$FLAGS -mabi=ilp32e -msave-restore -nostartfiles -nodefaultlibs -nostdlib --specs=nano.specs --specs=nosys.specs"
CFLAGS='-std=c99 -fasm -Wall -Wextra -pedantic -Isrc/ -Ihal/Core/ -Ihal/Debug -Ihal/Peripheral/inc -Ihal/User -fdata-sections -ffunction-sections -msmall-data-limit=8'
LFLAGS='-T hal/Ld/Link.ld -Wl,--gc-sections -Wl,--print-memory-usage -Wl,-Bstatic -lgcc'

CMD=${1:-}
BUILD="build"
BIN="$BUILD/firmware.bin"
SOURCES="src/main.c $(find hal/ -type f -name '*.c' -o -name '*.S')"
OBJECTS="$(echo "$SOURCES" | sed "s|\([^ ]*\)\.c|$BUILD/\1.c.o|g")"

export CCACHE_DIR="$BUILD/.ccache"
mkdir -p $BUILD $CCACHE_DIR

if [ "$CMD" = "clean" ]; then
	rm -rf $BIN $BUILD
	exit 0
elif [ "$CMD" = "bear" ]; then
	bear --append --output "$BUILD/compile_commands.json" -- "$0" # github.com/rizsotto/Bear
	exit 0
elif [ "$CMD" = "release" ]; then
	CFLAGS="$CFLAGS -DBUILD_RELEASE=1"
elif [ "$CMD" = "" ]; then
	CFLAGS="$CFLAGS -DBUILD_DEBUG=1"
elif [ "$CMD" ]; then
	echo "Invalid command '$CMD', Available commands are: clean/bear/assets/release or none to just build in debug mode."
	exit 1
fi

if ! [ -x "$(command -v ccache)" ]; then CCACHE=""; else CCACHE="ccache"; fi

echo "$SOURCES 0" | tr ' ' '\n' | while read -r source; do
	if [ "$source" = "0" ]; then wait; exit 0; fi
	echo "Compiling $source"
	mkdir -p "$(dirname "$BUILD/$source.o")"

	"$CCACHE" "$CC" $FLAGS $CFLAGS -c "$source" -o "$BUILD/$source.o" &
done

echo "  Linking $BIN.elf"
"$CCACHE" "$LD" $OBJECTS $FLAGS $LFLAGS -o "$BIN.elf"

echo "  Objcopy $BIN"
"$CCACHE" "$OBJC" -O binary "$BIN.elf" "$BIN"
