# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Spacemit Ltd.

define Device/MUSE-Pi-Pro
  DEVICE_VENDOR := Spacemit
  DEVICE_MODEL :=MUSE Pi Pro
  DEVICE_DTS := spacemit/k1-x_MUSE-Pi-Pro
  SOC := KeyStone
  DEVICE_PACKAGES := kmod-rtl8852bs wpad
endef
TARGET_DEVICES += MUSE-Pi-Pro

define Device/MUSE-Pi
  DEVICE_VENDOR := Spacemit
  DEVICE_MODEL :=MUSE Pi
  DEVICE_DTS := spacemit/k1-x_MUSE-Pi
  SOC := KeyStone
  DEVICE_PACKAGES := kmod-rtl8852bs wpad
endef
TARGET_DEVICES += MUSE-Pi

define Device/LicheePi-3A
  DEVICE_VENDOR := Spacemit
  DEVICE_MODEL :=LicheePi 3A
  DEVICE_DTS := spacemit/k1-x_lpi3a
  DEVICE_PACKAGES := kmod-aic8800s wpad
  SOC := KeyStone
endef
TARGET_DEVICES += LicheePi-3A

define Device/DEB1
  DEVICE_VENDOR := Spacemit
  DEVICE_MODEL :=k1-x deb1 board
  DEVICE_DTS := spacemit/k1-x_deb1
  SOC := KeyStone
  DEVICE_PACKAGES := kmod-rtl8852bs wpad
endef
TARGET_DEVICES += DEB1

define Device/DEB2
  DEVICE_VENDOR := Spacemit
  DEVICE_MODEL :=k1-x deb2 board
  DEVICE_DTS := spacemit/k1-x_deb2
  SOC := KeyStone
  DEVICE_PACKAGES := kmod-rtl8852bs wpad
endef
TARGET_DEVICES += DEB2

# Userspace stack for the Jupiter's M.2/PCIe NVMe slot. The NVMe block driver,
# the K1 PCIe root complex (CONFIG_PCI_K1X) and the combo-PHY are already built
# into the kernel; these packages let you partition, format, mount and manage an
# NVMe SSD (incl. extroot — moving the rootfs overlay onto NVMe).
JUPITER_NVME_PACKAGES := nvme-cli fdisk e2fsprogs f2fs-tools block-mount

define Device/Milkv-Jupiter
  DEVICE_VENDOR := Milk-V
  DEVICE_MODEL := Jupiter
  DEVICE_DTS := spacemit/k1-x_milkv-jupiter
  SOC := KeyStone
  DEVICE_PACKAGES := kmod-rtl8852bs wpad $(JUPITER_NVME_PACKAGES)
endef
TARGET_DEVICES += Milkv-Jupiter
