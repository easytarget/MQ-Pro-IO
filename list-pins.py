from subprocess import run,PIPE
import shlex

'''
    Runs 'gpioinfo' and parses it's output to a more human form, with pin designator included
'''

rawlist = run(['sudo', 'gpioinfo'],stdout=PIPE,universal_newlines=True)
pinlist = rawlist.stdout.splitlines()[1:]

for line in pinlist:
    out = shlex.split(line)
    number = int(out[1][:-1])
    pin = 'P{}{}'.format('ABCDEFGH'[int(number / 32)], number % 32)
    print('pin: {:3d}, {:>4}'.format(number, pin), end='')
    print(', {:>6}'.format(out[4]), end='')
    if out[2] != 'unnamed':
        print(', name: ' + out[2], end='')
    if out[3] != 'unused':
        print(', used by: ' + out[3], end='')
    print()
