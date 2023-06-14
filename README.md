This repo provides a scaffolding for performing a fully automated network install of Ubuntu 22.04.

_**IF YOU RUN THE AUTOINSTALL OPTION, IT WILL OVERWRITE ANY DATA ON THE TARGET DISK WITH NO FURTHER PROMPT**_

## Setup
1. Download an [Ubuntu 22.04 Server Live-CD ISO](https://releases.ubuntu.com/22.04.2/ubuntu-22.04.2-live-server-amd64.iso) and place it in `srv/images/ubuntu-22.04.2-live-server-amd64.iso`
2. [Download a copy of grubnetx64.efi](http://archive.ubuntu.com/ubuntu/dists/jammy/main/uefi/grub2-amd64/current/grubnetx64.efi.signed) and place it in `srv/boot/grubx64.efi`
3. Edit line 13 of `tftp.plist` to be the full directory path to the srv directory
4. Edit `srv/grub/grub.cfg` and replace all references to `your-host-or-ip` with the host or IP that will be running the server (your current ip usually)
4. If you wish to do an interactive install instead of an automated one, skip to step 8
5. Copy `srv/autoinstall/user-data-template` to `srv/autoinstall/user-data`
6. Update srv/autoinstall/user-data to include your desired details. Pay particular attention to lines:
    * 27-31 for your user details and hostname
        * Generating a crypted password is surprisingly irritating to do on macos. The easiest way to get one is probably to run:
            * `docker run -it quay.io/coreos/mkpasswd -m sha512crypt -s`
    * 43, if you require a different locale than en_US
    * 40, 53 should contain your ssh public key (yes, twice, once on each line)
    * 59: The desired unlock passphrase for full-disk encryption, in plaintext
    * 43: Add any additional desired packages here
7. *Be sure you're ready for your target machine to be completely wiped*
8. Set your DHCP server supply PXE boot settings:
    * Option 66 / Server IP: point at the current machine (the one with the repo)
    * Option 67: `boot/bootx64.efi`
9. Start the server: `sudo ./run.sh`
10. On the target machine, invoke network boot (On an Intel NUC, F12 during POST)
11. Select automatic or manual install, as desired
12. When finished, press enter in the shell where you ran run.sh to shut down the image server

