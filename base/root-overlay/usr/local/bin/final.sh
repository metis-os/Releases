#!/usr/bin/env bash

rm -rf /mnt/post_install.sh
sleep 1s
clear
echo -ne "
__________________________________________________________________________________________________________
|                                   Thanks For Choosing Metis Linux!                                      |
|                                                                                                         |
|                       +-+-+-+-+-+        +-+-+-+-+-+        +-+-+-+-+-+-+-+-+-+                         |
|                       |M|a|g|i|c|        |M|e|t|i|s|        |I|n|s|t|a|l|l|e|r|                         |
|                       +-+-+-+-+-+        +-+-+-+-+-+        +-+-+-+-+-+-+-+-+-+                         |
|                                                                                                         |
|---------------------------------------------------------------------------------------------------------|
|                                           INSTALLATION SUCCESSFUL!                                      |
|---------------------------------------------------------------------------------------------------------|
|                                 Metis Linus Installation Completed.                                     |
|               Check: https://github.com/metis-os for details or visit https://metislinux.org            |
|---------------------------------------------------------------------------------------------------------|
|_________________________________________________________________________________________________________|

"
echo "Metis Linux Installation Finished!!!"
echo "Umounting all the drives" 
umount -R /mnt
echo "After Reboot login your your username and password and type startx to start GUI."
echo "If you've installed metis-os in a VM, it may be buggy or could perform abnormal, try disabling picom compositor."
echo "AFTER REBOOTING RUN THE FOLLOWING COMMAND IN CASE OF NO NETWORK CONNECTIO: "
echo "1. sudo ls -s /etc/runit/sv/NetworkManager /run/runit/service"
echo "And then rebooting in 15 seconds!!!"
sleep 20s
reboot
