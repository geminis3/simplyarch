#!/bin/bash
clear
echo ">>> Desktop Environment <<<"
echo
while ! [[ "$desktop" =~ ^(1|2|3|4)$ ]] 
do
    echo "Please select 1,2,3 for:"
    echo "1. Gnome"
    echo "2. KDE/Plasma"
    echo "3. Xfce"
    echo "4. None"
    read -p "Desktop: " desktop
done
case $desktop in
    1)
        pacstrap /mnt gnome-shell mutter chrome-gnome-shell file-roller firefox gdm gnome-backgrounds gnome-control-center gnome-terminal gnome-tweak-tool nautilus 
        arch-chroot /mnt /bin/bash -c "systemctl enable gdm.service"
        ;;
    2)
        pacstrap /mnt plasma plasma-wayland-session ark dolphin firefox gwenview konsole kwrite krunner sddm
        arch-chroot /mnt /bin/bash -c "systemctl enable sddm.service"
        arch-chroot /mnt /bin/bash -c "systemctl enable bluetooth.service"
        ;;
    3)
        pacstrap /mnt xfce xfce4-goodies firefox lightdm lightdm-gtk-greeter
        arch-chroot /mnt /bin/bash -c "systemctl enable lightdm.service"
        ;;
    4)
        echo "No desktop environment will be installed."
        ;;
esac
clear
echo ">>> NVIDIA Support <<<"
echo
echo "Do you want to add NVIDIA support? (Y/N)"
read -p "NVIDIA Support: " nvidia
if [[ $nvidia == "y" || $nvidia == "Y" || $nvidia == "yes" || $nvidia== "Yes" ]]
then
    pacstrap /mnt nvidia
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
echo "- flatpak applications (libre office and other general flatpaks)"
echo "- alacritty (terminal emulator)"
echo "- timeshift (for snapshots)"
read -p "My Customs: " custom
if [[ $custom == "y" || $custom == "Y" || $custom == "yes" || $custom == "Yes" ]]
then
    pacstrap /mnt alacritty
    arch-chroot /mnt /bin/bash -c "paru --skipreview --removemake --cleanafter timeshift"
    arch-chroot /mnt /bin/bash -c "flatpak install flathub -y --noninteractive --app org.gnome.Boxes org.gnome.Calculator org.gnome.Calendar org.gnome.clocks org.gnome.eog org.gnome.Epiphany org.gnome.Extensions org.gnome.Evince org.gnome.font-viewer org.gnome.Geary org.gnome.gedit org.gnome.Photos org.gnome.Totem org.gnome.Weather"
fi