from subprocess import run,PIPE
from importlib import import_module
from sys import path,argv
path.append('maps')

'''
    Gathers the pinmux table and parses it's output to a more human form, with pin designator included
'''

# get the model for our board, generate an index and prep it
dtname = run(['cat','/proc/device-tree/model'],stdout=PIPE,universal_newlines=True).stdout[:-1]
if len(argv) == 2:
    model = argv[1]
else:
    model = dtname
board = import_module(model.replace(' ','-'))
muxindex = [pin[0] for pin in board.gpio]
for pin in board.gpio:
    pin.append('')

# start
print('\n{} (dtb name: {})\n'.format(board.name, dtname))

# Get the full pinmux list
rawlist = run(['sudo', 'cat','/sys/kernel/debug/pinctrl/2000000.pinctrl/pinmux-pins'],stdout=PIPE,universal_newlines=True).stdout
pinlist = rawlist.splitlines()[2:]

# interpret list
for line in pinlist:
    pmux = line.split()
    if int(pmux[1]) in muxindex:
        state = 'free' + ' (' + pmux[1] + ')'
        if pmux[3] == 'device':
            state = pmux[6] + ' (' + pmux[4] + ')'
        elif pmux[3] == 'GPIO':
            state = 'gpio (' + pmux[4] + ')'
        board.gpio[muxindex.index(int(pmux[1]))][3] = state

# work out column widths
width = []
for c in range(0, board.cols):
    wide = 0
    for p in range(c, len(board.gpio), board.cols):
        w = len(board.gpio[p][3])
        wide = w if w > wide else wide
    width.append(wide)

# Output result.
for p in range(0, board.cols):
    if p % 2 == 0:
        print('  {}func   des  pin   '.format(' ' * (width[p] -4)), end='')
    else:
        print('    pin  des   func{}  '.format(' ' * (width[p] - 4)), end='')
print()

for l in range(0, len(board.gpio), board.cols):
    for p in range(l, l + board.cols):
        if board.gpio[p][2] is None:
            board.gpio[p][3] = ''
            board.gpio[p][2] = ''
        pad = (width[p - l] - len(board.gpio[p][3])) * ' '
        if p % 2 == 0:
            print('  {}{} {:>5} {:>3} --o'.format(pad, board.gpio[p][3], board.gpio[p][2], str(board.gpio[p][1])), end='')
        else:
            print(' o-- {:3} {:5} {}{}  '.format(str(board.gpio[p][1]), board.gpio[p][2], board.gpio[p][3], pad), end='')
    print()

print()
print('Notes:')
for l in board.notes:
    print('- ' + l)
