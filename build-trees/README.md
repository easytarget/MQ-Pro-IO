# NOV 25, 2024
## Building is currently broken with the latest (**-49**) kernel.
### Ubuntu have updated the dts tree and with a newer include structure and this breaks the current tooling setup.
### I know how to fix this but it will be a few days before I can apply myself to this.

# Building and installing custom device trees.

This folder contains a `make_dtbs` script that can build device tree source (`.dts`) files against the correct upstream headers and device tree includes.

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
- Note that the command used here `apt source` will download the sources to the current working folder, not a fixed location
- It is run as a normal user, not root.

We download the sources into the [sources](../sources) folder:
```text
$ cd source
$ apt source linux-riscv
```
Go for a coffee.. ignore the 'git clone' suggestion.
- This will use ~1.6Gb of space.. so be prepared.

#### Updating sources
The `make_dtbs.sh` command used below will offer to update the source tree when run, this shoule be done wnenever a new kernel vesion s being built, but does not need to be re-done after that version has been fetched at least once.

You can also manually re-run the `apt source` command in this folder and it will only download and update as needed, but is still somewhat slow since it verifies the existing downloads when updating.

-------------------------------------------
# Building the device tree(s)

Run the build as a normal user (the same user used to fetch the sources above).
- Put your custom `.dts` in this folder.
- This folder also contains the necesscary softlinks to the include files in the source tree we just downloaded.

#### Terms
* `.dts` is a top-level Device Tree Source file.
* `.dtsi` is an include file for the `.dts`
* `.dtb` is the binary compiled device tree, this is what we are building here, and is supplied to the kernel at boot time.

## device tree sources
For convenience, the default `sun20i-d1-mangopi-mq-pro.dts` file from the Ubuntu source is also linked here.

Rather than modifying the default tree you should copy it to a custom name, eg 'my-project.dts'. Or you can copy in examples from the [alt-trees](../alt-trees/) folder.

A full-on tutorial for device tree editing is far beyond the scope of both this document and author.
* The examples show some simple custom modifications.
* Compare them to the original to see more.
  * Note how additional pin mappings had to be provided where the standard `.dtsi` includes do not provide them.

## Compile the mq-pro dts with the current kernel headers

To compile all the includes and sources simply run `make_dtbs.sh`.

This will:
* Pre-compile all the source and include files in the current folder into the output folder using the correct kernel headers.
* In the output folder it then compiles *all* the `.dts` files present.

```console
$ ./make_dtbs.sh
Update source tree (may be slow)? [y/N]:

Available kernels:
  [1]  6.8.0-41-generic
  [2]  6.8.0-44-generic
  [3]  6.8.0-47-generic
  [4]  6.8.0-48-generic - currently running kernel
Which kernel to build? [4]:

Building for kernel: 6.8.0-48-generic
Cleaning existing 6.8.0-48-generic build directory

Compiling against headers for 6.8.0-48-generic
Precompiling all includes in build root into 6.8.0-48-generic build directory
  sun20i-common-regulators.dtsi -> 6.8.0-48-generic/sun20i-common-regulators.dtsi
  sun20i-d1.dtsi -> 6.8.0-48-generic/sun20i-d1.dtsi
  sun20i-d1s.dtsi -> 6.8.0-48-generic/sun20i-d1s.dtsi
  sunxi-d1-t113.dtsi -> 6.8.0-48-generic/sunxi-d1-t113.dtsi
  sunxi-d1s-t113.dtsi -> 6.8.0-48-generic/sunxi-d1s-t113.dtsi
Precompiling all sources in build root into 6.8.0-48-generic build directory
  my-project.dts -> 6.8.0-48-generic/my-project.dts
  sun20i-d1-mangopi-mq-pro.dts -> 6.8.0-48-generic/sun20i-d1-mangopi-mq-pro.dts
Compiling all device tree sources in 6.8.0-48-generic build directory
  6.8.0-48-generic/my-project.dts -> 6.8.0-48-generic/my-project.dtb
  6.8.0-48-generic/sun20i-d1-mangopi-mq-pro.dts -> 6.8.0-48-generic/sun20i-d1-mangopi-mq-pro.dtb

Success. Consider running 'flash_latest.sh' to make permanent (see docs)
```
The `6.8.0-48-generic` folder now has our device tree: `my-project.dtb`
- We also generate the default device tree, this can be ignored.

The tool builds for *all* the kernels available on the system, not just the running kernel.
- As new kernels are updated the list of 'available' kernels will increase.

-----------------------

# Test Installing self-built DTB's
If this is the first time the tree is compiled after modifying it may be a good idea to do a 'quick' test that it boots properly before making it permanent.

### Move dtb into the boot tree
* move the `.dtb` file into the `/boot` folder: eg: `$ sudo mv 6.8.0-41-generic/my-project.dtb /boot/dtbs`
* make a soft link in `/boot` to this: `$ sudo ln -s dtbs/my-project.dtb /boot/dtb-mqpro`

### Set up Grub to test boot the new DTB
* backup the grub config: `$ sudo cp /etc/grub/grub.cfg /etc/grub/grub.cfg.mybackup`
* `$ sudo vi /etc/grub/grub.cfg`  (or use nano if you prefer)
  * Find the 1st `menuentry` section (the default Ubuntu one) and edit the `devicetree` line to look like:
```text
devicetree      /boot/dtb-mqpro
```
* Reboot (`$ sudo reboot`)
* If the reboot fails you can either attach a serial adapter to the GPIO pins and select the fallback kernel from the advanced options menu, and then restore the grub config backup once logged in.
  Or (if no serial available) remove the SD card, mount it on another (unix) computer and restore the grub config there.

After rebooting you can run **list-pins.py** to verify the new mappings.
* See the README in the [tools](../tools) folder for usage.

### Cleanup test
Once you are happy with the test you should make the change permanent as described below.
* Before you do the permanent install you *must* restore the backup copy of the grub config: `$ sudo mv /etc/grub/grub.cfg.mybackup /etc/grub/grub.cfg`
* Once that is done you can also clean up the `.dtb` file you manually placed in `/boot/`, and the softlink to it. 
  * *Do not remove the device tree file without restoring the grub config, it will leave the system unbootable!*
 
----------------------------------------------------

# Making Permanent:
We can use [flash-kernel](https://github.com/ubports/flash-kernel) to permanently apply our custom device tree.
* *Flash-kernel* normally searches in the linux firmware library to select the matching kernel version of the `.dtb` file for the machine (as specified in the database).
* But if a file of the same name is found in the `dtbs` override directory this will be used instead.

## Configure `flash-kernel` for the cusom device tree file
Similar to the way we reconfigured *flash-kernel* to use the MQ Pro device tree in the install guide, we can also configure it to use our custom kernel.

Add a new entry to `/etc/flash-kernel/db`:
```text
# Custom project entry
Machine: My Project
Kernel-Flavors: any
DTB-Id: custom/my-project.dtb
Boot-Script-Path: /boot/boot.scr
U-Boot-Script-Name: bootscr.uboot-generic
Required-Packages: u-boot-tools
```
Note that we specify `custom` in the DTB-Id instead of 'allwinner', this helps keep our trees apart from the vanilla (Ubuntu) ones in the boot tree.

Edit `/etc/flash-kernel/machine` to match the machine name in the definition:
```console
$ sudo mv /etc/flash-kernel/machine /etc/flash-kernel/machine.vanilla
$ sudo sh -c "echo 'My Project' > /etc/flash-kernel/machine"
```
Running *flash-kernel* immediately after this will fail since it cannot yet find the `.dtb` file specified in the database.
- We need to copy the `.dtb` to `/etc/flash-kernel/dtbs` first.

## Copying and flashing the device tree file
Run `flash_latest.sh`, this will ask you to confirm which kernel version you want to copy from.
- It defaults to the current running kernel.
- When upgrading this allows you to precompile and install the correct DTB in advance before rebooting into the new kernel.
- It needs root access via `sudo`, (you will be prompted to enter your password if using sudo with a password)

```console
$ ./flash_latest.sh

Available kernels:
  [1]  6.8.0-41-generic
  [2]  6.8.0-44-generic
  [3]  6.8.0-47-generic
  [4]  6.8.0-48-generic - currently running kernel
Which kernel to link? [4]:

Cleaning '/etc/flash-kernel/dtbs/' and copying in device tree binaries from '6.8.0-48-generic/'
  /home/owen/MQ-Pro-IO/build-trees/6.8.0-48-generic/my-project.dtb --> /etc/flash-kernel/dtbs/my-project.dtb
  /home/owen/MQ-Pro-IO/build-trees/6.8.0-48-generic/sun20i-d1-mangopi-mq-pro.dtb --> /etc/flash-kernel/dtbs/sun20i-d1-mangopi-mq-pro.dtb

Run 'flash-kernel' to apply device tree? [Y]: y
Using DTB: custom/my-project.dtb
Installing /etc/flash-kernel/dtbs/my-project.dtb into /boot/dtbs/6.8.0-48-generic/custom/my-project.dtb
Taking backup of my-project.dtb.
Installing new my-project.dtb.
System running in EFI mode, skipping.

If flash-kernel was successful and configured properly the new device tree will be used after reboot
```
After this, reboot to use the new device tree.

It is good practice to update the dtb when new kernels become available. But Ubuntu 24.04.1 is a LTS release, and the DTB should be stable going forward so you may not find it necesscary.

To Update, re-fetch the latest sources (see above), then re-run `make_dtbs.sh` and `flash_latest.sh`.

--------------------------------------------------------------------------

# references/links:
- https://manpages.ubuntu.com/manpages/focal/man1/dtc.1.html
- https://forum.armbian.com/topic/29626-mango-pi-mq-pro-d1-device-tree-try-to-okay-serial/
- https://github.com/torvalds/linux/tree/master/arch/riscv/boot/dts/allwinner
- https://github.com/ners/MangoPi/tree/d2589d8211a2f9ae57d88f2e2c4d6a449d668f9e/MangoPi/linux/arch/riscv/boot/dts/allwinner

Device Tree that is used in the official armbian image?
- https://github.com/smaeul/u-boot/tree/329e94f16ff84f9cf9341f8dfdff7af1b1e6ee9a/arch/riscv/dts
