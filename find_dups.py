#!/usr/bin/env python3

import argparse
import json
from hashlib import md5
from pathlib import Path

def main(path: Path) -> None:
    dub = {}

    for root, _, files in path.walk():
        for file in files:
            fullname = root.joinpath(file)
            hash_result = md5()
            with open(fullname, 'rb') as f:
                while True:
                    data = f.read(1024)
                    if not data:
                        break
                    hash_result.update(data)

            dub.setdefault(hash_result.hexdigest(), []).append(fullname)

    dubs = {k: v for k, v in dub.items() if len(v) > 1}
    if dubs:
        with open(f'{path.stem}_dups.json', 'w') as f:
            json.dump(dubs, f, indent=4)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
                    prog='fdf',
                    description='find dubs of fils')

    parser.add_argument('path', type=Path, help='path that you want to check')
    parser.add_argument('-s', type=int, default=1024, help='size of the chunk for reading')
    args = parser.parse_args()

    main(args.path.resolve())
