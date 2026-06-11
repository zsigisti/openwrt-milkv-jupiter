# OpenWrt for the Milk-V Jupiter (SpacemiT K1)

A buildable [OpenWrt](https://openwrt.org/) port for the **[Milk-V Jupiter](https://milkv.io/jupiter)** — the Mini-ITX single-board computer powered by the 8-core RISC-V **SpacemiT K1** SoC.

This repository is a fork of [`chainsx/openwrt-spacemit`](https://github.com/chainsx/openwrt-spacemit) (itself a fork of upstream OpenWrt 24.10) with a Milk-V Jupiter image target added and a reproducible, containerised build that works on modern host systems.

> ### 🤖 Built with AI
> This port — the device profile, the build fixes, the container setup, and this README — was created by **Anthropic's Claude (Claude Code)** working from the upstream sources. It is shared as-is in the hope it's useful. Treat it as a community/AI contribution: review before relying on it, and see the [boot caveat](#-boot-caveat-read-before-flashing) below.

---

## Hardware

| | |
|---|---|
| **SoC** | SpacemiT K1 — 8× X60 RISC-V cores (RVA22 + RVV 1.0) |
| **Board** | Milk-V Jupiter (Mini-ITX) |
| **Kernel** | Linux 6.6.63 |
| **Base** | OpenWrt 24.10 |
| **Boot media** | microSD card (eMMC untested here) |

---

## Quick start — build it yourself

You need **Docker** (or Podman) and ~25 GB of free disk. The build runs inside a
Debian Bookworm container, so it does **not** matter how new or old your host's
compiler is.

```bash
git clone https://github.com/zsigisti/openwrt-milkv-jupiter.git
cd openwrt-milkv-jupiter
./scripts/build-jupiter.sh
```

When it finishes, the images are in `bin/targets/spacemit/`:

| Image | When to use |
|-------|-------------|
| `…-Milkv-Jupiter-squashfs-sdcard.img.gz` | **Recommended.** squashfs + writable overlay; supports factory reset & sysupgrade. |
| `…-Milkv-Jupiter-ext4-sdcard.img.gz` | Fully writable ext4 rootfs. |

> Prefer Podman? `CONTAINER=podman ./scripts/build-jupiter.sh`.

---

## Flash to an SD card

Replace `/dev/sdX` with your card (double-check with `lsblk` — this erases the target):

```bash
zcat bin/targets/spacemit/openwrt-spacemit-k1-sbc-Milkv-Jupiter-squashfs-sdcard.img.gz \
  | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
```

Insert the card into the Jupiter and power on. By default OpenWrt brings up its
LAN on **192.168.1.1**; connect and browse to <http://192.168.1.1> (LuCI) or
`ssh root@192.168.1.1`.

---

## ⚠️ Boot caveat (read before flashing)

The early boot blobs in this tree (`FSBL.bin`, `u-boot.itb`, OpenSBI `fw_dynamic.itb`,
under `target/linux/spacemit/image/`) are **prebuilt and shared across all K1 boards**
— they are not regenerated per device. FSBL performs DDR training and PMIC bring-up,
which *can* be board-specific.

Because the Jupiter is a K1-x board there is a good chance these generic blobs work,
but **first-boot on real hardware is not guaranteed**. If the board hangs at early
boot, swap in Milk-V's own Jupiter bootloader and re-flash the boot sectors. The
correct `k1-x_milkv-jupiter.dtb` is already built and installed by this image.

---

## What was changed vs. upstream

- **`target/linux/spacemit/image/k1-sbc.mk`** — added a `Device/Milkv-Jupiter`
  image profile (DTS `spacemit/k1-x_milkv-jupiter`). The Jupiter device tree already
  existed in the tree, but had no image target.
- **`configs/jupiter.config`** — seed config selecting the Jupiter target and bumping
  the boot partition to 64 MB (the kernel `Image.itb` is ~23 MB and overflowed the
  default 16 MB partition).
- **`docker/Dockerfile` + `scripts/build-jupiter.sh`** — reproducible containerised
  build so the tree compiles on any host regardless of host-compiler version.
- **`tools/cmake/patches/170-*`, `171-*`** — fix the bundled CMake 3.30.5 bootstrap
  on very new host GCC (the GHS generator vtable leaking into `cmake.o`). Only needed
  for direct host builds; harmless under the container build.
- **`toolchain/gcc/common.mk`** — adds `-fno-char8_t` to the cross-GCC host CXXFLAGS so
  `libcody` builds on hosts whose compiler defaults to a newer C++ standard. Likewise
  only relevant to direct host builds.

---

## License

This project is distributed under the **[GNU General Public License v2.0](COPYING)**
(`GPL-2.0`), the same license as upstream OpenWrt and the Linux kernel it is built on.

GPL-2.0 is a strong **copyleft** license: anyone who distributes this software or a
modified version **must** make the complete corresponding source available under the
same terms. That is what keeps this — and everything derived from it — **open source,
permanently**. A permissive license (MIT/BSD/Apache) cannot be applied here, both
because it would allow the code to be closed and because the tree contains
`GPL-2.0-only` components that are legally incompatible with relicensing.

Individual files retain their original SPDX headers and licenses (see `LICENSES/`).

---

## Credits

- **[OpenWrt](https://openwrt.org/)** — the upstream project and build system.
- **[chainsx/openwrt-spacemit](https://github.com/chainsx/openwrt-spacemit)** — the
  SpacemiT K1 target this port builds on.
- **[SpacemiT](https://www.spacemit.com/)** & **[Milk-V](https://milkv.io/)** — the
  K1 SoC and Jupiter hardware.
- **Anthropic Claude** — produced this port and documentation.

Upstream OpenWrt's original README is preserved as [`README.OpenWrt.md`](README.OpenWrt.md).
