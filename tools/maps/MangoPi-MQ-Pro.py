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
cols = 2
gpio = [
        [None,  1,  '3v3'], [None,  2,   '5v'],
        [ 205,  3, 'PG13'], [None,  4,   '5v'],
        [ 204,  5, 'PG12'], [None,  6,  'gnd'],
        [  39,  7,  'PB7'], [  40,  8,  'PB8'],
        [None,  9,  'gnd'], [  41, 10,  'PB9'],
        [ 117, 11, 'PD21'], [  37, 12,  'PB5'],
        [ 118, 13, 'PD22'], [None, 14,  'gnd'],
        [  32, 15,  'PB0'], [  33, 16,  'PB1'],
        [None, 17,  '3v3'], [ 110, 18, 'PD14'],
        [ 108, 19, 'PD12'], [None, 20,  'gnd'],
        [ 109, 21, 'PD13'], [  65, 22,  'PC1'],
        [ 107, 23, 'PD11'], [ 106, 24, 'PD10'],
        [None, 25,  'gnd'], [ 111, 26, 'PD15'],
        [ 145, 27, 'PE17'], [ 144, 28, 'PE16'],
        [  42, 29, 'PB10'], [None, 30,  'gnd'],
        [  43, 31, 'PB11'], [  64, 32,  'PC0'],
        [  44, 33, 'PB12'], [None, 34,  'gnd'],
        [  38, 35,  'PB6'], [  34, 36,  'PB2'],
        [ 113, 37, 'PD17'], [  35, 38,  'PB3'],
        [None, 39,  'gnd'], [  36, 40,  'PB4'],
        ]
notes = ['I2C pins 2,5,27 and 28 (PG13, PG12, PE17 and PE16) have 10K pullup resistors to 3v3',
         'The onboard blue status LED is on PD18 [pwm2](pinmux:114)']

