# MangoPI MQ Pro Device Trees for Bluetooth and GPIO
### The MQ pro is a single core allwinner D1 64bit 1Ghz, 1Gb risc-v based Pi-Zero-alike.

This is a guide for enableing bluetooth and using the MangoPi MQ pro's IO capabilities when running Ubuntu 24.04.

`24.04` is a LTS+ release from Ubuntu, and should provide 5+ years of updates etc. As such it makes a very good choice for this board as a unattended headless device.

## Install
There is *no* specific image provided by Ubuntu for the MQ PRO, but they *do* provide an image for the 'AllWinner Nezha' which installs and boots on the MQ Pro.

- Download the 'AllWinner Nezha' Ubuntu image (compatible with the MQ pro) from: https://ubuntu.com/download/risc-v
- Follow the instructions linked there to create a SD/TF card image and boot the MQ Pro using it.
- WAIT!
  - First boot is super-slow, it may take 10+ mins before you see anything on the HDMI console.
  - If you have a USB-Serial adapter you can follow the boot via the serial console (`UART0` on the GPIO connector)
- Eventually you can log in (`ubuntu`,`ubuntu`) and will be guided through changing password etc.
- TODO: Wifi Setup
- Run `apt update` then `apt upgrade` and install whatever else you need.

The only thing **not working** out of the box is **Bluetooth**; this requires a Device Tree modification to fix. See below.

The HDMI console with a USB kbd and mouse works well, install `gpm` to get a working mouse in it. Once i had bluetooth working I was able to attach and use a bluetooth kbd+mouse with no issues.

#### Note:
I experimentally installed XFCE, it took 1+ hrs to log in and get a totally unusable desktop, the GPU support is obviously not there yet. Fortunately I have no plans to use a desktop and so it got de-installed asap.

# My Motivation:
My MQ PRO is connected to a Waveshare LORA hat, I want to make it work but the default Nezha device tree conflicts with some of the pins my HAT uses. So I decided to 'fix' this be putting a better device tree on it.

![My Hardware](waveshare_SX1268_LoRa_HAT/overview.jpg)

# Device Trees
TODO: general explanation,

My pre-compiled device-trees are in the [here](./precompiled-trees). 
- I still need to firm up and document how to deploy them!
- I still need to work out how to make this all permanent and able to survive a kernel upgrade.

## Roll Your Own Device Tree
Hopefully you can find what you want in the precompiled trees, or use the vanilla tree and dynamically create your devices on it via PinCTL.

But if not; my somewhat limited notes on compiling the tree, plus a script that handles running the C preprocessor on them (needed to get a working binary) are in the [device-tree](./device-tree) folder.

# Enabling Bluetooth
You need one of the new device trees provided (*except the original Nezha one*) since these correctly map UART1 onto the BT controller (with RTS/CTS).

Once that is in place you still need the correct firmware for this particular device, a copy of this is in the [bluetooth firmware](./bt-fw) folder.
* Copy the two firmware (`.bin`) files to `/usr/lib/firmware/` on the MQ PRO and reboot.

# Allwinner D1 GPIO pins
The **D1** SOC runs at 3v3, and you must not exceed this on any of the GPIO pins. The drive current is also very limited, a maximum of 4mA on any individual pin, and 6mA total across a bank of pins (eg the 12 pins in the `*PB*` bank combined cannot draw more than 6mA!).

Pins are organised into 7 'banks' (*PA*, *PB*, etc to *PG*) of up to 32 pins, but most banks have fewer pins.

There is a big table in the D1 datasheet that shows all possible functions each pin ccan assume.

## Default MQ-Pro mappings?
The mapping as described in the schematics; showing the specific GPIO pin assignments envisioned by MangoPI on the MQ Pro GPIO connector.

**Not what you get by default with Ubuntu**
```text
                 3v3  -  1  o o   2 -  5v
     i2c0 SDA   PG13 --  3  o o   4 -  5v
     i2c0 SDL   PG12 --  5  o o   6 -  GND
                PB7  --  7  o o   8 -- PB8    uart0 TX
                 GND  -  9  o o  10 -- PB9    uart0 RX
                PD21 -- 11  o o  12 -- PB5    i2s CLK [pwm0]
                PD22 -- 13  o o  14 -  GND
       [pwm3]   PB0  -- 15  o o  16 -- PB1    [pwm4]
                 3v3  - 17  o o  18 -- PD14   spi1 HOLD
    spi1 MOSI   PD12 -- 19  o o  20 -  GND
    spi1 MISO   PD13 -- 21  o o  22 -- PC1    uart2 RX
    spi1 SCLK   PD11 -- 23  o o  24 -- PD10   spi1 CS
                 GND  - 25  o o  26 -- PD15   spi1 WS
     i2c3 SDA   PE17 -- 27  o o  28 -- PE16   i2c3 SCL 
                PB10 -- 29  o o  30 -  GND
                PB11 -- 31  o o  32 -- PC0    uart2 TX
                PB12 -- 33  o o  34 -  GND
[pwm1] i2s FS   PB6  -- 35  o o  36 -- PB2
                PD17 -- 37  o o  38 -- PB3    i2s DI0
                 GND  - 39  o o  40 -- PB4    i2s DO

Notes:
- I2C pins 2,5,27 and 28 (PG13, PG12, PE17 and PE16) have 10K pullup resistors to 3v3
- The onboard blue status LED is on `PD18` [pwm2]
```

## GPIO Pin Muxing
The **D1** SOC itself has 88 GPIO pins. 

In the MQ PRO some of these GPIO pins are wired directly to peripherals on the board (eg SD card, Wifi chip, etc.) but that still leaves many free lines.

The board has a 'standard' Raspberry Pi compatible 40 pin GPIO connector; 12 are reserved for Power lines, leaving 28 GPIO pins available for the user.

Internally, the **D1** has a number of internal hardware interfaces for different signal types; 6xUART for serial, 2xSPI, 4xI2C(TWI), 3xI2Si/PCM (audio), 8xPWM, and some additional units for USB, HDMI, Audio, and more (see the Data sheet)

The chip has an internal 'pin muxer' to connect pins to signals. Each pin can connect to a (predefined) set of signals, which allows you to map each pin on the GPIO header to multiple possible functions. You can browse the full range of mappings in the Allwinner D1 datasheet, Table 4-3 (see the [references](./reference)' folder in this repo for a copy).

Additionally all pins are high-impedance by default and can be set to a HIGH or LOW digital output. They can all work as digital inputs, and all have configurable pull-up and pull down resistors, and can generate interrupts. ADC input capable pins are limited, see the datasheet for more.

### Internal interfaces
The MQ Pro uses several of the **D1**s interfaces on-board, specifically:

`UART1` is used to connect to the the bluetooth device by default (with flow control) using `PG6`, `PG7`, `PG8` and `PG9`. It can be reconfigured onto GPIO pins if bluetooth is not required.

`TWI2` (`I2C2`) can be  mapped to the DVP connector (for touchscreen interfaces) via pins `PE12` and `PE13`.

`TWI3` (`I2C3`) can be mapped to the DSI/LVDS connector via pins `PE16` and `PE17`; which also appear on the GPIO connector.

`SPI0` is mapped to the optional SPI flash chip (not fitted on consumer units)


### Pin Mapping Example; UART pins:
The D1 has 6 internal UARTs, and many pin mappings are possible on the GPIO connector:
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
- `UART1` and `UART3` have flow control lines (rts and cts) available
- some pins do not map to any UART devices

## References
I have a copy of the MQ PRO schematic and the AllWinner D1 datasheet in the [references](./reference) folder.

Online:
* https://mangopi.org/mangopi_mqpro
* https://linux-sunxi.org/MangoPi_MQ-Pro
* https://github.com/boosterl/awesome-mango-pi-mq-pro

