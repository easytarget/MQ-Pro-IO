# Precompiled device trees:
Each folder contains a `.dtb` file, which is the compiled device tree itself, plus a `.dts` with the original source and a `.gpio` file showing the GPIO pin mappings.

## Generic
[./generic](The generic device tree I will use in my project, suitable for many occasions)
* Has 2x UART (plus the console uart), 2x I2C. 1xSPI
* 12 unassigned GPIO pins

## Serial
[./serial](Four UART interfaces *and* Four I2C interfaces)
* Has 4x UART (plus the console uart), 4x I2C
* UART3 has RTC/CTS pins available too
* 10 unassigned GPIO pins

## SPI
[./spi](SPI plus Serial interfaces)
* Has 3x UART (plus the console uart), 3x I2C. 1xSPI
* 8 unassigned GPIO pins

## SunXI
[./sunxi](Vanilla, unpopulated, upstream)
* Has the console uart, nothing more
* *26 unassigned GPIO pins!*

## AllWinner Nezha
[./allwinner-nezha](DO NOT USE)
* Included for completeness, this is the default device tree you get with the Ubuntu image.
* Has the console uart, 1x I2C. 1xSPI
* 15 unassigned GPIO pins, 3 pre-assigned to pinctl
