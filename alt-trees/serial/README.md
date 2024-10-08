```
                   MangoPI MQ Pro GPIO header (dtb name: MangoPi MQ Pro)

Gpio Header:
                           func   des  pin       pin  des   func
                                  3v3   1 --o o-- 2   5v
     i2c0.sda (2502000.i2c:205)  PG13   3 --o o-- 4   5v
     i2c0.sck (2502000.i2c:204)  PG12   5 --o o-- 6   gnd
                      free (39)   PB7   7 --o o-- 8   PB8   uart0.tx (2500000.serial:40)
                                  gnd   9 --o o-- 10  PB9   uart0.rx (2500000.serial:41)
                     free (117)  PD21  11 --o o-- 12  PB5   uart5.rx (2501400.serial:37)
                     free (118)  PD22  13 --o o-- 14  gnd
                      free (32)   PB0  15 --o o-- 16  PB1   free (33)
                                  3v3  17 --o o-- 18  PD14  uart3.cts (2500c00.serial:110)
                     free (108)  PD12  19 --o o-- 20  gnd
 uart3.rts (2500c00.serial:109)  PD13  21 --o o-- 22  PC1   uart2.rx (2500800.serial:65)
  uart3.rx (2500c00.serial:107)  PD11  23 --o o-- 24  PD10  uart3.tx (2500c00.serial:106)
                                  gnd  25 --o o-- 26  PD15  free (111)
     i2c3.sda (2502c00.i2c:145)  PE17  27 --o o-- 28  PE16  i2c3.sck (2502c00.i2c:144)
                      free (42)  PB10  29 --o o-- 30  gnd
                      free (43)  PB11  31 --o o-- 32  PC0   uart2.tx (2500800.serial:64)
                      free (44)  PB12  33 --o o-- 34  gnd
                      free (38)   PB6  35 --o o-- 36  PB2   uart4.tx (2501000.serial:34)
                     free (113)  PD17  37 --o o-- 38  PB3   uart4.rx (2501000.serial:35)
                                  gnd  39 --o o-- 40  PB4   uart5.tx (2501400.serial:36)

Other gpio outputs of interest:
-- PD18: Blue Status Led - gpio (2000000.pinctrl:114)

Notes:
- I2C pins 3,5,27 and 28 (PG13, PG12, PE17 and PE16) have 10K pullup resistors to 3v3
- The Status LED (PD18) is common with the LED_PWM pin on the DSI/LVDS output
```
