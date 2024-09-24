'''
 Demo Python GPIO on the MQ-Pro (requires a modified device tree)
 See: https://github.com/easytarget/MQ-Pro-IO/

 For install requirements requirements look at:
 - https://github.com/easytarget/MQ-Pro-IO/blob/main/GPIO-examples.md#python-demo
 Tested using the LoRa HAT device tree:
 - https://github.com/easytarget/MQ-Pro-IO/tree/main/alt-trees/lora-hat
'''

from time import sleep, ctime

# oled libs
from luma.core.interface.serial import i2c
from luma.core.render import canvas
from luma.oled.device import ssd1306
# sensor libs
from smbus2 import SMBus
from bme280 import BME280

# Hardware
i2c_bus = 0
ssd1306_addr = 0x3c
bme280_addr = 0x76

# display init
serial = i2c(port=i2c_bus, address=ssd1306_addr)
device = ssd1306(serial)

# sensor init
bus = SMBus(i2c_bus)
bme280 = BME280(i2c_addr=bme280_addr, i2c_dev=bus)
bme280.setup()

def read_sensor():
    t = round(bme280.get_temperature(),1)
    h = round(bme280.get_humidity(),1)
    p = round(bme280.get_pressure())
    return t, h, p

# initial reading settles sensor
_, _, _ = read_sensor()

# loop
while True:
    sleep(1)
    temp, humi, pres = read_sensor()
    out = ' Temp: {}°C\n Humi: {}%\n Pres: {}mb'.format(temp, humi, pres)
    with canvas(device) as draw:
        draw.rectangle(device.bounding_box, outline="white", fill="black")
        draw.text((26, 12), out, fill="white")
    print('{} :: {}°C, {}%, {}mb'.format(ctime(),temp, humi, pres))
