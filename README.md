# CH32V003
Minimal CLI Oriented CH32V003 Build Environment (No CH32Fun)

---

## About

This repository is a cleaner extended version of <https://github.com/maxgerhardt/ch32v003-vanilla-gcc>.
It's meant to provide a minimal CLI oriented build environment for CH32V003.
The repository uses the original HAL (Inside `hal/`) provided by WCH whilst
using regular gcc toolchain which you can easily setup by running `setup_toolchain.sh`
(Which setups [riscv-none-elf-gcc-xpack](<https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack>)).

The repository contains a `build.sh` script responsible for building/cleaning
your code. It uses `ccache` (If available) to do incremental builds.

The repository also has GitHub Actions setup inside `.github/workflows/build.yml`
file. It sets up the toolchain (caches it to speedup further CI builds) & builds
in both debug & release mode. The built binaries are then uploaded as artifacts.

Other stuff that might be worth looking into:
- <https://github.com/basilhussain/ch32v003-startup>

## License
All the non-WCH code in this repository is under public domain license.

---

# Thanks
