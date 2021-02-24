#!/bin/bash

# WARNING: THIS SCRIPT USES RELATIVE FILE PATHS SO IT MUST BE RUN FROM THE SAME WORKING DIRECTORY AS THE CLONED REPO

clear
echo
echo "Bienvenido a SimplyArch Installer (ahora en Español)"
echo "Copyright (C) 2021 Victor Bayas"
echo
echo "DESCARGO: EL SOFTWARE SE PROPORCIONA ""TAL CUAL"", SIN GARANTÍA DE NINGÚN TIPO, EXPRESA O IMPLÍCITA"
echo
echo "ADVERTENCIA: ESCRIBA BIEN PORQUE EL SCRIPT NO VALIDA LAS ENTRADAS"
echo
echo "Te guiaremos a lo largo de la instalación de un sistema Arch Linux completamente funcional"
echo
read -p "Continuar? (Y/N): " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
	clear
	# Ask locales
	echo ">>> Región & Idioma <<<"
	echo
	echo "EJEMPLOS:"
	echo "us Inglés | us-acentos Inglés Intl | latam Español latino | es Español de España"
	read -p "Distribución de teclado: " keyboard 
	if [[ -z "$keyboard" ]]
	then
		keyboard="us"
	fi
	echo
	echo "EJEMPLOS: en_US | es_ES (no agregar el .UTF-8)"
	read -p "Idioma: " locale
	if [[ -z "$locale" ]]
	then
		locale="en_US"
	fi
	clear
	# Ask account
	echo ">>> Cuentas <<<"
	echo
	read -p "Hostname: " hostname
	echo
	echo "Usuario Administrador"
	echo "User: root"
	read -sp "Contraseña: " rootpw
	echo
	read -sp "Ingrese nuevamente su contraseña: " rootpw2
	echo
	while [[ $rootpw != "$rootpw2" ]]
	do
		echo
		echo "Las contraseñas no coinciden. Intente nuevamente."
		echo
		read -sp "Contraseña: " rootpw
		echo
		read -sp "Ingrese nuevamente su contraseña: " rootpw2
		echo
	done
	echo
	echo "Usuario Normal"
	read -p "User: " user
	export user
	read -sp "Contraseña: " userpw
	echo
	read -sp "Ingrese nuevamente su contraseña: " userpw2
	echo
	while [[ $userpw != "$userpw2" ]]
	do
		echo
		echo "Las contraseñas no coinciden. Intente nuevamente."
		echo
		read -sp "Contraseña: " userpw
		echo
		read -sp "Ingrese nuevamente su contraseña: " userpw2
		echo
	done
	# Disk setup
	clear
	echo ">>> Discos <<<"
	echo
	echo "Asegúrese de tener su disco previamente particionado, si no está seguro presione CTRL + C y ejecute este script nuevamente"
	sleep 5
	clear
	echo "Tabla de Particiones"
	echo
	lsblk
	echo
	while ! [[ "$partType" =~ ^(1|2)$ ]] 
	do
		echo "Seleccione el tipo de partición (1/2):"
		echo "1. EXT4"
		echo "2. BTRFS"
		read -p "Partition Type: " partType
	done
	clear
	echo "Tabla de Particiones"
	echo
	lsblk
	echo
	echo "Escriba el nombre de la partición, por ejemplo: /dev/sdaX /dev/nvme0n1pX"
	read -p "Partición Raíz: " rootPart
	case $partType in
		1)
			mkfs.ext4 $rootPart
			mount $rootPart /mnt
			;;
		2)
			mkfs.btrfs -f -L "Arch Linux" $rootPart
			mount $rootPart /mnt
			btrfs sub cr /mnt/@
			umount $rootPart
			mount -o relatime,space_cache=v2,compress=lzo,subvol=@ $rootPart /mnt
			mkdir /mnt/boot
			;;
	esac
	clear
	if [[ -d /sys/firmware/efi ]]
	then
		echo "Tabla de Particiones"
		echo
		lsblk
		echo
		echo "Escriba el nombre de la partición, por ejemplo: /dev/sdaX /dev/nvme0n1pX"
		read -p "Partición EFI: " efiPart
		echo
		echo "USUARIOS DE DUALBOOT: Si está compartiendo esta partición EFI con otro sistema operativo escriba N"
		read -p "¿Quiere formatear esta partición como FAT32? (Y/N): " formatEFI
		if [[ $formatEFI == "y" || $formatEFI == "Y" || $formatEFI == "yes" || $formatEFI == "Yes" ]]
		then
			mkfs.fat -F32 $efiPart
		fi
		mkdir -p /mnt/boot/efi
		mount $efiPart /mnt/boot/efi
		echo
		clear
	fi
	echo "Tabla de Particiones"
	echo
	lsblk
	echo
	echo "NOTA: Si no quiere Swap escriba N"
	echo
	echo "Escriba el nombre de la partición, por ejemplo: /dev/sdaX /dev/nvme0n1pX"
	read -p "Partición Swap: " swap
	if [[ $swap == "n" || $swap == "N" || $swap == "no" || $swap == "No" ]]
	then
		echo
		echo "Partición Swap no seleccionada"
		sleep 1
	else
		mkswap $swap
		swapon $swap
	fi
	clear
	# update mirrors
	chmod +x simple_reflector.sh
	./simple_reflector.sh
	clear
	# Install base system
	if [[ -d /sys/firmware/efi ]]
	then
		pacstrap /mnt base base-devel linux linux-firmware linux-headers grub efibootmgr os-prober bash-completion sudo nano vim networkmanager ntfs-3g neofetch htop git reflector xdg-user-dirs e2fsprogs man-db
	else
		pacstrap /mnt base base-devel linux linux-firmware linux-headers grub os-prober bash-completion sudo nano vim networkmanager ntfs-3g neofetch htop git reflector xdg-user-dirs e2fsprogs man-db
	fi
	# fstab
	genfstab -U /mnt >> /mnt/etc/fstab
	# configure base system
	# locales
	echo "$locale.UTF-8 UTF-8" > /mnt/etc/locale.gen
	arch-chroot /mnt /bin/bash -c "locale-gen" 
	echo "LANG=$locale.UTF-8" > /mnt/etc/locale.conf
	# keyboard
	echo "KEYMAP=$keyboard" > /mnt/etc/vconsole.conf
	# timezone
	arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime"
	arch-chroot /mnt /bin/bash -c "hwclock --systohc"
	# enable multilib
	sed -i '93d' /mnt/etc/pacman.conf
	sed -i '94d' /mnt/etc/pacman.conf
	sed -i "93i [multilib]" /mnt/etc/pacman.conf
	sed -i "94i Include = /etc/pacman.d/mirrorlist" /mnt/etc/pacman.conf
	# hostname
	echo "$hostname" > /mnt/etc/hostname
	echo "127.0.0.1	localhost" > /mnt/etc/hosts
	echo "::1		localhost" >> /mnt/etc/hosts
	echo "127.0.1.1	$hostname.localdomain	$hostname" >> /mnt/etc/hosts
	# grub
	if [[ -d /sys/firmware/efi ]]
	then
		arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch"
	else
		arch-chroot /mnt /bin/bash -c "grub-install ${rootPart::-1}"
	fi
	arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
	# networkmanager
	arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager.service"
	# root pw
	arch-chroot /mnt /bin/bash -c "(echo $rootpw ; echo $rootpw) | passwd root"
	# create user
	arch-chroot /mnt /bin/bash -c "useradd -m -G wheel $user"
	arch-chroot /mnt /bin/bash -c "(echo $userpw ; echo $userpw) | passwd $user"
	arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
	arch-chroot /mnt /bin/bash -c "xdg-user-dirs-update"
	# update mirrors
	cp ./simple_reflector.sh /mnt/home/$user/simple_reflector.sh
	arch-chroot /mnt /bin/bash -c "chmod +x /home/$user/simple_reflector.sh"
	clear
	arch-chroot /mnt /bin/bash -c "/home/$user/simple_reflector.sh"
	clear
	# paru
	echo ">>> Asistente del AUR <<<"
	echo
	echo "Instalando Paru..."
	echo "cd && git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si --noconfirm && cd && rm -rf paru-bin" | arch-chroot /mnt /bin/bash -c "su $user"
	clear
	# bloat
	chmod +x bloat.sh
	./bloat.sh
	# end
	clear
	echo "SimplyArch Installer"
	echo
	echo ">>> Instalación finalizada exitosamente <<<"
	echo
	read -p "Desea reiniciar? (Y/N): " reboot
	if [[ $reboot == "y" || $reboot == "Y" || $reboot == "yes" || $reboot == "Yes" ]]
	then
		echo "El sistema se reiniciará en un momento..."
		sleep 3
		clear
		umount -a
		reboot 
	fi
fi
