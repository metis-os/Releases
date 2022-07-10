#!/usr/bin/env sh

clear
echo "generating locale"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
sleep 2s

clear
echo "Getting Timezone..."
timezone() {
time_zone="$(curl --fail https://ipapi.co/timezone)"
clear
echo "System detected your timezone to be $time_zone"
echo "Is this correct?"

PS3="Select one.[1/2]: "
options=("Yes" "No")
select one in "${options[@]}"; do
    case $one in
        Yes)
            echo "${time_zone} set as timezone"
            ln -sf /usr/share/zoneinfo/"$time_zone" /etc/localtime && break
            ;;
        No)
            echo "Please enter your desired timezone e.g. Europe/London :"
            read -r new_timezone
            echo "${new_timezone} set as timezone"
            ln -sf /usr/share/zoneinfo/"$time_zone" /etc/localtime && break
            ;;
        *) echo "Wrong option. Try again";timezone;;
    esac
done
}
timezone
hwclock --systohc
echo "checking date"
date
sleep 2s
clear

echo "setting LANG variable"
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf
sleep 2s
clear
echo "setting console keyboard layout"
echo "KEYMAP=us" > /etc/vconsole.conf
sleep 2s
clear
echo "Set up your hostname!"
echo "Enter your computer name: "
read -r hostname
echo "$hostname" > /etc/hostname
echo "Checking hostname (/etc/hostname)"
cat /etc/hostname
sleep 1s
clear
echo "setting up hosts file"
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain     $hostname" >> /etc/hosts
clear
echo "checking /etc/hosts file"
cat /etc/hosts
sleep 2s
#if you are dualbooting, add os-prober with grub and efibootmgr
echo "Installing grub networkmanager and xwallpaper"
pacman -Sy --needed --noconfirm grub networkmanager-runit xwallpaper zsh
clear
sleep 1s
clear
echo "Enabling NetworkManager"
ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/default
sleep 2s
clear
echo "Enter password for root user:"
passwd
clear
echo "Adding regular user!"
echo "Enter username to add a regular user: "
read -r username
useradd -m -g users -G wheel,audio,video,network,storage -s /bin/zsh "$username"
echo "To set password for $username, use different password than for root."
echo "Enter password for "$username": "
passwd "$username"
echo "NOTE: ALWAYS REMEMBER THIS USERNAME AND PASSWORD YOU PUT JUST NOW."
sleep 2s
mv /os-release /usr/lib/
mv /pacman.conf /etc/
mv /mirrorlist /etc/pacman.d/
# mv /arch-mirrorlist /etc/pacman.d/
mv /metis-mirrorlist /etc/pacman.d/
mv /xinitrc /home/"$username"/.xinitrc
chown "$username":users /home/"$username"/.xinitrc
sleep 2s
mkdir -p /home/"$username"/.config/nvim/
mkdir -p /home/"$username"/.config/picom/
mv /init.vim /home/"$username"/.config/nvim/
chown -R "$username":users /home/"$username"/.config
mv /zshrc /home/"$username"/.zshrc
chown "$username":users /home/"$username"/.zshrc
mv /picom.conf /home/"$username"/.config/picom/
chown -R "$username":users /home/"$username"/.config/picom
chown -R "$username":users /home/"$username"/.config/
sleep 2s
clear
mv /grub /etc/default/
pacman -Sy --needed --noconfirm metis-dwm metis-st metis-dmenu metis-wallpapers xorg-server xorg-xinit xorg-xsetroot nerd-fonts-jetbrains-mono ttf-font-awesome pavucontrol pulseaudio pulseaudio-alsa firefox brillo linux-zen-headers linux-firmware curl git neovim zsh metis-slstatus picom-jonaburg-git acpi 
sleep 3s
clear
proc_type=$(lscpu)
if grep -E "GenuineIntel" <<< ${proc_type}; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm --needed intel-ucode
elif grep -E "AuthenticAMD" <<< ${proc_type}; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm --needed amd-ucode
fi

sleep 2s

#Adding sudo previliages to the user you created
echo "Giving sudo access to "$username"!"
echo "$username ALL=(ALL) ALL" >> /etc/sudoers.d/$username
sleep 2s
clear
lsblk
if [[ ! -d "/sys/firmware/efi" ]]; then
  clear
  echo "Installing grub for legacy system"
  sleep 2s
  clear
  echo "Enter the drive name to install bootloader in it. (eg: sda or nvme01 or vda or something similar)! "
  echo "NOTE: JUST GIVE DRIVE NAME (sda, nvme0n1, vda or something similar); NOT THE PARTITION NAME (sda1)"
  echo "Enter the drive name: "
  read -r grubdrive
  grub-install --target=i386-pc /dev/"$grubdrive"
  grub-mkconfig -o /boot/grub/grub.cfg
else
  echo "Installing efibootmgr"
  pacman -Sy --needed --noconfirm efibootmgr dosfstools
  sleep 1s
  clear
  lsblk
  echo "Enter partition to install grub! (eg: sda2 or nvme0n1p3, vda4 or something similar): "
  read -r grubpartition
  mkfs.fat -F 32 /dev/"$grubpartition"
  mkdir -p /boot/efi
  mount /dev/"$grubpartition" /boot/efi
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable
  grub-mkconfig -o /boot/grub/grub.cfg
fi
sleep 2s 
clear

echo "Searching and Installing graphics driver if available"
gpu_type=$(lspci)
if grep -E "NVIDIA|GeForce" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed nvidia nvidia-utils
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S --noconfirm --needed xf86-video-amdgpu
elif grep -E "Integrated Graphics Controller" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl vulkan-intel libva-utils
elif grep -E "Intel Corporation UHD" <<< ${gpu_type}; then
    pacman -S --needed --noconfirm libva-intel-driver libvdpau-va-gl vulkan-intel libva-intel-driver libva-utils
fi
sleep 2s
clear
echo "Second Phase Completed!"
echo "Entering into Final Phase of Installation..."
echo "run the following commands to start final phase "
echo "1. exit"
echo "2. final.sh"
sleep 5s