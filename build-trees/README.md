## `list-pins.py`
This is a tool that displays a ascii-art 'map' of the current pinmux assignments on the GPIO header

To run the pin list tool you need to be in the tools directory, then run:
```console
$ python3 list-pins.py MangoPi-MQ-Pro
```
* The script requires root acces (via sudo) to read the pin maps.
* Running the script produces the same map I use in this documentation.
* The data used to assemble the `.gpio` map files identifies which interface a pin is attached to, but not it's specific function for the interface.
  * eg it can say 'pinX and pinY are mapped to UART2', but cannot identify which pin is the TX and which is the RX; a limitation of the data, my apologies..
  * You therefore need to reference the [D1 pin mapping table](../reference/d1-pins.pdf) to get the exact functions for pins when running this for yourself.
