# Alternate device tree Examples:
Each folder contains a `.dts` file and a README showing the GPIO pin mappings.

Copy the desired `.dts` file to the [build-trees](../build-trees) folder and follow the readme there to build the device-tree binaries.

There are instructions at the end of that document on how you can use a custom `.dtb` and make it permanent across reboots and kernel upgrades.

The issue with using these trees is that **if** the upstream device tree or includes is modified you need to manually rebuild these trees. 

EG any changes to the upstream `sun20i-d1-mangopi-mq-pro.dts` source needs to be detected and applied too. You need to examine file histories to do this.
- Fortunately this should not be an issue in practice; the kernel *should* remain very stable going forward. Ubuntu 24.04.1 is a LTS release..

The authors personal advice is to use this only if needed; or as a learning excercise.

## Common
[A common (generic) device tree I, suitable for many occasions](./common)
* Has 2x UART (plus the console uart), 2x I2C. 1xSPI
* 12 unassigned GPIO pins

## Serial
[Four UART interfaces *and* Four I2C interfaces](./serial)
* Has 4x UART (plus the console uart), 4x I2C
* UART3 has RTC/CTS pins available too
* 10 unassigned GPIO pins

## SPI
[SPI plus Serial interfaces](./spi)
* Has 3x UART (plus the console uart), 3x I2C. 1xSPI
* 8 unassigned GPIO pins
