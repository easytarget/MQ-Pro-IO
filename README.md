# MangoPI MQ Pro (single core allwinner D1 risc-v based Pi Zero clone)
Investigating the MangoPi MQ pro's IO capabilities when running Ubuntu 23.10, instead of the Armbian image it 'shipped' with. This is using the 'AllWinner Nezha' image (compatible with the MQ pro) from here: https://ubuntu.com/download/risc-v

My unit is connected to a Waveshare LORA hat, I want to make it work.

### MQ Pro Pins:
This is derived from the schematics; showing the specific GPIO pin assignments on the MQ Pro GPIO connector

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

Note that the spare onboard LED (activity?) is on `PD18` [pwm2]

## Default MQ-Pro mappings (as described in the schematic and other docs) looks like this:

```text
                    3v3  -- o o -- 5v
     i2c0 SDA   PG13 ------ o o -- 5v
     i2c0 SDL   PG12 ------ o o -- GND
                PB7  ------ o o ------ PB8    uart0 TX
                     GND -- o o ------ PB9    uart0 RX
                PD21 ------ o o ------ PB5    i2s CLK [pwm0]
                PD22 ------ o o -- GND
       [pwm3]   PB0  ------ o o ------ PB1    [pwm4]
                     3v3 -- o o ------ PD14   spi1 HOLD
    spi1 MOSI   PD12 ------ o o -- GND
    spi1 MISO   PD13 ------ o o ------ PC1    uart2 RX
    spi1 SCLK   PD11 ------ o o ------ PD10   spi1 CS
                     GND -- o o ------ PD15   spi1 WS
     i2c3 SDA   PE17 ------ o o ------ PE16   i2c3 SCL 
                PB10 ------ o o -- GND
                PB11 ------ o o ------ PC0    uart2 TX
                PB12 ------ o o -- GND
[pwm1] i2s FS   PB6  ------ o o ------ PB2
                PD17 ------ o o ------ PB3    i2s DI0
                     GND -- o o ------ PB4    i2s DO

Note: I2C pins 2,5,27 and 28 (PG13, PG12, PE17 and PE16) have 10K pullup resistors to 3v3
```

## Uart pins:
The D1 has 6 internal UARTs and many pin mappings are possible on the GPIO connector:
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
- UART0 on gpio pins 8 and 10 (PB8 and PB9) is the used for the system console by default
- UART1 is connected to the bluetooth device by default, this can be reconfigured onto the GPIO pins if bluetooth is not required.
- UART1 and UART3 have flow control lines available

## References
Pin mappings come from the Allwinner D1 datasheet, Table 4-3 (see the 'references' folder in this repo for a copy)

#### MQ Pro
https://mangopi.org/mangopi_mqpro
