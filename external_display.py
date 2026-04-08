#!/usr/bin/env python3

import sys
import argparse
import subprocess


def print_error(string: str) -> None:
    print(f'\033[31m{string}\033[0m', file=sys.stderr)


def show_info(print_it: bool) -> str:
    result = subprocess.run('xrandr', shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print_error(string=f'Failed to get result of xrandr: {result.stderr}, {result.returncode}')
        exit(1)

    hdmi = result.stdout.split('HDMI-2')
    assert len(hdmi) > 1

    if print_it:
        print('HDMI-2', end='')
        print(hdmi[1])

    return hdmi[1]


def show_current() -> None:
    info_lines = show_info(print_it=False).split('\n')

    for info in info_lines:
        if '*' in info:
            data = (x.strip() for x in info.split(' ') if x.strip())
            for index, setting in enumerate(data):
                 if index == 0:
                    print(f'current settings: {setting}', end=' ')
                 elif '*' in setting:
                    print(f'{setting.replace('*', '')}')
                    break
            break
    else:
        print_error(string='There is no current settings for the second screen')
        exit(2)


def set_monitor(resolution: str, refresh: str) -> None:
    info_lines = show_info(print_it=False).split('\n')

    if info_lines[0].startswith(' connected'):
        info_lines = (info for info in info_lines[1:])

    display_info = ''
    for info in info_lines:
        if resolution in info:
            display_info = info
            break
    else:
        print_error(string=f'resolution: {resolution} is not supported')
        show_info(print_it=True)
        exit(3)
    assert display_info

    for ref in display_info.split(' '):
        if not ref.strip():
            continue

        if ref != refresh:
            continue

        break
    else:
        print_error(string=f'refresh rate: {refresh} is not supported for resolution: {resolution}')
        show_info(print_it=True)
        exit(4)

    result = subprocess.run(f'xrandr --output HDMI-2 --mode {resolution} --rate {refresh} --right-of eDP-1',
                            shell=True,
                            capture_output=True,
                            text=True)
    if result.returncode != 0:
        print_error(string=f'Failed to set the display: {result.stderr}, code: {result.returncode}')
        exit(5)


def main():
    parser = argparse.ArgumentParser(
            prog='display_setter',
            description='set external display for my macbook (debian i3)')

    parser.add_argument('-i', '--info', action='store_true', help='Show display options')
    parser.add_argument('-s', '--show', action='store_true', help='Show display current display settings')
    parser.add_argument('-rs', '--resolution', default='1920x1080', help='Display resolution')
    parser.add_argument('-rr', '--refresh', default='60.00', help='Display refresh rate')

    args = parser.parse_args()

    if args.info:
        show_info(print_it=True)
    elif args.show:
        show_current()
    else:
        set_monitor(resolution=args.resolution, refresh=args.refresh)


if __name__ == '__main__':
    main()
