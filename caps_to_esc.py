#!/usr/bin/env python3

import argparse
import subprocess
from pathlib import Path
import sys

# source https://wiki.archlinux.org/title/Xmodmap

def update_state():
    result = get_state()
    state = result.split("=")[1].split(" ")[1].replace("_", "")
    data = '{"text": "' + state + '"}'
    url =  f"curl -H 'Content-Type: application/json' -d '{data}' -X POST 'http://192.168.2.59:8888/api/location/1/0/3/style'"
    result = subprocess.run(url, shell=True, capture_output=True)
    if result.returncode != 0:
        print(f'Failed to get: {url}', file=sys.stderr)
        exit(1)

def get_state():
    state = subprocess.run('xmodmap -pke | grep " 66 = "', shell=True, capture_output=True, text=True)
    return state.stdout


def change_state():
    state = get_state()

    if 'Caps_Lock' in state:
        subprocess.run('xmodmap -e "clear Lock"', shell=True);
        subprocess.run('xmodmap -e "keysym Caps_Lock = Escape"', shell=True, capture_output=True)
    elif 'Escape' in state:
        subprocess.run('xmodmap -e "add Lock = Caps_Lock"', shell=True)
        subprocess.run('xmodmap -e "keycode 66 = Caps_Lock"', shell=True, capture_output=True)
    else:
        print('Unkown state do nothing!')
        exit(2)

    update_state()


if __name__ == '__main__':
    home = Path().home()

    parser = argparse.ArgumentParser(prog='Key mapper')
    parser.add_argument('action')

    args = parser.parse_args()
    if args.action == 's':
        get_state()
    elif args.action == 'c':
        change_state()
