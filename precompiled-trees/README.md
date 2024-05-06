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

# Examining the current DTB pin mappings:
In the [tools](../tools) folder there is a python script called `list-pins.py`.

To run it you need to be in that directory, then run `python3 list-pins.py MangoPi-MQ-Pro` to see a map of the current pin assignments (the same map I use in `.gpio` files in the folders above.) 

# Install and use
Installing is simple, clone this repo on to the MQ pro and, as root, copy the desired `.dtb` file to the `/boot/dbts` folder.

Then make a soft link in the root of the /boot folder named `dtb-mqpro` that points to the file you just copied.

Finally, edit the `/boot/grub/grub.cfg` file to use the new DTB for the default 'Ubuntu' target.

Reboot!

After rebooting you can re-run **list-pins.py** from above to verify the new mappings.

If you have errors rebooting (maybe a corrupt file if you rebuilt it etc..) you need to either boot using a USB serial adapter on the console pins and select the recover image (or edit the command and revert to the generic `.dtb`). Or remove the SD card, mount the /boot partition and edit the `grub/grub.cfg` file there.

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
