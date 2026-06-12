# OpenWrt for the Milk-V Jupiter (SpacemiT K1)

A buildable [OpenWrt](https://openwrt.org/) port for the **[Milk-V Jupiter](https://milkv.io/jupiter)** — the Mini-ITX single-board computer powered by the 8-core RISC-V **SpacemiT K1** SoC.

This repository is a fork of [`chainsx/openwrt-spacemit`](https://github.com/chainsx/openwrt-spacemit) (itself a fork of upstream OpenWrt 24.10) with a Milk-V Jupiter image target added and a reproducible, containerised build that works on modern host systems.

> ### 🤖 Built with AI
> This port — the device profile, the build fixes, the container setup, and this README — was created by **Anthropic's Claude (Claude Code)** working from the upstream sources. It is shared as-is in the hope it's useful. Treat it as a community/AI contribution: review before relying on it, and see the [boot caveat](https://github.com/zsigisti/openwrt-milkv-jupiter#%EF%B8%8F-boot-caveat-read-before-flashing) below.

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

## Using NVMe storage

The Jupiter has an M.2 slot on the PCIe root complex. The kernel has the K1 PCIe
controller (`CONFIG_PCI_K1X`), the combo-PHY and the NVMe block driver built in, and
the image ships the userspace tools (`nvme-cli`, `fdisk`, `e2fsprogs`, `f2fs-tools`,
`block-mount`). With an SSD in the slot it should appear as `/dev/nvme0n1`.

> ⚠️ Built and wired up, but **not yet verified on real hardware** — see the status table.

```sh
# 1. Confirm the drive is detected
nvme list
ls -l /dev/nvme*

# 2. Partition it (GUI: cfdisk /dev/nvme0n1)
fdisk /dev/nvme0n1            # e.g. one big Linux partition -> /dev/nvme0n1p1

# 3. Format (ext4, or f2fs which suits flash well)
mkfs.ext4 /dev/nvme0n1p1
# mkfs.f2fs /dev/nvme0n1p1

# 4a. Mount somewhere for data
mkdir -p /mnt/nvme
mount /dev/nvme0n1p1 /mnt/nvme
```

### Move the overlay onto NVMe (extroot)

To give the system real disk space instead of the tiny SD overlay, use OpenWrt
[extroot](https://openwrt.org/docs/guide-user/additional-software/extroot_configuration):

```sh
# copy the current overlay to the NVMe partition, then point fstab at it
mount /dev/nvme0n1p1 /mnt/nvme
tar -C /overlay -cvf - . | tar -C /mnt/nvme -xf -
block detect | uci import fstab
uci set fstab.@mount[-1].target='/overlay'
uci set fstab.@mount[-1].enabled='1'
uci commit fstab
reboot
```

---

## ⚠️ Boot caveat (read before flashing)

The early boot blobs live under `target/linux/spacemit/image/`. The **`FSBL.bin`** —
which performs DDR training and PMIC bring-up, the most board-specific stage — is
taken directly from **Milk-V's official Jupiter Bianbu release (v2.1.1, 2025-03-05)**,
so first-stage bring-up uses the binary Milk-V validates on real Jupiter hardware.

The later stages (OpenSBI `fw_dynamic.itb`, `u-boot.itb`, `env.bin`) are the
OpenWrt-tuned blobs from the upstream port: `env.bin` carries the OpenWrt **extlinux**
boot flow (Milk-V's own env boots GRUB/EFI instead, so it can't be used as-is). The
correct `k1-x_milkv-jupiter.dtb` is built and installed by this image.

**First-boot on real hardware is still not guaranteed** — the Jupiter FSBL is now in
place, but the full FSBL → OpenSBI → U-Boot → extlinux chain has not been verified
end-to-end on a board. If it hangs at early boot, re-flash the boot sectors with
Milk-V's complete official bootloader and report back.

---

## Project status & roadmap

**This firmware is not 100% working yet.** It builds cleanly and produces flashable
images, but it has **not** been verified to boot all the way to a usable system on
real Jupiter hardware (see the [boot caveat](#-boot-caveat-read-before-flashing)).
Treat every release as experimental until the status below says otherwise.

| Area | Status |
|------|--------|
| Build from source (container) | ✅ Works |
| SD-card image generation | ✅ Works |
| First boot on real hardware | ⚠️ Unverified — now uses Milk-V's official Jupiter FSBL (v2.1.1) |
| Ethernet / LAN | ⚠️ Unverified |
| Wi-Fi (RTL8852BS) | ⚠️ Unverified |
| **NVMe / PCIe storage** | 🧪 Supported in image — driver + tooling built in, untested on hardware |
| eMMC boot | ⛔ Not tested |

### Roadmap

- [ ] Confirm first boot on real Milk-V Jupiter hardware
- [ ] Verify Ethernet, Wi-Fi and USB
- [x] **NVMe support** — K1 PCIe root complex + combo-PHY + NVMe block driver are
      built into the kernel, and the image ships `nvme-cli`, partitioning/format
      tools and `block-mount` so an NVMe SSD in the M.2 slot can be used (incl.
      extroot). See [Using NVMe storage](#using-nvme-storage). *(needs hardware
      verification.)*
- [ ] Jupiter-specific boot blobs (FSBL / u-boot) instead of the shared K1 ones
- [ ] eMMC boot / install path
- [ ] Verify NVMe on real hardware and add a boot-from-NVMe path

Found a bug or got it booting? Please open an issue or PR — reports from real
hardware are the most useful thing right now.

---

## Releases, branches & snapshots

This repo uses two long-lived branches and two kinds of release.

| Branch | Purpose |
|--------|---------|
| **`main`** | Stable line. Only tested, tagged states land here. Default branch. |
| **`dev`** | Development line. New work, experiments and roadmap items land here first. |

**Stable releases** are cut from `main` as version tags (`vX.Y.Z`) and show up under
[Releases](https://github.com/zsigisti/openwrt-milkv-jupiter/releases) with the built
`.img.gz` images attached. The first one is `v0.1.0-alpha` and is marked
*pre-release* because the firmware is not fully verified yet.

**Snapshots** are the OpenWrt term for rolling, automatically-built images from the
tip of development — the bleeding edge, rebuilt as `dev` changes, never a fixed
version. Here they work like this:

- A GitHub Actions workflow ([`.github/workflows/snapshot.yml`](.github/workflows/snapshot.yml))
  builds the image whenever `dev` is pushed (or on manual dispatch).
- The result is published to a single rolling pre-release tagged **`snapshot`**, whose
  assets are overwritten on every successful build.
- So <https://github.com/zsigisti/openwrt-milkv-jupiter/releases/tag/snapshot> always
  points at the latest `dev` build.

Rule of thumb: grab a **versioned release** for the most-tested image, or a
**snapshot** if you want the newest changes and don't mind that it's untested.

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
