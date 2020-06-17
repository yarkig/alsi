#!/bin/bash
loadkeys ru
setfont cyr-sun16

echo 'Очистка диска'
wipefs --all --force /dev/sda /dev/sda1 /dev/sda2 /dev/sda3
dd if=/dev/zero of=/dev/sda bs=512 count=1

echo 'Создание разделов'
(
  echo o;
  echo Y;

  echo n;
  echo;
  echo;
  echo +100M;
  echo EF00;
  
  echo n;
  echo;
  echo;
  echo +10240M;
  echo;

  echo n;
  echo;
  echo;
  echo;
  echo;

  echo w;
  echo Y;
) | gdisk /dev/sda

echo 'Форматирование дисков'
mkfs.vfat -F32 /dev/sda1
mkfs.btrfs /dev/sda2
mkfs.btrfs /dev/sda3

echo 'Монтирование дисков'
mount /dev/sda2 /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
mount /dev/sda2 /mnt/home

echo 'Выбор зеркал для загрузки. Ставим зеркало от Яндекс на первое место'
sed -ie '1 iServer = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch' /etc/pacman.d/mirrorlist

echo 'Прогресс-бар в виде Пакмана, пожирающего пилюли'
sudo sed -ie '/^# Misc options/a ILoveCandy' /etc/pacman.conf

echo 'Установка основных пакетов'
pacstrap -i /mnt base base-devel linux linux-firmware mc nano openssh networkmanager --noconfirm

echo 'Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

echo 'Входим в установленную систему'
arch-chroot /mnt sh -c "$(curl -fsSL git.io/ai2-uefi.sh)"
