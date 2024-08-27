# NOTE
# Being refactored at the moment. I want to make sure the dtsi and generic image are taken for currnet kernel;

## Ignore this: (until I properly update, some of this needs moving to source/README.md)

```console
# Install build-essentials (lots of packages, will take some time)
apt install build-essentials

# Enable source repos:
# As root edit the file: /etc/apt/sources.list.d/ubuntu.sources
# There should be two repo definitions, for both find the lines that say:
Types: deb
# add 'deb-src' so it now says
Types: deb deb-src
# Save and exit editor.

# As root, run
apt update
# you should see a load of new (source) repos being updated.
# - adding all these source repos slows apt down,
#   not much that can be done about this on such a slow machine.

# Now we can install the linux sources
# This can be done as a normal user
# note that the command used here `apt source` will download the sources to the current working folder, not a fixed location.

cd source
apt source linux-riscv
# Go for a coffee.. ignore the 'git clone' suggestion.
# This will take some time, and place the sources in the current
# directory.
# It will use ~1.6Gb of space.. so be prepared..

# If you re-run the command in this folder it will only update as needed, but is still somewhat slow since it verifies the existing downloads when updating.

```

# Rebuild dts tree for MQ pro..

Start by `cd`'ing into this [device tree](device-tree) folder and editing your device tree.

You can use the generic `sun20i-d1-mangopi-mq-pro.generic.dts` already in the device tree folder as a basis, or start with one of the ones provided with my precompiled trees.

You may also need to modify `sun20i-d1.dtsi` since this is where pin mappings are declared; eg UART pin sets are defined in this include file and then used in the main tree file.

A full-on tutorial for device tree editing is far beyond the scope of both this document and author.

#### Terms
* `.dts` is a top-level Device Tree Source file.
* `.dtsi` is a include file for the `.dts`
* `.dtb` is the binary compiled device tree, this is what we are building here, and is supplied to the kernel at boot time.

## Building the MQ PRO device tree (`.dtb`)
By default the Device Tree compiler (`/usr/bin/dtc`) should already be installed in Ubuntu server, as should the linux-headers for the kernel.

## Compile the mq-pro dts with the current kernel headers
Example here is against the 'default' 6.8.0-31 linux kernel from the Ubuntu 24.04 release
* cd into the `dtspp` folder and  clean: `rm *.dts *.dtsi`
* run `preprocess.sh` to precompile the files in the parent folder against the latest linux-headers.
* still in the `dtspp` folder run: 
  ```dtc sun20i-d1-mangopi-mq-pro.generic.dts > dtb-6.8.0-31-mqpro-generic.dtb```
  modify the version to reflect the current headers
* move the `.dtb` file into the `/boot` folder:
  `sudo mv dtb-6.8.0-31-mqpro-generic /boot/dtbs`
* make a soft link in `/boot` to this:
  `sudo ln -s dtbs/dtb-6.8.0-31-mqpro-generic.dtb /boot/dtb-mqpro`

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
This is covered in the 'precompiled trees' readme [here](../precompiled-trees#making-permanent).

### Bonus
The onboard (blue) status LED can be controlled via the sys tree:

`sudo sh -c "echo 1 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn on

`sudo sh -c "echo 0 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn off

You can make it flash as wifi traffic is seen with:

`sudo sh -c "echo phy0rx > /sys/devices/platform/leds/leds/blue\:status/trigger"`

# references/links:
https://manpages.ubuntu.com/manpages/focal/man1/dtc.1.html
https://forum.armbian.com/topic/29626-mango-pi-mq-pro-d1-device-tree-try-to-okay-serial/
https://github.com/torvalds/linux/tree/master/arch/riscv/boot/dts/allwinner
https://github.com/ners/MangoPi/tree/d2589d8211a2f9ae57d88f2e2c4d6a449d668f9e/MangoPi/linux/arch/riscv/boot/dts/allwinner
DTS version that is used in the official armbian image? 
https://github.com/smaeul/u-boot/tree/329e94f16ff84f9cf9341f8dfdff7af1b1e6ee9a/arch/riscv/dts
