# GPIO usage examples (for the MQ-Pro)
This guide assumes you have a correctly installed and set up board, with the correct device tree (plus overlays) to expose the pins you want to use

## General Purpose GPIO (digital read/write)
<todo>, python lgpio.

### Status LED notes:
The onboard (blue) status LED is attached to gpio `PD18`, and can be controlled via the sys tree:

`$ sudo sh -c "echo 1 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn on

`$ sudo sh -c "echo 0 > /sys/devices/platform/leds/leds/blue\:status/brightness"` to turn off

You can make it flash as network traffic is seen with:

`$ sudo sh -c "echo phy0rx > /sys/devices/platform/leds/leds/blue\:status/trigger"`

Other control options are available, `$ sudo cat /sys/devices/platform/leds/leds/blue\:status/brightness` shows a list and the current selection. Most do not work or are not very useful; ymmv.
- `PD18` can also be mapped to `pwm-2` in a modified device tree if you want to manually control the LED and vary it's brightness.

## PWM
<todo>, need to attach pins to pwm channels via DT and then control. Might need (legacy) `/sys/class` control, pwm control in userland seems like a WIP for linux at present.

## I2C
Working! I have read temperatures from a BME280 sensor via pins 3 and 5.

Install [pypi:bme280](https://pypi.org/project/bme280/) and it's requirement smbus-cffi.

I am using a [virtual environment](https://docs.python.org/3/tutorial/venv.html), rather than installing globally.
```
$ sudo apt install python3-venv python3-dev
$ python3 -m venv env
$ source env/bin/activate
(env) $ pip install --upgrade pip
(env) $ pip install --upgrade smbus-cffi bme280

# The bme280 library provides a python API, and a commandline tool
(env) $ which read_bme280
<cwd>/env/bin/read_bme280

# My bme280 defaults to address 0x76, and I'm using I2C0
(env) $ read_bme280 --i2c-bus 0 --i2c-address 0x76
1024.85 hPa
  56.84 %
  21.59 C
```

## SPI
Not (yet!) Working. No devices appear at `/dev/spi*`
<todo>, I think there is a change (patch) needed in one of the allwinner headers to get this working.? it's a little unclear at present.

## Other:
CPU temperature sensor: `apt install lm-sensors`, then try:
```console
$ sensors
cpu_thermal-virtual-0
Adapter: Virtual device
temp1:        +19.4°C  
```
**HOWEVER** : this is nonsense.. I'm testing and the attached BME280 sensor is showing room temp as 22C..
- check out the device tree, maybe a bad offset. Or some kind of calibration/reference voltage needed?
