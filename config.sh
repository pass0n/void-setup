#!/bin/bash

PKGS="xorg-minimal xdg-user-dirs zathura zathura-pdf-mupdf git vscode firefox unrar unzip p7zip numlockx mpv mesa-dri mesa-dri-32bit gvfs elogind rtkit pavucontrol pipewire alsa-pipewire webp-pixbuf-loader nvidia470 nvidia470-libs-32bit"

DEVEL="fontconfig-devel libX11-devel libXft-devel"

THUNAR="Thunar tumbler thunar-archive-plugin file-roller thunar-media-tags-plugin"

XFCE="$THUNAR xfce4 ristretto"

BSPWM="bspwm sxhkd polybar rofi picom dex setxkbmap xsetroot xprop nitrogen lxappearance ristretto"

AWESOME="awesome nitrogen ristretto dex scrot setxkbmap lxappearance"

xbps-install -Sy void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
xbps-install -Sy

mkdir -p /var/lib/dkms

while true; do
    echo -ne "XFCE4 = 1\nAWESOMEWM = 2\nBSPWM = 3\nNúmero: "
    read -r n
    
    echo -ne "Número escolhido foi $n, confirmar? S/n "
    read -r escolha
    if [ "$escolha" = "s" ] || [ "$escolha" = "S" ]; then
        break
    fi
done

if [ "$n" = "1" ]; then
    eval "sudo xbps-install -S $XFCE $PKGS"
elif [ "$n" = "2" ]; then
    eval "sudo xbps-install -S $AWESOME $THUNAR $PKGS"
elif [ "$n" = "3" ]; then
    eval "sudo xbps-install -S $BSPWM $THUNAR $PKGS"
else
    eval "sudo xbps-install -S $PKGS $DEVEL"
fi

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

#=== PIPEWIRE CONFIG
ln -s /usr/share/applications/pipewire.desktop /etc/xdg/autostart/pipewire.desktop
ln -s /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/pipewire-pulse.desktop
#= SESSION MANAGEMENT
mkdir -p /etc/pipewire/pipewire.conf.d
ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
#= PULSEAUDIO REPLACEMENT
ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/
#= ALSA INTEGRATION
mkdir -p /etc/alsa/conf.d
ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d
ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d

#=== RUNIT SERVICES
ln -s /etc/sv/dbus/ /var/service/
ln -s /etc/sv/dhcpcd/ /var/service/
ln -s /etc/sv/rtkit/ /var/service/
ln -s /etc/sv/polkitd/ /var/service/

useradd -m -s /bin/bash -U -G wheel,audio,video,kvm,xbuilder void
passwd void
