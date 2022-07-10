#!/usr/bin/env sh

rm -rf /mnt/post_install.sh
sleep 3s
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
echo "And then rebooting in 10  seconds!!!"
echo "After Reboot login your your username and password and type startx to start GUI."
sleep 10s
reboot
