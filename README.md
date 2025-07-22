# CH32V003
Minimal CLI Oriented CH32V003 Build Environment (No CH32Fun)

---

## About

This repository provides a minimal cli-oriented build environment
for CH32V003 applications. This environment uses the [HAL provided
by WCH](https://www.wch.cn/downloads/CH32V003EVT_ZIP.html).

The `build.sh` script is responsible for building your code. By default
`build.sh` is configured to use [riscv-none-elf-gcc-xpack](<https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack>)
toolchain (Assumed to be installed in `./toolchain`). You can run the
`./setup_toolchain.sh` script to install this toolchain in the appropriate
location or you can override the `TC` environment variable to point
to the `bin/` directory of your toolchain.

Using toolchains like `riscv-none-elf-gcc-xpack` means you cannot use
features like `WCH-Interrupt-fast` that are found in the proprietary
toolchain by WCH. If you wish to use the proprietary toolchain, You
can run `build-wch.sh` script instead. But before doing that you must
download the proprietary toolchain from <https://www.mounriver.com/download>
& Extract it to a location. You can then either update the `TC` variable
inside `build-wch.sh` or `TC` environment variable to point to your
toolchain's `bin/` directory.

The build scripts use `ccache` to do incremental builds & The repository
also has GitHub Actions setup inside `.github/workflows/build.yml` file.
It sets up the toolchain (caches it to speedup further CI builds) & builds
in both debug & release mode. The built binaries are then uploaded as artifacts.

Other stuff that might be worth looking into:
- <https://github.com/basilhussain/ch32v003-startup>

## License
All the non-WCH code in this repository is under public domain license.

---

# Thanks
