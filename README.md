# MangoPI MQ Pro (single core allwinner D1 risc-v based Pi Zero clone)
Investigating the MangoPi MQ pro's IO capabilities when running Ubuntu 24.4.
- This is using the 'AllWinner Nezha' image (compatible with the MQ pro) from here: https://ubuntu.com/download/risc-v

My MQ PRO is connected to a Waveshare LORA hat, I want to make it work but the default Nezha device tree conflicts with some of the pins my HAT uses. So I decided to 'fix' this be putting a better device tree on my MQ PRO

## Allwinner D1 GPIO pins
The **D1** SOC runs at 3v3, and you must not exceed this on any of the GPIO pins. The drive current is also very limited, a maximum of 4mA on any individual pin, and 6mA total across a bank of pins (eg the 12 pins in the `*PB*` bank combined cannot draw more than 6mA!).

Pins are organised into 7 'banks' (*PA*, *PB*, etc to *PG*) of up to 32 pins, but most banks have fewer pins.

## Default MQ-Pro mappings (as described in the schematic and other docs) looks like this:
This is derived from the schematics; showing the specific GPIO pin assignments on the MQ Pro GPIO connector

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
- Device names can be aliased to logical names in the tree, eg 'uart2' can be mapped as 'serial1', and will use '/dev/ttyS1' as it's device
- I2C pins 2,5,27 and 28 (PG13, PG12, PE17 and PE16) have 10K pullup resistors to 3v3
- The onboard blue status LED is on `PD18` [pwm2]
```

## GPIO Pin Muxing
The **D1** SOC itself has 88 GPIO pins. 

In the MQ PRO some of these GPIO pins are wired directly to peripherals on the board (eg SD card, Wifi chip, etc.) but that still leaves many free lines. The 'standard' PI GPIO connector on it has 40 pins, but 12 are reserved for Power lines, leaving 28 GPIO pins for the user.

Internally, the **D1** has a number of internal hardware interfaces for different signal types; 6xUART for serial, 2xSPI, 4xI2C(TWI), 3xI2Si/PCM (audio), 8xPWM, and some additional units for USB, HDMI, Audio, and more (see the Data sheet)

The chip has an internal 'pin muxer' to connect pins to signals. Each pin can connect to a (predefined) set of signals, which allows you to map each pin on the GPIO header to multiple possible functions. You can browse the full range of mappings in the Allwinner D1 datasheet, Table 4-3 (see the 'references' folder in this repo for a copy)

Additionally all pins are high-impedance by default and can be set to a HIGH or LOW digital output. They can all work as digital inputs, and all have configurable pull-up and pull down resistors, and can generate interrupts. ADC input capable pins are limited, see the datasheet for more.

### Example; mapping uart pins:
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
         UART5-TX   PB6  ------ o o ------ PB2   UART4-TX
                    PD17 ------ o o ------ PB3   UART4-RX
                         GND -- o o ------ PB4   UART5-TX
```
Notes:
- UART0 maps by default to gpio pins 8 and 10 (*PB8* and *PB9*) is the used for the system console by default at boot and you should expect data on it during boot even if you disable it in the device tree as the kernel starts.
- UART1 is connected to the bluetooth device by default, it can be reconfigured onto GPIO pins if bluetooth is not required.
- UART1 and UART3 have flow control lines (rts and cts) available
- some pins do not map to any UART devices

## References

#### MQ Pro
https://mangopi.org/mangopi_mqpro

#### General Template for pins:
```text
looking down, Pin1 is top left, Pin40 bottom right

        3v3  -- o o -- 5v
    PG13 ------ o o -- 5v
    PG12 ------ o o -- GND
    PB7  ------ o o ------ PB8
         GND -- o o ------ PB9
    PD21 ------ o o ------ PB5
    PD22 ------ o o -- GND
    PB0  ------ o o ------ PB1
         3v3 -- o o ------ PD14
    PD12 ------ o o -- GND
    PD13 ------ o o ------ PC1
    PD11 ------ o o ------ PD10
         GND -- o o ------ PD15
    PE17 ------ o o ------ PE16
    PB10 ------ o o -- GND
    PB11 ------ o o ------ PC0
    PB12 ------ o o -- GND
    PB6  ------ o o ------ PB2
    PD17 ------ o o ------ PB3
         GND -- o o ------ PB4
```
