![OpenWrt logo](include/logo.png)

OpenWrt Project is a Linux operating system targeting embedded devices. Instead
of trying to create a single, static firmware, OpenWrt provides a fully
writable filesystem with package management. This frees you from the
application selection and configuration provided by the vendor and allows you
to customize the device through the use of packages to suit any application.
For developers, OpenWrt is the framework to build an application without having
to build a complete firmware around it; for users this means the ability for
full customization, to use the device in ways never envisioned.

Sunshine!

### This project is based on OpenWrt

## Supported Spacemit Device

1. MUSE Pi Pro

**Currently, it only supports booting from a micro SD card, and rootfs only supports ext4.**

## Download Pre-built image

https://github.com/chainsx/openwrt-spacemit/releases

### Requirements

You need the following tools to compile OpenWrt, the package names vary between
distributions. A complete list with distribution specific packages is found in
the [Build System Setup](https://openwrt.org/docs/guide-developer/build-system/install-buildsystem)
documentation.

```
binutils bzip2 diff find flex gawk gcc-6+ getopt grep install libc-dev libz-dev
make4.1+ perl python3.7+ rsync subversion unzip which
```

### Quickstart

1. Run `./scripts/feeds update -a` to obtain all the latest package definitions
   defined in feeds.conf / feeds.conf.default

2. Run `./scripts/feeds install -a` to install symlinks for all obtained
   packages into package/feeds/

3. Run `make menuconfig` to select your preferred configuration for the
   toolchain, target system & firmware packages.

4. Run `make` to build your firmware. This will download all sources, build the
   cross-compile toolchain and then cross-compile the GNU/Linux kernel & all chosen
   applications for your target system.


## License

OpenWrt is licensed under GPL-2.0

## Reference

https://github.com/openwrt/openwrt.git

https://gitee.com/bianbu-linux/openwrt.git

https://gitee.com/bianbu-linux/linux-6.6.git

https://gitee.com/bianbu-linux/opensbi.git

https://gitee.com/bianbu-linux/uboot-2022.10.git

https://github.com/armbian/build.git
