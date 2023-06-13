#!/usr/bin/env bash

# Copyright PwnWriter // METIS Linux ( metislinux.org )


make_tty() {
  local run_file1="/run/runit/service/agetty-tty1/run"
  local run_file2="/etc/runit/sv/agetty-tty1/run"
  local login_command="#!/bin/sh\nexec /bin/login -f root < /dev/tty1 > /dev/tty1 2>&1"

  echo -e "$login_command" > "$run_file1" || echo "Couldn't update $run_file1"
  echo -e "$login_command" > "$run_file2" || echo "Couldn't update $run_file1"
  echo "Update complete. Contents of $run_file:"
  cat "$run_file"
}

update_db() {

    pacman-key --init 
    pacman-key --populate
    pacman --noconfirm -Syy 
}


replace_getty_args() {
    local file="/etc/runit/runsvdir/default/agetty-tty1/conf"

    if [ -f "$file" ]; then
        sed -i 's/GETTY_ARGS="--noclear "/GETTY_ARGS="--noclear --autologin root"/' "$file"
        echo "Replacement completed."
    else
        echo "File $file does not exist."
    fi
}

replace_getty_args


remove_user_files() {
  # Check if the script is running as root
  if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
  fi

  local users=("artix" "metis")

  for user in "${users[@]}"; do
    local user_home=$(eval echo ~$user)

    if [ -z "$user_home" ]; then
      echo "User '$user' does not exist."
      continue
    fi

    echo "Removing files and folders for user '$user' located at: $user_home"


    # Remove the user itself
    echo "Removing user: $user"
    userdel -r "$user"
    if [ $? -ne 0 ]; then
            find "$user_home" -user "$user" -exec rm -rf {} \;
    else
      echo "User $user successfully removed."
    fi
  done
}



manage_users() {
  # Check if the script is running as root
  if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
  fi

  remove_user_files

  local shell="/bin/zsh"
  echo "Changing root user's default shell to $shell"
  chsh -s "$shell" root
  if [ $? -ne 0 ]; then
    echo "Failed to change root user's default shell."
    exit 1
  fi
  echo "Root user's default shell successfully changed to $shell."

  local password="metis"
  echo "Setting password for root user to '$password'"
  echo "root:$password" | chpasswd
  if [ $? -ne 0 ]; then
    echo "Failed to set password for root user."
    exit 1
  fi
  echo "Password for root user successfully set to '$password'."
}

remove_artix(){
        sed -i '/^artix/d' /etc/shadow
}


rank_and_replace_mirrorlist() {
  if command -v rankmirrors >/dev/null 2>&1; then
    rankmirrors -n 20 /etc/pacman.d/mirrorlist > mirrorlist
    mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
    mv mirrorlist /etc/pacman.d/mirrorlist
    echo "Mirrorlist successfully ranked and replaced."
  else
    echo "rankmirrors command not found. Please make sure it is installed."
  fi
}

install_grub(){
        pacman --noconfirm -Rcns artix-grub-live && pacman --noconfirm  -S metis-grub-live || echo "Couldn't install grub".
}

# execute
#make_tty
#install_grub

make_grub(){
        mv background.png /var/lib/artools/buildiso/base/artix/rootfs/usr/share/grub/themes/artix/background.png
        mv logo.png /var/lib/artools/buildiso/base/artix/rootfs/usr/share/grub/themes/artix/logo.png
}

#make_grub

update_db
rank_and_replace_mirrorlist
remove_artix
manage_users



