#!/usr/bin/env bash
set -e

#DEVICE="$1"
DEVICE="/dev/sde"

function test-command() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "The command \"$1\" is required.  Try \"apt-get install $2\"."; exit 1; }
}

test-command debootstrap debootstrap
test-command arch-chroot arch-install-scripts
test-command genfstab arch-install-scripts
test-command parted parted

# Download the debs to be used to install debian
if [ ! -e "debs.tar.gz" ]; then
    debootstrap --verbose \
        --make-tarball=debs.tar.gz \
	    --include=linux-image-generic,grub-efi \
	    cosmic rootfs http://archive.ubuntu.com/ubuntu/
fi

# Partition layout:
# 1. EFI boot partition
# 1. The base recovery OS
# 2. Swap
# 3. Darch configuration (/etc/darch)
# 4. Darch stage/images

# Create our hard disk
parted -s ${DEVICE} \
        mklabel gpt \
        mkpart primary 0% 500MiB \
        mkpart primary 500MiB 4GiB \
        mkpart primary 4GiB 8GiB \
        mkpart primary 8GiB 8.5GiB \
        mkpart primary 8.5GiB 100% \
        set 1 esp on
sync

# Format the partitions
mkfs.fat -F32 ${DEVICE}1
mkfs.ext4 ${DEVICE}2
mkswap ${DEVICE}3
mkfs.ext4 ${DEVICE}4
mkfs.ext4 ${DEVICE}5

# Mount the new partitions
rm -rf rootfs && mkdir rootfs
mount ${DEVICE}2 rootfs
mkdir -p rootfs/boot/efi
mount ${DEVICE}1 rootfs/boot/efi
mkdir -p rootfs/etc/darch
mount ${DEVICE}4 rootfs/etc/darch
mkdir -p rootfs/var/lib/darch
mount ${DEVICE}5 rootfs/var/lib/darch

# Generate the rootfs
debootstrap --verbose \
    --unpack-tarball=$(pwd)/debs.tar.gz \
    --include=linux-image-generic,grub-efi \
    cosmic rootfs http://archive.ubuntu.com/ubuntu/

# Generate fstab (removing comments and whitespace)
genfstab -U -p rootfs | sed -e 's/#.*$//' -e '/^$/d' > rootfs/etc/fstab
# TODO: Add swap to fstab
# $(lsblk -rno UUID ${DEVICE}2)
# UUID=8cf93f5d-5ffe-4739-b62a-b055d334d8f3       none            swap            defaults,pri=-2 0 0

# Set the computer name
echo "PAULS-UBUNTU" > rootfs/etc/hostname

# Update all the packages
arch-chroot rootfs apt-get update

# Install network manager for networking and SSH
arch-chroot rootfs apt-get -y install network-manager openssh-server

# Install GRUB
arch-chroot rootfs grub-install ${DEVICE} --target=x86_64-efi --efi-directory=/boot/efi
arch-chroot rootfs grub-mkconfig -o /boot/grub/grub.cfg

# Create the default users
arch-chroot rootfs apt-get -y install sudo
arch-chroot rootfs /usr/bin/bash -c 'echo -en "root\nroot" | passwd'
arch-chroot rootfs useradd -m -G users,sudo -s /usr/bin/bash darch
arch-chroot rootfs /usr/bin/bash -c 'echo -en "darch\ndarch" | passwd darch'

# Install Darch
arch-chroot rootfs apt-get -y install curl gnupg software-properties-common
arch-chroot rootfs /bin/bash -c "curl -L https://raw.githubusercontent.com/godarch/debian-repo/master/key.pub | apt-key add -"
arch-chroot rootfs add-apt-repository 'deb https://raw.githubusercontent.com/godarch/debian-repo/master/darch testing main'
arch-chroot rootfs apt-get update
arch-chroot rootfs apt-get -y install darch
arch-chroot rootfs mkdir -p /etc/containerd
echo "root = \"/var/lib/darch/containerd\"" > rootfs/etc/containerd/config.toml
arch-chroot rootfs systemctl enable containerd

# Setup the fstab hooks for Darch
cat rootfs/etc/fstab | tail -n +2 > rootfs/etc/darch/hooks/default_fstab
echo "*=default_fstab" > rootfs/etc/darch/hooks/fstab.config

# Run grub-mkconfig again to ensure it loads the Darch grub config file
arch-chroot rootfs grub-mkconfig -o /boot/grub/grub.cfg

# Clean up
umount rootfs/boot/efi
umount rootfs/etc/darch
umount rootfs/var/lib/darch
umount rootfs