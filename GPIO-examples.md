# GPIO usage examples (for the MQ-Pro)
This guide assumes you have a correctly installed and set up board, with the correct device tree (plus overlays) to expose the pins you want to use.

*Caveat:* notes here are biased towards Python usage, since that is what I will be using in my projects.

## General Purpose GPIO (digital read/write)
**You do not need to use a custom Device Tree in order to use digital IO**
* The 'default' device tree for the MQ pro has 26 free pins to use! 

Look at the great guide here: https://worldbeyondlinux.be/posts/gpio-on-the-mango-pi/

It does a better job of explaining this than I can do in a short guide.

## PWM
**working**, There are eight PWM timers available and GPIO pins can be mapped to these in a custom device tree
- The available mappings are somewhat limited, see the diagram in the main README to determine which pins on the GPIO connector can be used.
- The example below uses (legacy) `/sys/class` control, which in turn needs root access. PWM control from userland seems like a WIP for linux at present.
- I have not (yet) investigated using this via `lgpio` in Python.

The following needs to be run as root. It uses `pwm2` (the `lora` example device tree attaches this to pin 31 on the GPIO connector).

First, export the PWM interface:
```
# echo 2 > /sys/class/pwm/pwmchip0/export
```
- The node for the interface wil appear at `/sys/class/pwm/pwmchip0/pwm2/`

Set a default period (10μs) and duty cycle (5μs, 50%):
```
# echo 10000 > /sys/class/pwm/pwmchip0/pwm2/period`
# echo 5000 > /sys/class/pwm/pwmchip0/pwm2/duty_cycle`
```
After setting the default you can enable it with:
```
# echo 1 > /sys/class/pwm/pwmchip0/pwm2/enable`
```
You can stop and detach the interface with: `# echo 2 > /sys/class/pwm/pwmchip0/unexport`

The following is a shell script that implements a crude LED fader:

```bash
#!/bin/bash
# PWM silly fader
#
pwm="/sys/class/pwm/pwmchip0/pwm2"

echo normal > $pwm/polarity
echo 10000 > $pwm/period
echo 1 > $pwm/enable
while true ; do
    for p in 40 100 400 1000 4000 10000 6000 1200 600 120 60 0 ; do
        echo -n "."
        echo $p > $pwm/duty_cycle
        sleep 0.25
    done
    echo
done
```
See the [kernel guide](https://www.kernel.org/doc/html/latest/driver-api/pwm.html#using-pwms-with-the-sysfs-interface) for the parameters we set to assign and control the pin.

## I2C
**Working**: I have read temperature, pressure and humidity from a BME280 sensor connected to pins `3` and `5`.

Install [`pypi:bme280`](https://pypi.org/project/bme280/) and it's requirement `smbus-cffi`.
* I am using a [virtual environment](https://docs.python.org/3/tutorial/venv.html), rather than installing globally.
* Add the user to the group 'i2c' and re-login.
```
$ sudo apt install python3-venv python3-dev i2c-tools

$ sudo usermod -a -G i2c <username>
# Log out then in again so that your user now has the `i2c` group membership

# Create virtualenv in a directory './bme-env' and activate it (exit with `deactivate`, removing the directory+contents deletes the venv)
$ python3 -m venv bme-env
$ source bme-env/bin/activate
(bme-env) $ pip install --upgrade pip
(bme-env) $ pip install --upgrade smbus-cffi bme280

# The bme280 library provides a python API, and a commandline tool
(bme-env) $ which read_bme280
<cwd>/env/bin/read_bme280

# My bme280 defaults to address 0x76, and I'm using I2C0
(bme-env) $ read_bme280 --i2c-bus 0 --i2c-address 0x76
1024.85 hPa
  56.84 %
  21.59 C
```

## SPI
**Working?**: When I enable SPI1 in the device tree nodes a device at is registered at /sys/devices/platform/soc/4026000.spi/, it lists it's driver (correctly) as sun6i-spi and is a bus master.
* Kernel drivers that use spi via pinctl should be able to use this.
* But no block device appears at /dev/spi*.
  * Normally spi-tools provides userland support via the /dev/spi* device.
* I do not plan to use SPI so I have not tested further.

---------------------------------------------------------

# Extra!
## Status LED:
The onboard (blue) status LED is attached to gpio `PD18`, and can be controlled via the sys tree:

`$ sudo sh -c "echo 1 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn on

`$ sudo sh -c "echo 0 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn off

You can make it flash as network traffic is seen with:

`$ sudo sh -c "echo phy0rx > /sys/devices/platform/leds/leds/blue\:status/trigger"`

Other control options are available, `$ sudo cat /sys/devices/platform/leds/leds/blue\:status/trigger` shows a list and the current selection. Most do not work or are not very useful; ymmv.
- `PD18` can also be re-mapped to `pwm-2` in a modified device tree if you want to manually control the LED and vary it's brightness.
- PD18 is also used as the LED_PWM pin on the DSI/LVDS output


## Onboard CPU temperature sensor:
```console
$ sudo apt install lm-sensors
$ sensors
cpu_thermal-virtual-0
Adapter: Virtual device
temp1:        +19.4°C
```
**HOWEVER**: This is nonsense.. I'm testing with the board in a enclosure, and the attached BME280 sensor is showing room temp outside the enclosure as 22C, the CPU is not that cold.
- check out the device tree, maybe a bad offset. Or some kind of calibration/reference voltage needed?
