# Alternate device tree Examples:
Each folder contains a `.dts` file and a README showing the GPIO pin mappings.

## Use
Copy the desired `.dts` file(s) to the [build-trees](../build-trees) folder and follow the readme there to build the device-tree binaries.

There are instructions at the end of that document on how to make this permanent across reboots and kernel upgrades, some example flash-kernel database entries are given below for convenience.

## Caveat
The issue with using these trees is that **if** the upstream device tree or includes is modified you need to manually rebuild these trees.

EG any changes to the upstream `sun20i-d1-mangopi-mq-pro.dts` source needs to be detected and applied too. You need to examine file histories to do this.
- Fortunately this should not be an issue in practice; the kernel *should* remain very stable going forward. Ubuntu 24.04.1 is a LTS release..

## HAT
[Emulates a standard PI hat pinout](./hat)
* 1x SPI
* 2x I2C
* Console UART only
* 16 unassigned GPIO pins

## LoRa HAT
[Expanded HAT pinout for my LoRa hat use](./lora-hat)
* 1x SPI
* 2x I2C
* 1x UART (plus the console uart)
* 4x PWM
* 11 unassigned GPIO pins

## SPI and I2C
[SPI plus I2C interfaces](./spi-i2c)
* 1x SPI
* 4x I2C
* 3x UART (plus the console uart)
* 6 unassigned GPIO pins

## Serial
[Four UART interfaces](./serial)
* 4x UART (plus the console uart)
  * UART3 has RTC/CTS pins available too
* 2x I2C
* 12 unassigned GPIO pins

#### Example `/etc/flash-kernel/db` entries
```text
# Custom kernels

Machine: MQpro HAT
Kernel-Flavors: any
DTB-Id: custom/mqpro-hat.dtb
Boot-Script-Path: /boot/boot.scr
U-Boot-Script-Name: bootscr.uboot-generic
Required-Packages: u-boot-tools

Machine: MQpro LoRa HAT
Kernel-Flavors: any
DTB-Id: custom/mqpro-lora-hat.dtb
Boot-Script-Path: /boot/boot.scr
U-Boot-Script-Name: bootscr.uboot-generic
Required-Packages: u-boot-tools

Machine: MQpro Serial
Kernel-Flavors: any
DTB-Id: custom/mqpro-serial.dtb
Boot-Script-Path: /boot/boot.scr
U-Boot-Script-Name: bootscr.uboot-generic
Required-Packages: u-boot-tools

Machine: MQpro SPI I2C
Kernel-Flavors: any
DTB-Id: custom/mqpro-spi-i2c.dtb
Boot-Script-Path: /boot/boot.scr
U-Boot-Script-Name: bootscr.uboot-generic
Required-Packages: u-boot-tools
```
