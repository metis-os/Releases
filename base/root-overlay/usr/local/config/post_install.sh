#!/usr/bin/env bash

failed() {
  sleep 2s
  clear
  echo -e "Something went wrong.\nThe command could not be executed correctly!\nPlease try again.\nExitting..."
  sleep 2s
  exit 1
}

installationError() {
  sleep 2s
  clear
  echo -e "Something went wrong.\nAll the packages couldn't be installed correctly!\nPlease try again.\nExitting..."
  sleep 2s
  exit 1
}

ignoreableErrors() {
  sleep 2s
  clear
  echo -e "Something went wrong.\nOS is installing and could be useable but the error should be manually fixed later..."
  sleep 3s
}

displayArt(){
  sleep 1s
  clear
  echo -ne "
  Installing Metis Linux in a VM is not recommended as it may perform slow and buggy.
  __________________________________________________________________________________________________________
  |                                                                                                         |
  |                       +-+-+-+-+-+        +-+-+-+-+-+        +-+-+-+-+-+-+-+-+-+                         |
  |                       |M|a|g|i|c|        |M|e|t|i|s|        |I|n|s|t|a|l|l|e|r|                         |
  |                       +-+-+-+-+-+        +-+-+-+-+-+        +-+-+-+-+-+-+-+-+-+                         |
  |                                                                                                         |
  |---------------------------------------------------------------------------------------------------------|
  |                                                PHASE 2                                                  |
  |---------------------------------------------------------------------------------------------------------|
  |                                 Install Metis Linus in few clicks                                       |
  |               Check: https://github.com/metis-os for details or visit https://metislinux.org            |
  |---------------------------------------------------------------------------------------------------------|
  |_________________________________________________________________________________________________________|
  "
  sleep 4s
}

generatingLocale() {
    sleep 2s
    clear
    echo "Generating locale at /etc/locale.gen"
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen || ignoreableErrors
    locale-gen
}

timezone() {
    echo "Getting Timezone..."
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

settingTimezone() {
    sleep 2s
    clear
    timezone
    hwclock --systohc
    echo "Checking system date and time..."
    date
    sleep 2s
}

settingLang() {
    sleep 2s
    clear
    echo "Setting LANG variable"
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf
    echo "LC_COLLATE=C" >> /etc/locale.conf
    echo "Checking system language..."
    cat /etc/locale.conf || ignoreableErrors
    sleep 3s
}

settingKeyboard() {
    sleep 2s
    clear
    echo "Setting console keyboard layout"
    echo "KEYMAP=us" > /etc/vconsole.conf
    echo "Checking system Keyboard Layout..."
    cat /etc/locale.conf || ignoreableErrors
    sleep 3s
}

settingHostname() {
    sleep 2s
    clear
    echo "Enter your computer name: "
    read -r hostname
    echo "$hostname" > /etc/hostname
    echo "Checking hostname (/etc/hostname)"
    cat /etc/hostname || ignoreableErrors
    sleep 3s
}

settingHosts() {
    sleep 2s
    clear
    echo "setting up hosts file"
    {
        echo "127.0.0.1       localhost"
        echo "::1             localhost"
        echo "127.0.1.1       $hostname.localdomain     $hostname"
    } >> /etc/hosts

    echo "checking /etc/hosts file"
    cat /etc/hosts || ignoreableErrors
    sleep 3s
}

installingBootloader() {
    clear
    #if you are dualbooting, add os-prober with grub and efibootmgr
    echo "Installing grub networkmanager and zsh shell..."
    pacman -Sy --needed --noconfirm grub networkmanager-runit zsh || installationError
    sleep 3s
}

enablingServices() {
    sleep 2s
    clear
    echo "Enabling NetworkManager"
    ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/default
    clear
}

addingUser() {
    clear
    echo "Enter password for root user!"
    passwd
    sleep 1s
    clear
    echo "Adding regular user!"
    echo "Enter username to add a regular user: "
    read -r username
    useradd -m -g users -G wheel,audio,video,network,storage -s /bin/zsh "$username" || ignoreableErrors
    echo "To set password for $username, use different password than of root."
    echo "Enter password for $username! "
    passwd "$username"
    echo "NOTE: ALWAYS REMEMBER THIS USERNAME AND PASSWORD YOU PUT JUST NOW."
    sleep 3s
}

sudoAccess() {
    sleep 2s
    clear
    echo "Giving sudo access to $username!"
    echo "$username ALL=(ALL) ALL" >> /etc/sudoers.d/"$username"
}

copyingConfig() {
    sleep 2s
    clear
    echo "Copying config file to their absolute path..."
    mv /config/os-release /usr/lib/ || failed
    mv /config/grub /etc/default/grub || failed

    mv /config/xinitrc /home/"$username"/.xinitrc || failed
    chown "$username":users /home/"$username"/.xinitrc || failed
    mv /config/zshrc /home/"$username"/.zshrc || failed
    chown "$username":users /home/"$username"/.zshrc || failed

    sleep 1s
    mv /config /home/"$username"/.config/ || ignoreableErrors
    chown -R "$username":users /home/"$username"/.config || ignoreableErrors
    sleep 1s
}

installingPackages() {
    sleep 2s
    clear
    echo "Installing require packages for metis-os"
    pacman -Sy --needed --noconfirm metis-dwm metis-st metis-dmenu metis-wallpapers xorg-server xorg-xinit xorg-xsetroot nerd-fonts-jetbrains-mono ttf-font-awesome pavucontrol pulseaudio pulseaudio-alsa firefox brillo linux-zen-headers linux-firmware curl git neovim zsh metis-slstatus picom-jonaburg-git acpi xwallpaper || installationError
}

installingMicrocode() {
    sleep 2s
    clear
    if lscpu | grep  "GenuineIntel"; then
        echo "Installing Intel microcode"
        pacman -S --noconfirm --needed intel-ucode || ignoreableErrors
    elif lscpu | grep "AuthenticAMD"; then
        echo "Installing AMD microcode"
        pacman -S --noconfirm --needed amd-ucode || ignoreableErrors
    fi
}

configuringBootloader() {
    sleep 2s
    clear
    if [[ ! -d "/sys/firmware/efi" ]]; then
      echo "Legacy system detected..."
      echo "Enter the drive name to install bootloader in it. (eg: sda or nvme01 or vda or something similar)! "
      echo "NOTE: JUST GIVE DRIVE NAME (sda, nvme0n1, vda or something similar); NOT THE PARTITION NAME (sda1)"
      echo "Enter the drive name: "
      read -r grubdrive
      grub-install --target=i386-pc /dev/"$grubdrive"
      grub-mkconfig -o /boot/grub/grub.cfg
    else
      echo "UEFI system detected..."
      echo "Installing efibootmgr"
      pacman -Sy --needed --noconfirm efibootmgr dosfstools
      sleep 2s
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
}

graphicsDriver() {
    sleep 2s
    clear
    echo "Searching and Installing graphics driver if available"
    if lspci | grep "NVIDIA|GeForce"; then
        pacman -S --noconfirm --needed nvidia nvidia-utils || ignoreableErrors
    elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
        pacman -S --noconfirm --needed xf86-video-amdgpu || ignoreableErrors
    elif lspci | grep "Integrated Graphics Controller"; then
        pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl vulkan-intel libva-utils || ignoreableErrors
    elif lspci | grep -E "Intel Corporation UHD|Intel Corporation HD"; then
        pacman -S --needed --noconfirm libva-intel-driver libvdpau-va-gl vulkan-intel libva-intel-driver libva-utils || ignoreableErrors
    fi
}

secondphaseCompleted(){
    sleep 2s
    clear
    echo "Second Phase Completed!"
    echo "Entering into Final Phase of Installation..."
    echo "Run the following commands to start final phase..."
    echo "1. exit"
    echo "2. final.sh"
}

displayArt
generatingLocale
settingTimezone
settingLang
settingKeyboard
settingHostname
settingHosts
installingBootloader
addingUser
sudoAccess
copyingConfig
installingPackages
installingMicrocode
configuringBootloader
graphicsDriver
secondphaseCompleted
