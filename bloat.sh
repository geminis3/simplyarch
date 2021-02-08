#!/bin/bash
clear
echo ">>> Desktop Environment <<<"
echo
while ! [[ "$desktop" =~ ^(1|2|3|4)$ ]] 
do
    echo "Please select 1,2,3,4,5,6 for:"
    echo "1. Gnome"
    echo "2. KDE/Plasma"
    echo "3. Xfce"
    echo "4. LXQt"	
    echo "5. LXDE"
    echo "6. None - Quit"
    read -p "Desktop: " desktop
done
case $desktop in
    1)
        pacstrap /mnt gnome-shell mutter chrome-gnome-shell gdm gnome-backgrounds gnome-control-center gnome-screenshot gnome-system-monitor gnome-terminal gnome-tweak-tool nautilus tracker
        arch-chroot /mnt /bin/bash -c "systemctl enable gdm.service"
        ;;
    2)
        pacstrap /mnt sddm plasma dolphin konsole kate kcalc ark gwenview spectacle okular packagekit-qt5
        arch-chroot /mnt /bin/bash -c "systemctl enable sddm.service"
        ;;
    3)
        pacstrap /mnt lxdm xfce xfce4-goodies
        arch-chroot /mnt /bin/bash -c "systemctl enable lxdm.service"
        ;;
    4)
    	pacstrap /mnt sddm lxqt breeze-icons featherpad
    	arch-chroot /mnt /bin/bash -c "systemctl enable sddm.service"
    5)
    	pacstrap /mnt lxdm lxde leafpad galculator
    	arch-chroot /mnt /bin/bash -c "systemctl enable lxdm.service"
    6)
        echo "No desktop environment will be installed."
        exit 0
        ;;
esac
# install Firefox for all DE selections
pacstrap /mnt firefox
# install KVM video drivers
if [[ $dekstop != "2" && arch-chroot /mnt /bin/bash -c "grep -q ^flags.*\ hypervisor\  /proc/cpuinfo" ]]
then
    pacstrap /mnt spice-vdagent xf86-video-qxl
fi
clear
echo ">>> NVIDIA Support <<<"
echo
echo "Do you want to add NVIDIA support? (Y/N)"
read -p "NVIDIA Support: " nvidia
if [[ $nvidia == "y" || $nvidia == "Y" || $nvidia == "yes" || $nvidia == "Yes" ]]
then
    pacstrap /mnt nvidia nvidia-utils egl-wayland
fi
clear
echo ">>> Flatpak <<<"
echo
echo "Do you want to install flatpak? (Y/N)"
read -p "Flatpak: " flatpak
if [[ $flatpak == "y" || $flatpak == "Y" || $flatpak == "yes" || $flatpak == "Yes" ]]
then
    pacstrap /mnt flatpak
fi
clear
echo ">>> Printer Support <<<"
echo
echo "Do you want to add printing support? (Y/N)"
read -p "Printing Support: " printerSupport
if [[ $printerSupport == "y" || $printerSupport == "Y" || $printerSupport == "yes" || $printerSupport == "Yes" ]]
then
    pacstrap /mnt cups
fi
clear
echo ">>> IzZy's Customs <<<"
echo
echo "Install my customs? (Y/N)"
echo "These customs includes:"
echo "- Flatpak Applications - libreoffice, geary, remmina, boxes & Gnome Applications if Gnome DE is selected"
echo "- AUR Packages - timeshift (for snapshots), vscode, teams"
read -p "My Customs: " custom
if [[ $custom == "y" || $custom == "Y" || $custom == "yes" || $custom == "Yes" ]]
then
    if [[ $desktop == "1" ]] && [[ $flatpak == "y" || $flatpak == "Y" || $flatpak == "yes" || $flatpak == "Yes" ]]
    then
        arch-chroot /mnt /bin/bash -c "flatpak install flathub -y --noninteractive --app org.gnome.Boxes org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.clocks org.gnome.Contacts org.gnome.eog org.gnome.Epiphany org.gnome.Extensions org.gnome.Evince org.gnome.FileRoller org.gnome.font-viewer org.gnome.Geary org.gnome.gedit org.gnome.Logs org.gnome.Photos org.gnome.Totem org.gnome.Weather org.libreoffice.LibreOffice org.remmina.Remmina"
    elif [[ $flatpak == "y" || $flatpak == "Y" || $flatpak == "yes" || $flatpak == "Yes" ]]
    then
        arch-chroot /mnt /bin/bash -c "flatpak install flathub -y --noninteractive --app org.gnome.Boxes org.gnome.Geary org.libreoffice.LibreOffice org.remmina.Remmina"
    fi
    echo "HOME=/home/$user; paru -Sy timeshift-bin visual-studio-code-bin teams --removemake --cleanafter --noconfirm" | arch-chroot /mnt /bin/bash -c "su $user"
fi
exit 0
