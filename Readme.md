# Raspberry Pi - (VPN Gateway with Wireless Access Point setup)

Note: This is for using openvpn configs -- You may need to tweak the "install.sh" file if using something else

To get started:
1.Flash your device with the latest raspbian image (preferably with the Raspberry Pi Imager)
  a. It is recommended to use "Raspberry Pi OS Lite (64-bit)" without the desktop
  b. Either set a username or password through the "Edit Settings" button for "OS customisation settings" in the Rpi Image tool, or set it manually using startup text file configs (the latter is more advanced)

2.After flashing the microsd card, SSH into the device with `ssh <username>@<device_ip>`, then just upload the `install.sh` script and run it: `bash install.sh`
  a. Everything should be automatically ran and installed, then you should be able to just do the following

---

## Now we can install the necessary items and setup the wireless access point (should be non-interactive, but still monitor JIC)

3.Next, obtain your openvpn files for all the countries you want and upload to the device. 

4.Then move all the files under `/etc/openvpn/client/` and ensure they are named similar to this format:
  a. `<country>.conf` -> i.e. `brazil.conf`

5.Then all you need to do is run `openvpn-connect <country>` (i.e. `openvpn-connect brazil`) and it should connect
  a. To disconnect, just run the `openvpn-disconnect` command
