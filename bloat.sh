#!/bin/bash

# WARNING: BLOAT SHALL BE RUN AS A CHILD OF THE BASE SCRIPT BECAUSE PARU CAN'T BE RUN AS ROOT
# However feel free to override the inherited user variable if you know what you're doing
#user="your_username"

clear
echo "Bloat por SimplyArch (BETA)"
echo "Copyright (C) 2021 Victor Bayas"
echo
echo "NOTA: ESTE PASO ES COMPLETAMENTE OPCIONAL, siéntase libre de seleccionar Ninguno y finalizar el proceso de instalación"
echo
echo "Lo guiaremos a través del proceso de instalación de un DE, software y drivers adicionales."
echo
echo ">>> Entorno de Escritorio (DE) <<<"
echo
while ! [[ "$desktop" =~ ^(1|2|3|4|5|6|7|8)$ ]]
do
    echo "Selecciona uno:"
    echo "1. GNOME Mínimo"
    echo "2. GNOME Full (bastantes paquetes)"
    echo "3. KDE Plasma"
    echo "4. Xfce"
    echo "5. LXQt"	
    echo "6. LXDE"
    echo "7. Cinnamon"
    echo "8. Ninguna - No quiero bloat >:("
    read -p "Escritorio (1-8): " desktop
done
case $desktop in
    1)
        DEpkg="gdm gnome-shell gnome-backgrounds gnome-control-center gnome-screenshot gnome-system-monitor gnome-terminal gnome-tweak-tool nautilus gedit gnome-calculator gnome-disk-utility eog evince"
        ;;
    2)
        DEpkg="gdm gnome gnome-tweak-tool"
        ;;
    3)
        DEpkg="sddm plasma plasma-wayland-session dolphin konsole kate kcalc ark gwenview spectacle okular packagekit-qt5"
        ;;
    4)
        DEpkg="lxdm xfce4 xfce4-goodies network-manager-applet"
        ;;
    5)
        DEpkg="sddm lxqt breeze-icons featherpad"
        ;;
    6)
        DEpkg="lxdm lxde leafpad galculator"
        ;;
    7)
        DEpkg="lxdm cinnamon cinnamon-translations gnome-terminal"
        ;;
    8)
        echo "No desktop environment will be installed."
        exit 0
        ;;
esac
# install packages accordingly
arch-chroot /mnt /bin/bash -c "pacman -Sy $DEpkg firefox-i18n-es-es pulseaudio pavucontrol pulseaudio-alsa --noconfirm --needed"
# enable DM accordingly
case $desktop in
    1)
        arch-chroot /mnt /bin/bash -c "systemctl enable gdm.service"
        ;;
    2)
        arch-chroot /mnt /bin/bash -c "systemctl enable gdm.service"
        ;;
    3)
        arch-chroot /mnt /bin/bash -c "systemctl enable sddm.service"
        ;;
    4)
        arch-chroot /mnt /bin/bash -c "systemctl enable lxdm.service"
        ;;
    5)
        arch-chroot /mnt /bin/bash -c "systemctl enable sddm.service"
        ;;
    6)
        arch-chroot /mnt /bin/bash -c "systemctl enable lxdm.service"
        ;;
    7)
        arch-chroot /mnt /bin/bash -c "systemctl enable lxdm.service"
        ;;
esac
# auto-install VM drivers
case $(systemd-detect-virt) in
    kvm)
        # xf86-video-qxl is disabled due to bugs on certain DEs
        arch-chroot /mnt /bin/bash -c "pacman -S spice-vdagent --noconfirm --needed"
        ;;
    vmware)
        arch-chroot /mnt /bin/bash -c "pacman -S open-vm-tools --noconfirm --needed"
        arch-chroot /mnt /bin/bash -c "systemctl enable vmtoolsd.service ; systemctl enable vmware-vmblock-fuse.service"
        ;;
esac
# app installer
while ! [[ "$app" =~ ^(15)$ ]] 
do
    clear
    echo ">>> Instalador de Apps <<<"
    echo
    echo "NOTA: Firefox se instaló en el paso anterior"
    echo
    echo "Seleccione:"
    echo
    echo ">>> Navegadores"
    echo
    echo "1. Google Chrome"
    echo "2. Chromium"
    echo
    echo ">>> Trabajo & Productividad"
    echo
    echo "3. LibreOffice Fresh"
    echo "4. Zoom"
    echo "5. Microsoft Teams"
    echo "6. Telegram Desktop"
    echo
    echo ">>> Multimedia"	
    echo
    echo "7. VLC"
    echo "8. MPV"
    echo
    echo ">>> Utilidades"
    echo
    echo "9. GParted"
    echo "10. Timeshift Backup"
    echo
    echo ">>> Editores de Texto"
    echo
    echo "11. Visual Studio Code"
    echo "12. Neovim"
    echo "13. GNU Emacs"
    echo "14. Atom"
    echo
    echo "15. Ninguni / Continuar al siguiente paso"
    read -p "App (1-15): " app
    case $app in
        1)
            arch-chroot /mnt /bin/bash -c "sudo -u $user paru -S google-chrome --noconfirm --needed"
            ;;
        2)
            arch-chroot /mnt /bin/bash -c "pacman -S chromium --noconfirm --needed"
            ;;
        3)
            arch-chroot /mnt /bin/bash -c "pacman -S libreoffice-fresh-es --noconfirm --needed"
            ;;
        4)
            arch-chroot /mnt /bin/bash -c "sudo -u $user paru -S zoom --noconfirm --needed"
            ;;
        5)
            arch-chroot /mnt /bin/bash -c "sudo -u $user paru -S teams --noconfirm --needed"
            ;;
        6)
            arch-chroot /mnt /bin/bash -c "pacman -S telegram-desktop --noconfirm --needed"
            ;;
        7)
            arch-chroot /mnt /bin/bash -c "pacman -S vlc --noconfirm --needed"
            ;;
        8)
            arch-chroot /mnt /bin/bash -c "pacman -S mpv --noconfirm --needed"
            ;;
        9)
            arch-chroot /mnt /bin/bash -c "pacman -S gparted --noconfirm --needed"
            ;;
        10)
            arch-chroot /mnt /bin/bash -c "sudo -u $user paru -S timeshift-bin --noconfirm --needed"
            ;;
        11)
            arch-chroot /mnt /bin/bash -c "sudo -u $user paru -S visual-studio-code-bin --noconfirm --needed"
            ;;
        12)
            arch-chroot /mnt /bin/bash -c "pacman -S neovim --noconfirm --needed"
            ;;
        13)
            arch-chroot /mnt /bin/bash -c "pacman -S emacs --noconfirm --needed"
            ;;
        14)
            arch-chroot /mnt /bin/bash -c "pacman -S atom --noconfirm --needed"
            ;;
    esac
done
clear
# nvidia
echo ">>> Drivers de NVIDIA <<<"
echo
echo "¿Quiere agregar los drivers propietarios de NVIDIA? (Y/N)"
read -p "NVIDIA: " nvidia
if [[ $nvidia == "y" || $nvidia == "Y" || $nvidia == "yes" || $nvidia == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S nvidia-dkms nvidia-utils egl-wayland --noconfirm --needed"
fi
clear
# broadcom
echo ">>> Broadcom WiFi <<<"
echo
echo "Solo haga esto si su tarjeta Broadcom no funciona con los drivers integrados del kernel"
echo
echo "¿Quiere agregar los drivers propietarios de Broadcom drivers? (Y/N)"
read -p "Broadcom: " broadcom
if [[ $broadcom == "y" || $broadcom == "Y" || $broadcom == "yes" || $broadcom == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S broadcom-wl-dkms --noconfirm --needed"
fi
clear
# intel vaapi
echo ">>> Intel VAAPI drivers (recomendado) <<<"
echo
echo "Haga esto solo si tiene una GPU Intel"
echo
echo "¿Desea agregar Intel VAAPI? (Y/N)"
read -p "Intel VAAPI: " intelVaapi
if [[ $intelVaapi == "y" || $intelVaapi == "Y" || $intelVaapi == "yes" || $intelVaapi == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S libva-intel-driver intel-media-driver vainfo --noconfirm --needed"
fi
clear
# flatpak
echo ">>> Flatpak <<<"
echo
echo "¿Desea instalar Flatpak? (Y/N)"
read -p "Flatpak: " flatpak
if [[ $flatpak == "y" || $flatpak == "Y" || $flatpak == "yes" || $flatpak == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S flatpak --noconfirm --needed"
fi
clear
# cups
echo ">>> Soporte de Impresoras (CUPS) <<<"
echo
echo "¿Quieres agregar soporte de impresión? (Y/N)"
read -p "Soporte de Impresoras: " printerSupport
if [[ $printerSupport == "y" || $printerSupport == "Y" || $printerSupport == "yes" || $printerSupport == "Yes" ]]
then
    arch-chroot /mnt /bin/bash -c "pacman -S cups --noconfirm --needed"
fi
exit 0
