# A device tree for my LORA HAT..

Designed to mimic the standard PI gpio assignments for use with PI HAT's
* i2c0 and spi1 ports are located on the same Pins as the PI I2C-1 and SPI-0 on the PI gpio header
  * i2c3 is on the same pins as I2C-0 on the Pi (normally reserved as the Pi EEPROM Data pins)

In addition it:
* Brings uart4 out on pins 36 and 38 (so I can leave the console free)
* Has 4 PWM channels for a RGB status led, and I2C screen brightness


Nb: screen is https://www.waveshare.com/wiki/3.5inch_RPi_LCD_(A)
```
               MangoPI MQ Pro GPIO header (dtb name: MangoPi MQ Pro)

Gpio Header:
                        func   des  pin       pin  des   func
                               3v3   1 --o o-- 2   5v
  i2c0.sda (2502000.i2c:205)  PG13   3 --o o-- 4   5v
  i2c0.scl (2502000.i2c:204)  PG12   5 --o o-- 6   gnd
                   free (39)   PB7   7 --o o-- 8   PB8   uart0.tx (2500000.serial:40)
                               gnd   9 --o o-- 10  PB9   uart0.rx (2500000.serial:41)
                  free (117)  PD21  11 --o o-- 12  PB5   free (37)
                  free (118)  PD22  13 --o o-- 14  gnd
                   free (32)   PB0  15 --o o-- 16  PB1   pwm4 (2000c00.pwm:33)
                               3v3  17 --o o-- 18  PD14  spi1.hold (4026000.spi:110)
 spi1.mosi (4026000.spi:108)  PD12  19 --o o-- 20  gnd
 spi1.miso (4026000.spi:109)  PD13  21 --o o-- 22  PC1   free (65)
  spi1.clk (4026000.spi:107)  PD11  23 --o o-- 24  PD10  spi1.cs (4026000.spi:106)
                               gnd  25 --o o-- 26  PD15  spi1.wp (4026000.spi:111)
  i2c3.sda (2502c00.i2c:145)  PE17  27 --o o-- 28  PE16  i2c3.sck (2502c00.i2c:144)
                   free (42)  PB10  29 --o o-- 30  gnd
       pwm2 (2000c00.pwm:43)  PB11  31 --o o-- 32  PC0   free (64)
       pwm0 (2000c00.pwm:44)  PB12  33 --o o-- 34  gnd
       pwm1 (2000c00.pwm:38)   PB6  35 --o o-- 36  PB2   uart4.tx (2501000.serial:34)
                  free (113)  PD17  37 --o o-- 38  PB3   uart4.rx (2501000.serial:35)
                               gnd  39 --o o-- 40  PB4   free (36)

Other gpio outputs of interest:
-- PD18: Blue Status Led - gpio (2000000.pinctrl:114)

Notes:
- I2C pins 3,5,27 and 28 (PG13, PG12, PE17 and PE16) have 10K pullup resistors to 3v3
- The Status LED (PD18) is common with the LED_PWM pin on the DSI/LVDS output
```
