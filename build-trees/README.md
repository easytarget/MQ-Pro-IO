# Building and installing custom device trees.

This folder contains a `make-trees` script that can build device tree source (`.dts`) files against the correct upstream headers and device tree includes.

## Preparation / requirements

### Compile and make tooling
You need `build-essential` installed:
```console
$ apt install build-essential
```
*This will take a while.. as will most commands described here!*

By default the Device Tree compiler (`/usr/bin/dtc`) should already be installed in Ubuntu server, as should the linux-headers for the kernel.

### Enable source repos:
As root edit the file: `/etc/apt/sources.list.d/ubuntu.sources`

There should be two repo definitions, find the lines in them that say:
```console
Types: deb
```
And add `deb-src` so it now says:
```console
Types: deb deb-src
```
Save and exit editor.

Run
```console
$ sudo apt update
```
You should see a load of new (source) repos being updated, it is slow, let it finish.

### Get the linux sources
This should be done as a normal user
- Note that the command used here `apt source` will download the sources to the current working folder, not a fixed location, and is intended to be run as a normal user.

We download the sources into the [sources](../sources) repo in this folder:
```text
$ cd source
$ apt source linux-riscv
```
Go for a coffee.. ignore the 'git clone' suggestion.
- This will use ~1.6Gb of space.. so be prepared.

#### Updating sources
You can re-run the `apt source` command in this folder and it will only download and update as needed, but is still somewhat slow since it verifies the existing downloads when updating.

-------------------------------------------
# Building the device tree(s)

Build the sources as a normal user (the same user used to fetch the sources above), in this folder.

#### Terms
* `.dts` is a top-level Device Tree Source file.
* `.dtsi` is a include file for the `.dts`
* `.dtb` is the binary compiled device tree, this is what we are building here, and is supplied to the kernel at boot time.

## device tree sources
By default the standard `sun20i-d1-mangopi-mq-pro.dts` file from the Ubuntu source is linked here. 

Rather than modifying the default tree you should copy it to a custom name, eg 'my-project-mqpro.dts'. Or you can copy in examples from the [alt-trees](../alt-trees/) folder.

A full-on tutorial for device tree editing is far beyond the scope of both this document and author.
* The examples show some simple custom modifications.
* Compare them to the original to see more.
  * Note how additional pin mappings had to be provided where the standard `.dtsi` includes do not provide them.

## Compile the mq-pro dts with the current kernel headers

To compile all the includes and sources simply run `make-trees.sh`.

This will:
* Create an output folder named after the kernel version, or clean an existing output folder.
* Pre-compile all the source and include files in the current folder into the output folder using the current kernel headers.
* In the output folder it then compiles *all* the `.dts` files present, and prefixes the output `.dtb` files with the kernel version.

```console
$ ./make_dtb.sh
Compiling against headers for 6.8.0-41-generic
Creating new build directory: 6.8.0-41-generic
Precompiling all includes in build root into 6.8.0-41-generic build directory
  sun20i-common-regulators.dtsi -> 6.8.0-41-generic/sun20i-common-regulators.dtsi
  sun20i-d1.dtsi -> 6.8.0-41-generic/sun20i-d1.dtsi
  sun20i-d1s.dtsi -> 6.8.0-41-generic/sun20i-d1s.dtsi
  sunxi-d1-t113.dtsi -> 6.8.0-41-generic/sunxi-d1-t113.dtsi
  sunxi-d1s-t113.dtsi -> 6.8.0-41-generic/sunxi-d1s-t113.dtsi
Precompiling all sources in build root into 6.8.0-41-generic build directory
  my-project-mqpro.dts -> 6.8.0-41-generic/my-project-mqpro.dts
  sun20i-d1-mangopi-mq-pro.dts -> 6.8.0-41-generic/sun20i-d1-mangopi-mq-pro.dts
Compiling all device tree sources in 6.8.0-41-generic build directory
  6.8.0-41-generic/my-project-mqpro.dts -> 6.8.0-41-generic/6.8.0-41-generic-my-project-mqpro.dtb
  6.8.0-41-generic/sun20i-d1-mangopi-mq-pro.dts -> 6.8.0-41-generic/6.8.0-41-generic-sun20i-d1-mangopi-mq-pro.dtb
```

-----------------------

# Test Installing self-built DTB's

### Move dtb into the boot tree
* move the `.dtb` file into the `/boot` folder: eg: `$ sudo mv 6.8.0-41-generic-my-project-mqpro.dtb /boot/dtbs`
* make a soft link in `/boot` to this: `$ sudo ln -s dtbs/6.8.0-41-generic-my-project-mqpro.dtb /boot/dtb-mqpro`

### Set up Grub to test boot the new DTB
Initially we will test the new dtb:
* backup the grub config: `$ sudo cp /etc/grub/grub.cfg /etc/grub/grub.cfg.mybackup`
* `$ sudo vi /etc/grub/grub.cfg`  (or use nano if you prefer)
  * Find the 1st `menuentry` section (the default Ubuntu one) and edit the `devicetree` line to look like:
```text
devicetree      /boot/dtb-mqpro
```
* Reboot (`$ sudo reboot`)
* If the reboot fails you can either attach a serial adapter to the GPIO pins and select the fallback kernel from the advanced options menu, and then restore the grub config backup once logged in.
  Or (if no serial available) remove the SD card, mount it on another computer and restore the file there.

After rebooting you can run **list-pins.py** (see below) to verify the new mappings.

If you have errors rebooting (maybe a corrupt file if you rebuilt it etc..) you need to either boot using a USB serial adapter on the console pins and select the recovery image,  or, in grub, edit the command and revert to the generic `/boot/dtb`.
As a last resort you may have to remove the SD card, mount the `/boot` partition and edit `grub/grub.cfg` there.
* !! The 'default' dtb supplied by ubuntu should always be softlinked as `/boot/dtb`, so putting `devicetree      /boot/dtb` in grub in place of the custom `.dtb` should work and is predictable (no version numbers etc).

## Examining the DTB pin mappings with `list-pins.py`
In the [tools](../tools) folder there is a python script called `list-pins.py`.

To run the pin list tool you need to be in the tools directory, then run:
```console
$ python3 list-pins.py MangoPi-MQ-Pro
```
* The script requires root acces (via sudo) to read the pin maps.
* Running the script produces the same map I use in this documentation.
* The data used to assemble the `.gpio` map files identifies which interface a pin is attached to, but not it's specific function for the interface.
  * eg it can say 'pinX and pinY are mapped to UART2', but cannot identify which pin is the TX and which is the RX; a limitation of the data, my apologies..
  * You therefore need to reference the [D1 pin mapping table](../reference/d1-pins.pdf) to get the exact functions for pins when running this for yourself.
* The README files uploaded for alternate device trees *have been manually edited* to note full pin function for convenience.

### Cleanup test
Once you are happy with the test you should make the change permanent as described below.
* Before you do the permanent install you *must* restore the backup copy of the grub config: `$ sudo mv /etc/grub/grub.cfg.mybackup /etc/grub/grub.cfg`
* Once that is done you can also clean up any test `.dtb` files you manually placed in `/boot/`, and the softlink to them. 
* *Do not remove the files without restoring the grub config, it will leave the system unbootable!*

----------------------------------------------------

# Making Permanent:
We can use [flash-kernel](https://github.com/ubports/flash-kernel) to permanently apply our custom device tree. *Flash-kernel* allows an 'override' device tree to be specified that will be used in place of the tree provided by the linux firmware package.

*Flash-kernel* normally searches in the linux firmware library to select the matching kernel version of the `.dtb` file for the machine (as specified in the database). But if a file of the same name is found in the `dtbs` override directory this will be used instead.

If we soft-link our custom `.dtb` file from this directory and re-run `flash-kernel` it will be installed to the `/boot/dtbs/` tree and used at next boot. 
- As with all the device tree tests above an error here might produce an unbootable machine!

```text
$ cd /etc/flash-kernel/dtbs/
$ sudo ln -s /home/<user+path>/MQ-Pro-IO/build-trees/6.8.0-41-generic/6.8.0-41-generic-my-project-mqpro.dtb sun20i-d1-mangopi-mq-pro.dtb
```
In this example I am soft linking directly to the `.dtb` I built.

Run `flash-kernel` again: you will see the overide being applied.
```console
$ sudo flash-kernel 
Using DTB: allwinner/sun20i-d1-mangopi-mq-pro.dtb
Installing /etc/flash-kernel/dtbs/sun20i-d1-mangopi-mq-pro.dtb into /boot/dtbs/6.8.0-41-generic/allwinner/sun20i-d1-mangopi-mq-pro.dtb
Taking backup of sun20i-d1-mangopi-mq-pro.dtb.
Installing new sun20i-d1-mangopi-mq-pro.dtb.
System running in EFI mode, skipping.
```
After this, reboot to use the new device tree.

A *flash-kernel* installs a full copy of the `.dtb` into the `/boot/` area, so deleting or moving the build folder will not 'break' bootup, but it *will* break kernel image rebuilds when `dpkg` tries to re-run the *flash-kernel* command and the softlink target has disappeared. Be warned!

It is good practice to keep the build repo and (periodically) update the dtb when new kernels becme available. But Ubuntu 24.04.1 is a LTS release, and the DTB should be stable going forward so you may not find it necesscary.

--------------------------------------------------------------------------

# references/links:
- https://manpages.ubuntu.com/manpages/focal/man1/dtc.1.html
- https://forum.armbian.com/topic/29626-mango-pi-mq-pro-d1-device-tree-try-to-okay-serial/
- https://github.com/torvalds/linux/tree/master/arch/riscv/boot/dts/allwinner
- https://github.com/ners/MangoPi/tree/d2589d8211a2f9ae57d88f2e2c4d6a449d668f9e/MangoPi/linux/arch/riscv/boot/dts/allwinner

Device Tree that is used in the official armbian image?
- https://github.com/smaeul/u-boot/tree/329e94f16ff84f9cf9341f8dfdff7af1b1e6ee9a/arch/riscv/dts

