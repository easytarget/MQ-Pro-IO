# MangoPI MQ Pro Device Trees for Bluetooth and GPIO

The MQ pro is a single core RISC-V allwinner D1 64bit 1Ghz CPU, with 1Gb RAM, HDMI and Wifi, in a Pi-Zero form factor Single Board Computer.

It runs Linux, and is quite usable as a small headless (networked, non GUI) machine.

![reference/MangoPi-MQ-Pro-view.jpg](reference/MangoPi-MQ-Pro-view.jpg)

## This is a guide for enabling bluetooth and using the MangoPi MQ pro's IO capabilities when running Ubuntu 24.04.1

The `24.04.1` is a LTS+ release from Ubuntu and should provide 5+ years of updates. 

As such it makes a good choice for an unattended headless device.

Unfortunately there is no [Official Ubuntu image](https://ubuntu.com/download/risc-v) for the MQ Pro, but you can use the image for the Sipeed LicheeRV dock. This has the same SOC as the MQ-Pro, and boots properly.

Once the LicheeRV image is booted you can swap the device tree it uses for the MQ-Pro one.
- Vanilla device trees for all current Risc-v platforms are provided as part of the firmware package for each kernel.
- This means that the mqpro device tree *is* available, but is not the default installed by `flash-kernel` for the image file we use.
  - You can reconfigure `flash-kernel` with a different default device tree name in config.
  - This is future proof, each new kernel deliveres a new device tree that will be installed as the kernel is upgraded.

The idea of compiling your own Device Tree is depreciated in favor of the vanilla mqpro devicetree and using gpiod and pinctl to setup devices.
- However, I also have instructions for doing this, for those who like to tinker.

-----------------------------

## Install Steps
If you have set up SD card based systems before the following should feel familiar. You will need a SD card to boot and run the system.
- I had issues getting a successful first boot with a *generic* cheap SD card, using a brand-name (Kingston) high speed card solved all the issues.
- I am also using a high wear resistance card since I want this to run for years in a hard-to-reach location.

### Notes
Unfortunately HDMI only starts very late in the boot process, you cannot use it to select GRUB options, and the console is not usable until the boot is complete.
- Once the console login is available You can use a USB keyboard with it, and install `gpm` to get a working mouse. 
- Once I had bluetooth working I was able to attach and use a bluetooth kbd+mouse.

If you have a USB serial adapter available you can follow the entire boot process
- This is the only way to access the GRUB prompt and select recovery options etc!
- Make sure your adapter is set to 3.3v and *not* 5v. This is important.
- Attach `gnd`, `tx` and `rx` to pins `6`, `8` and `10` on the GPIO header.
- See Jeff Geerlings excellent '[serial console uart debugging](https://www.jeffgeerling.com/blog/2021/attaching-raspberry-pis-serial-console-uart-debugging) article for a good description. His example is for a Raspberry PI, but MQ Pro is *identical* to a Pi for this.

The WiFi module will be detected, but will not connect to any networks unless preconfigured on the SD card before first boot.
- The instructions below show how to do this. (Requires a linux machine to mount & modify the SD card.)
- Alternatively, wait for the console boot to finish and configure the network on that using netplan, this is also covered below.

If you have a Linux compatible USB Ethernet adapter you can attach that to the spare USB-C port on the MQ-Pro.
- It will be detected and connected (using DHCP) during boot.
- You will need to find the assigned IP from router logs, netscan, or looking on the console.

### Creating SD card
You will need a suitable machine to download the image file to, with a SD card writer so the image can be written. 
- The instructions below are for a generic Linux system with a sd card writer.
  - As ever with this sort of operation make *absolutely* sure you are using the correct disk device when writing.
  - The example here assumes `/dev/mmcblk0`, which is the inbuilt SD card slot onm *my* system. ymmv.
- Windows users need to ignore the linux steps and use a tool such as Belena Etcher or similar to burn the SD card, before skipping to [first boot](#first-boot).

Get the image file; (as of 2-Sep-2024 the url below works).
```console
$ wget https://cdimage.ubuntu.com/releases/noble/release/ubuntu-24.04.1-preinstalled-server-riscv64+licheerv.img.xz
```

Unpack and copy the downloaded image to the SD card:
```console
$ xzcat ubuntu-24.04.1-preinstalled-server-riscv64+licheerv.img.xz | sudo dd bs=8M conv=fsync status=progress of=/dev/mmcblk0
```

If you are going to configure Wifi/Network via the console or using a USB Ethernet adapter you can skip to [`First Boot`](#first-boot) below.

#### Preconfiguring WiFi networks

Mount the SD card you just created:
```console
$ sudo mount /dev/mmcblk1p1 /mnt
```
Create a new network config file that will be applied at first init:
```console
$ sudo vi /mnt/etc/cloud/cloud.cfg.d/55_net.cfg
```
It should have the following contents:
```yaml
network:
    version: 2
    wifis:
        wlan0:
            optional: true
            access-points:
                "SSID":
                    password: "PASSWORD"
            dhcp4: true
```
- Replace 'SSID' and 'PASSWORD' with your details, multiple ssid/password line pairs are allowed.
- This is for a very simple 'connect to accesspoint' scenario.
  - The Netplan syntax allows almost any possible Network setup to be preconfigured!
  - See the [Netplan Documentation](https://netplan.readthedocs.io/en/stable/examples/) for lots of examples and the full syntax.
- After first boot this file will be copied (with some comments) to `/etc/netplan/50-cloud-init.yaml`.
  - If you made a mistake in the config, or need to change details, edit it in `/etc/netplan/` and use `netplan try` to test the new configuration.

Unmount the filesystem so that it is synced properly.
```console
$ sudo umount /mnt
```
Eject the SD card.

### First Boot
Insert the SD card into the MQ Pro and apply power.
- First boot is SLOW. It will take 5+ minutes before anything useful appears on HDMI.
  - This is where a serial adapter is handy for following progress.
- The HDMI console first appears after several minutes but then freezes soon after, it recovers after a while when the login prompt appears.

Once the machine has booted you can login on console or ssh as `ubuntu:ubuntu`, and follow the mandatory instructions to change password.

#### WiFi config after first boot
If you are setting up WiFI *after* first boot you can use [`netplan`](https://netplan.io) to configure the WiFi.

Create and edit a file in the netplan config:
```console
$ sudo vi /etc/netplan/55-wifi.yaml
```
The contents of this are ***identical*** to the [precofigured WiFi](#preconfiguring-wifi-networks) setup given above.
- Copy the `yaml` definition given there to this file and edit with your details.
- The comments for the file there also apply here.

### Reconfigure to use MangoPI Device Tree

You should now have bootable machine you can access via the console or SSH. We can now reconfigure this to use the MQ Pro device tree via [`flash-kernel`](https://manpages.debian.org/testing/flash-kernel/flash-kernel.8.en.html).

```console
ubuntu@ubuntu:~$ sudo vi /etc/flash-kernel/db
```
Append the following after the comments:
```text
Machine: MangoPI MQ pro
Kernel-Flavors: any
DTB-Id: allwinner/sun20i-d1-mangopi-mq-pro.dtb
Boot-Script-Path: /boot/boot.scr
U-Boot-Script-Name: bootscr.uboot-generic
Required-Packages: u-boot-tools
```
This adds a new custom entry for the MQ Pro based on the default LicheeRV dock definition from `/usr/share/flash-kernel/db/all.db`, but with the correct name and device tree.

Make this the default with:
```console
ubuntu@ubuntu:~$ sudo echo 'MangoPI MQ pro' > /etc/flash-kernel/machine
```
We now apply this by running `flash-kernel` manually (it is run automatically by dpkg whenever kernel images are (re)installed).
```console
ubuntu@ubuntu:~$ sudo flash-kernel
Using DTB: allwinner/sun20i-d1-mangopi-mq-pro.dtb
Installing /lib/firmware/6.8.0-41-generic/device-tree/allwinner/sun20i-d1-mangopi-mq-pro.dtb into /boot/dtbs/6.8.0-41-generic/allwinner/sun20i-d1-mangopi-mq-pro.dtb
Taking backup of sun20i-d1-mangopi-mq-pro.dtb.
Installing new sun20i-d1-mangopi-mq-pro.dtb.
System running in EFI mode, skipping.
```
Reboot the system and you will be using the default (vanilla) device tree.
```console
$ sudo reboot
# wait while it reboots then ssh into the machine as ubuntu:<new passwd>
$ sudo cat /proc/device-tree/model
```
This should return `MangoPi MQ Pro`

### Update 
```console
$ apt update
```
Let this run
- It will eventually tell you that a lot of packages need updating
```console
$ apt upgrade
```
You may see packages 'deferred due to phasing', this is quite normal, an artifact of Ubuntu's build system. These can safely be ignored.

When this completes reboot again, or finish the BT setup below first since it also needs a reboot.

#### Setup Bluetooth adapter and status LED
Get the Bluetooth firmware files, they can be found online, but thee is a copy in my repo for convenience.
```console
$ git clone https://github.com/easytarget/MQ-Pro-IO.git
```
Copy Bluetooth firmware to the system firmware tree.
```console
$ sudo cp MQ-Pro-IO/files/rtl_bt/* /usr/lib/firmware/rtl_bt/
```
 Before you reboot to apply these you should also install `bluez`, which allows you to use `bluetoothctl` to connect and pair,etc
```console
$ sudo apt install bluez
$ sudo reboot
```
# Set up a service for the activity light
```console
$ sudo cp MQ-Pro-IO/files/mqpro-status-led.service /etc/systemd/system/
$ sudo systemctl daemon-reload
$ sudo systemctl enable --now mqpro-status-led.service
```
The Status LED should now be continually flashing with Network activity, there is more on controlling this below.

--------------------------------------------------------------------

# My Motivation:
My MQ PRO is connected to a Waveshare LORA hat, I want to make it work but the default device tree conflicts with some of the pins my HAT uses. So I decided to 'fix' this by putting a better device tree on my board.

![My Hardware](reference/waveshare_SX1268_LoRa_HAT/overview.jpg)
# Device Trees
In the install steps above we reconfigure the system to use the correct MangoPI MQ pro device tree instead of the Sipeed Lichee RV one.

A device tree is a file in the `/boot` area file that defines the structure of the hardware provided by the chipset on a SBC.

It is used in several places during initial boot to discover storage, console and other devices as needed. Once the linux kernel starts it is used to provision devices such as UART, network, gpu and other hardware. The device tree itself is a source file that is compiled into a binary to be loaded during boot.

In this guide we only replace the device tree used by the kernel when Linux is started in the final stages of boot up. 

We do not need to modify the device tree used by U-Boot, or the kernel init processes, they still use the default (Sipeed Lichee RV) device tree they were compiled against. Because this part of the boot process already works correctly we can avoid the complexity of recompiling anything.

## Roll Your Own Device Tree
Hopefully you can do what you need with the default tree, and dynamically create your devices on it via `gpiod` and `pinctl`.

But if not; my somewhat limited notes on compiling the tree, plus a script that handles running the C preprocessor on them (needed to get a working binary) are in the [build-trees](./build-trees) folder.

# Using the trees

## Status LED
The onboard (blue) status LED can be controlled via the sys tree:

`sudo sh -c "echo 1 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn on

`sudo sh -c "echo 0 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn off

You can make it flash as network traffic is seen with:

`sudo sh -c "echo phy0rx > /sys/devices/platform/leds/leds/blue\:status/trigger"`

You can make this permanent by, as root, copying `tools/mqpro-status-led.service` to `/etc/systemd/system/`, running `systemctl daemon-reload` then `systemctl enable --now mqpro-status-led.service`.

Other control options are available, `sudo cat /sys/devices/platform/leds/leds/blue\:status/brightness` shows a list and the current selection. Most do not work or are not very useful; ymmv.

## Using GPIO
Providing a full GPIO how-to is beyond the scope of this document, I use GPIOd to do this. But have also used direct pinctl control via the `/sys/class/gpio` tree.

There are many tutorials on doing this online that give a better explanation than I can here

## Allwinner D1 GPIO pins
The **D1** SOC runs at 3v3, and you must not exceed this on any of the GPIO pins. The drive current is also very limited, a maximum of 4mA on any individual pin, and 6mA total across a bank of pins (eg the 12 pins in the `*PB*` bank combined cannot draw more than 6mA!).

Pins are organised into 7 'banks' (*PA*, *PB*, etc to *PG*) of up to 32 pins, but most banks have fewer pins.

## GPIO Pin Muxing
The **D1** SOC itself has 88 GPIO pins.

In the MQ PRO some of these GPIO pins are wired directly to peripherals on the board (eg SD card, Wifi chip, etc.) but that still leaves many free lines.

The board has a 'standard' Raspberry Pi compatible 40 pin GPIO connector; 12 are reserved for Power lines, leaving 28 GPIO pins available for the user.

Internally, the **D1** has a number of internal hardware interfaces for different signal types; 6xUART for serial, 2xSPI, 4xI2C(TWI), 3xI2Si/PCM (audio), 8xPWM, and some additional units for USB, HDMI, Audio, and more (see the Data sheet)

The **D1** chip has an internal 'pin muxer' to connect pins to signals. Each pin can connect to a (predefined) set of signals, which allows you to map each pin on the GPIO header to multiple possible functions.

You can browse the full range of mappings in the Allwinner D1 datasheet, Table 4-3.
- A copy of this table is available here: [reference/d1-pins.pdf](reference/d1-pins.pdf)).

Additionally all pins are high-impedance by default and can be set to a HIGH or LOW digital output. They can all work as digital inputs, and all have configurable pull-up and pull down resistors, and can generate interrupts. PWM and ADC input capable pins are limited, see the datasheet for more.

### Internal interfaces
The MQ Pro uses several of the **D1**s interfaces on-board, specifically:

`UART1` is used to connect to the the bluetooth device by default (with flow control) using `PG6`, `PG7`, `PG8` and `PG9`. It can be reconfigured onto GPIO pins if bluetooth is not required.

`TWI2` (`I2C2`) can be  mapped to the DVP connector (for touchscreen interfaces) via pins `PE12` and `PE13`.

`TWI3` (`I2C3`) can be mapped to the DSI/LVDS connector via pins `PE16` and `PE17`; which also appear on the GPIO connector.

`SPI0` is mapped to the optional SPI flash chip (not fitted on consumer units), and cannot be mapped to the GPIO connector.

### Pin Mapping EXAMPLE
The D1 has 6 internal UARTs, and many pin mappings are possible on the GPIO connector.

When creating a device tree you can create any pin mapping that conforms to this:
```text
                        3v3  -- o o -- 5v
         UART1-RX   PG13 ------ o o -- 5v
         UART1-TX   PG12 ------ o o -- GND
         UART3-RX   PB7  ------ o o ------ PB8   UART0-TX,UART1-TX
                         GND -- o o ------ PB9   UART0-RX,UART1-RX
         UART1-TX   PD21 ------ o o ------ PB5   UART5-RX
         UART1-RX   PD22 ------ o o -- GND
UART2-TX,UART0-TX   PB0  ------ o o ------ PB1   UART0-RX,UART2-RX
                         3v3 -- o o ------ PD14  UART3-CTS
                    PD12 ------ o o -- GND
         UART3-RTS  PD13 ------ o o ------ PC1   UART2-RX
         UART3-RX   PD11 ------ o o ------ PD10  UART3-TX
                         GND -- o o ------ PD15
                    PE17 ------ o o ------ PE16
         UART1-RTS  PB10 ------ o o -- GND
         UART1-CTS  PB11 ------ o o ------ PC0   UART2-TX
                    PB12 ------ o o -- GND
         UART3-TX   PB6  ------ o o ------ PB2   UART4-TX
                    PD17 ------ o o ------ PB3   UART4-RX
                         GND -- o o ------ PB4   UART5-TX
```
Notes:
- `UART0` maps by default to gpio pins 8 and 10 (*PB8* and *PB9*) is the used for the system console by default at boot and you should expect data on it during boot even if you disable it in the device tree as the kernel starts.
- `UART1` is normally used by the bluetooth adapter, enabling it here will disable bluetooth.
- `UART1` and `UART3` have flow control lines (rts and cts) available
- some pins do not map to any UART devices

## References
There are reference copies of the MQ PRO schematic and the AllWinner D1 datasheet in the [references](./reference) folder.

Online:
* https://mangopi.org/mangopi_mqpro
* https://linux-sunxi.org/MangoPi_MQ-Pro
* https://github.com/boosterl/awesome-mango-pi-mq-pro
