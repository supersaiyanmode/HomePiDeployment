#!/bin/sh

DEVICE=$1
ARCH_PATH=$2
PARITION_PREFIX=p
BOOT_MOUNT_POINT=/mnt/PiBoot
MAIN_MOUNT_POINT=/mnt/Pi


if [ "$1" == "" ]; then
  echo "No device specified." 1>&2
  exit 1
fi

if [ "$ARCH_PATH" == "" ] || [ ! -f $ARCH_PATH ]; then
  echo "Expected path to ArchLinuxARM-rpi-2-latest.tar.gz file." 1>&2
  exit 1
else
  ARCH_PATH=$(readlink -f $ARCH_PATH)
  echo "Using: $ARCH_PATH"
fi

if [ ! -d $BOOT_MOUNT_POINT ]; then
  echo "Mount point for boot does not exist." 1>&2
  exit 1
fi

if [ ! -d $MAIN_MOUNT_POINT ]; then
  echo "Mount point for main does not exist." 1>&2
  exit 1
fi



# From https://superuser.com/a/984637/25705
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${DEVICE}
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk
  +100M # 100 MB boot parttion
  t #
  c # W95 FAT32 LBA
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

if [ $? -ne 0 ]; then
  echo "Unable to create partition table." 1>&2
  exit 1;
fi


BOOT_PARTITION=${DEVICE}${PARITION_PREFIX}1
MAIN_PARTITION=${DEVICE}${PARITION_PREFIX}2

if [ ! -b $BOOT_PARTITION ]; then
  echo "Unable to find boot partition: $BOOT_PARTITION" 1>&2
  exit 1
fi

if [ ! -b $MAIN_PARTITION ]; then
  echo "Unable to find the main parition: $MAIN_PARTITION" 1>&2
  exit 1
fi

mkfs.vfat $BOOT_PARTITION
mkfs.ext4 $MAIN_PARTITION


mount $BOOT_PARTITION $BOOT_MOUNT_POINT
if [ $? -ne 0 ]; then
  echo "Unable to mount boot partition." 1>&2
  exit 1
fi

mount $MAIN_PARTITION $MAIN_MOUNT_POINT
if [ $? -ne 0 ]; then
  echo "Unable to mount main partition." 1>&2
  exit 1
fi


su << EOF
  bsdtar -xpf $ARCH_PATH -C $MAIN_MOUNT_POINT
  sync
  mv $MAIN_MOUNT_POINT/boot/* $BOOT_MOUNT_POINT/.
EOF

umount $MAIN_MOUNT_POINT
umount $BOOT_MOUNT_POINT

echo "All done!"

