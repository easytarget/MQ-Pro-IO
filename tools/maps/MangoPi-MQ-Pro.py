'''
    Map file for a MangoPi MQ Pro

    The 'gpio' list has 40 entries corresponding
    to pins 1-40 on the 2-row GPIO header.

    Each gpio[] entry is a list with two items:
        [0] the pinmux pin number, or 'None' if a power pin
        [1] the pin number on the connector
        [2] a text description, or 'None' to omit the pin

'''

name = 'MangoPI MQ Pro GPIO header'
cols = 2   # standard 40
rows = 20  # pin connector
gpio = [
        # The first 40 entries are the 40pin GPIO connector
        [None,  '3v3'], [None,   '5v'],
        [ 205, 'PG13'], [None,   '5v'],
        [ 204, 'PG12'], [None,  'gnd'],
        [  39,  'PB7'], [  40,  'PB8'],
        [None,  'gnd'], [  41,  'PB9'],
        [ 117, 'PD21'], [  37,  'PB5'],
        [ 118, 'PD22'], [None,  'gnd'],
        [  32,  'PB0'], [  33,  'PB1'],
        [None,  '3v3'], [ 110, 'PD14'],
        [ 108, 'PD12'], [None,  'gnd'],
        [ 109, 'PD13'], [  65,  'PC1'],
        [ 107, 'PD11'], [ 106, 'PD10'],
        [None,  'gnd'], [ 111, 'PD15'],
        [ 145, 'PE17'], [ 144, 'PE16'],
        [  42, 'PB10'], [None,  'gnd'],
        [  43, 'PB11'], [  64,  'PC0'],
        [  44, 'PB12'], [None,  'gnd'],
        [  38,  'PB6'], [  34,  'PB2'],
        [ 113, 'PD17'], [  35,  'PB3'],
        [None,  'gnd'], [  36,  'PB4'],
        # Everything after this is listed in 'extras'
        [114, 'PD18: Blue Status Led'],
        ]
notes = ['I2C pins 3,5,27 and 28 (PG13, PG12, PE17 and PE16) have 10K pullup resistors to 3v3','The Status LED (PD18) is common with the LED_PWM pin on the DSI/LVDS output']

