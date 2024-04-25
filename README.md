# MangoPI MQ Pro (single core allwinner D1 risc-v based Pi Zero clone)
Investigating the MangoPi MQ pro's IO capabilities

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

Note that the spare onboard LED (activity?) is on `PD18`

## LoRA HAT pins
This is derived from the schematics; showing the 5 specific pins used (only)

```text
looking down, Pin1 is top left, Pin40 bottom right

        3v3  -- o o -- 5v
                o o -- 5v
                o o -- GND
    AUX  ------ o o ------ TX (set to USB serial via jumpers on HAT)
         GND -- o o ------ RX (set to USB serial via jumpers on HAT)
             -- o o --
    M1   ------ o o -- GND
    M0   ------ o o --
         3v3 -- o o --
             -- o o -- GND
             -- o o --
             -- o o --
         GND -- o o --
             -- o o --
             -- o o -- GND
             -- o o --
             -- o o -- GND
             -- o o --
             -- o o --
         GND -- o o --

```
The three fixed pins used by the HAT are 7,13 and 15.
These map as follows:
* `AUX` is on `PB7`
* `M1` is on `PD22`
* `M0` is on `PB0`

The Serial (TX,RX) is deselected via onboard jumpers, a secondary serial will be jumpered to the module TX/RX instead.

## References
#### MQ Pro
https://mangopi.org/mangopi_mqpro
#### Lora HAT
https://www.waveshare.com/wiki/SX1262_868M_LoRa_HAT
