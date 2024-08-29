# MangoPI MQ Pro Device Trees for Bluetooth and GPIO
### The MQ pro is a single core allwinner D1 64bit 1Ghz, 1Gb risc-v based Pi-Zero-alike.

This is a guide for enabling bluetooth and using the MangoPi MQ pro's IO capabilities when running Ubuntu 24.04.

`24.04` is a LTS+ release from Ubuntu, and should provide 5+ years of updates. As such it makes a good choice for an unattended headless device.

## Installing Ubuntu
There is *no* specific image provided by Ubuntu for the MQ PRO, but they *do* provide an image for the 'FIX!!!' which installs and boots on the MQ Pro with almost everything working.

Please refer to the Ubuntu documentation and forums if struggling with this.
- I had issues getting a successful first boot with a cheap SD card, using a brand-name (Kingston) high speed card solved all the issues.
- I am also using a high wear resistance card since I want this to run for years in a hard-to-reach location.

There is no HDMI output (console) with the image.
- EXPAND!!!

### steps:
<EDITED LOG HERE>

# My Motivation:
My MQ PRO is connected to a Waveshare LORA hat, I want to make it work but the default Nezha device tree conflicts with some of the pins my HAT uses. So I decided to 'fix' this be putting a better device tree on it.

![My Hardware](waveshare_SX1268_LoRa_HAT/overview.jpg)

# Device Trees
In the install steps above we reconfigure the system to use the correct MangoPI MQ pro device tree instead of the ??FIX?? one.

A device tree is a file that defines the structure of the peripherals attached to, and provided by, the GPIO and internal busses on a SBC.

It is used in several places during initial boot to discover storage, console and other devices as needed. Once the linux kernel starts it is used to provision devices such as UART, network, gpu and other hardware. The device tree itself is a source file that is compiled into a binary to be loaded during boot.

In this guide we only replace the device tree used by the kernel when Linux is started in the final stages of boot up. 

We do not need to modify the device tree used by U-Boot, or the kernel init processes, they still use the default (??FIX??) device tree they were compiled against. Because this part of the boot process already works correctly we can avoid the complexity of recompiling anything.

## Roll Your Own Device Tree
Hopefully you can do what you need with the default tree, and dynamically create your devices on it via `pinctl`.

But if not; my somewhat limited notes on compiling the tree, plus a script that handles running the C preprocessor on them (needed to get a working binary) are in the [build-trees](./build-trees) folder.

# Using the new tree

## Enabling Bluetooth
After cheanging to the correct device tree you also need the correct firmware for the bluetooth adapter, a copy of this is in the [files/rtl_bt/](./files/rtl_bt) folder.
* Copy the two firmware (`.bin`) files to `/usr/lib/firmware/rtl_bt/` on the MQ PRO and reboot.
* Install *Bluez* (`sudo apt install bluez`) and then you can use `bluetoothctl` to configure and connect

## Status LED
The onboard (blue) status LED can be controlled via the sys tree:

`sudo sh -c "echo 1 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn on

`sudo sh -c "echo 0 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn off

You can make it flash as wifi traffic is seen with:

`sudo sh -c "echo phy0rx > /sys/devices/platform/leds/leds/blue\:status/trigger"`

You can make this permanent by, as root, copying `tools/mqpro-status-led.service` to `/etc/systemd/system/`, running `systemctl daemon-reload` then `systemctl enable --now mqpro-status-led.service`.

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
