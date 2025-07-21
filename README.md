# CH32V003
Minimal Standalone CH32V003 Build Environment (No CH32Fun)

---

## About

This repository is an cleaner extension of <https://github.com/maxgerhardt/ch32v003-vanilla-gcc>.
It uses the original HAL code provided by WCH whilst using regular gcc toolchain (riscv-none-elf-gcc)
which you can easily setup by running `setup_toolchain.sh` (It setups [riscv-none-elf-gcc-xpack](<https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack>)).

The aim is to provide a minimal environment that's CLI oriented. The
repository contains a main `build.sh` script responsible for building/cleaning.
It uses `ccache` (If available) to do incremental builds.

The repository also has GitHub Actions setup inside `.github/workflows/build.yml`
file. It sets up the toolchain (caches it to speedup further CI builds) & builds
in both debug & release mode. The built binaries are then uploaded as artifacts.

Other stuff that might be worth looking into:
- <https://github.com/basilhussain/ch32v003-startup>

## License
All the non-WCH code in this repository is under public domain license.

---

# Thanks
