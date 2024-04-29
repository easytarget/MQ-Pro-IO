# Rebuild dts tree fo MQ pro..

see:
https://manpages.ubuntu.com/manpages/focal/man1/dtc.1.html
https://forum.armbian.com/topic/29626-mango-pi-mq-pro-d1-device-tree-try-to-okay-serial/
https://github.com/torvalds/linux/tree/master/arch/riscv/boot/dts/allwinner

## Notes for re-generating MQ PRO device tree (`.dtb`)
My notes
* By default the Device Tree compiler (`/usr/bin/dtc`) should already be installed, as should the linux-headers for the kernel.

### compile the mq-pro dts with the current kernel headers
Example here is against the 'default' 6.8.0-31 linux kernel from the Ubuntu 24.04 release
* clean the `dtspp` folder: `rm dtspp/*`
* edit and run `bake.sh` to precompile the files against the latest linux-headers
* cd into the `dtspp` folder and run: 
  `dtc sun20i-d1-mangopi-mq-pro.dts > dtb-6.8.0-31-mqpro`
  modify the version to reflect the current headers
* move the `.dtb` file into the `/boot` folder:
  `sudo mv dtb-6.8.0-31-mqpro /boot/dtbs`
* make a link in `/boot` to this:
  `sudo ln -s dtbs/dtb-6.8.0-31-mqpro /boot/dtb-mqpro`

### Set up Grub to test boot the new DTB
Initially we will test the new dtb:
* backup the grub config: `sudo cp /etc/grub/grub.cfg /etc/grub/grub.cfg.generic-dtb`
* `sudo vi /etc/grub/grub.cfg`  (or use nano if you prefer)
  Find the 1st `menuentry` section (the default Ubuntu one) and edit the `devicetree` line to look like:
  `devicetree      /boot/dtb-mqpro`
* Reboot (`sudo reboot`) (remember the mq-pro is sloooow to reboot ;-) )
* If the reboot fails you can either attach a serial adapter to the GPIO pins and select the fallback kernel from the advanced options menu, and then restore the grub config backup once logged in. 
  Or (if no serial available) remove the SD card, mount it on another computer and restore the file there.

### Check that we have the correct device tree
`dtc -I fs /sys/firmware/devicetree/base | grep 'model'`
* ignore all the 'not a phandle reference' warnings
* you should see `model = "MangoPi MQ Pro"` at the end

### Make this permanent in grub
ToDo

## Issues
**No HDMI output** - this is either a blocker.. or fine for a headless system

### Bonus
The onboard (blue) status LED can be controlled via the sys tree:
`sudo sh -c "echo 1 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn on
`sudo sh -c "echo 1 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn off
You can make it flash as wifi traffic is seen with:
`sudo sh -c "echo phy0rx > /sys/devices/platform/leds/leds/blue\:status/trigger"` 

