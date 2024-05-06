# Precompiled device trees:
Each folder contains a `.dtb` file, which is the compiled device tree itself, plus a `.dts` with the original source and a `.gpio` file showing the GPIO pin mappings.

## Generic
[The generic device tree I will use in my project, suitable for many occasions](./generic)
* Has 2x UART (plus the console uart), 2x I2C. 1xSPI
* 12 unassigned GPIO pins

## Serial
[Four UART interfaces *and* Four I2C interfaces](./serial)
* Has 4x UART (plus the console uart), 4x I2C
* UART3 has RTC/CTS pins available too
* 10 unassigned GPIO pins

## SPI
[SPI plus Serial interfaces](./spi)
* Has 3x UART (plus the console uart), 3x I2C. 1xSPI
* 8 unassigned GPIO pins

## SunXI
[Vanilla, unpopulated, upstream](./sunxi)
* Has the console uart, nothing more
* *26 unassigned GPIO pins!*

## AllWinner Nezha
[DO NOT USE](./allwinner-nezha)
* Included for completeness, this is the default device tree you get with the Ubuntu image.
* Has the console uart, 1x I2C. 1xSPI
* 15 unassigned GPIO pins, 3 pre-assigned to pinctl

# Getting the DTB files
Clone this repo:
```console
$ git clone https://github.com/easytarget/MQ-Pro-IO.git
$ cd MQ-Pro-IO
```

# Examining the current DTB pin mappings:
In the [tools](../tools) folder there is a python script called `list-pins.py`.

To run it you need to be in that directory, then run:
`python3 list-pins.py MangoPi-MQ-Pro`
* This produces the same map I use in the documentation and `.gpio` files in the folders above.

# Install the Device Tree
Installing is, in principle, simple. 
* Clone this repo on to the MQ pro and, as root, copy the desired `.dtb` file to the `/boot/dbts` folder.
* Then make a soft link in the root of the /boot folder named `dtb-mqpro` that points to the file you just copied.
```console
$ sudo cp precompiled-trees/generic/6.8.0-31-generic.dtb /boot/dtbs/
$ cd /boot
$ sudo ln -s dtbs/6.8.0-31-generic.dtb dtb-mqpro
```

Finally, edit the `/boot/grub/grub.cfg` file to use the new DTB for the default 'Ubuntu' target:
* `sudo vi /boot/grub/grub.cfg`
* Look for the first block that begins with: `menuentry 'Ubuntu'`
* Comment out the existing entry and add a new one:
```console
        # devicetree     /boot/dtb-6.8.0-31-generic
        devicetree      /boot/dtb-mqpro
```

Reboot!

After rebooting you can re-run **list-pins.py** from above to verify the new mappings.

If you have errors rebooting (maybe a corrupt file if you rebuilt it etc..) you need to either boot using a USB serial adapter on the console pins and select the recovery image,  or, in grub, edit the command and revert to the generic `/boot/dtb`. 
As a last resort you may have to remove the SD card, mount the `/boot` partition and edit `grub/grub.cfg` there.
* !! The 'default' dtb supplied by ubuntu should always be softlinked as `/boot/dtb`, so putting `devicetree      /boot/dtb` in grub in place of the custom `.dtb` should work and is predictable (no version numbers etc).

## Making Permanent:
(As Root) Edit: `/etc/grub.d/10_linux` line 458 to say:
```
  for i in "dtb-mqpro" "dtb-${version}" "dtb-${alt_version}" "dtb"; do
```

Note that we are adding `dtb-mqpro` to the start of this list, this is the 'search list' for the DTB files, the full section reads:
```bash
  dtb=
  for i in "dtb-mqpro" "dtb-${version}" "dtb-${alt_version}" "dtb"; do
    if test -e "${dirname}/${i}" ; then
      dtb="$i"
      break
    fi
  done
```
When Grub next rebuilds it *should* make the new DTB the default for all entries now. (this is untested, as of this writing there have not been any kernel upgrades to test them on)
