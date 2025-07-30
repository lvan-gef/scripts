#! /usr/bin/env python3

import subprocess
import sys

user_input = sys.argv[1]

start_line="Below is a list of the symbolic error names that are defined on Linux:"
end_line="NOTES"

result = subprocess.run(f'man 3 errno | cat | sed -n "/{start_line}/,/{end_line}/p" | sed "1d;$d" | sed "/^$/d"',
                        shell=True,
                        capture_output=True,
                        text=True)

lines = result.stdout.split('\n')[:-2]
new_lines = []
index = 0
for line in lines:
    l = line[7:]
    if l[0] == ' ':
        new_lines[index - 1].append(line)
    else:
        new_lines.append([line.strip()])
        index += 1

lines = [' '.join(x for x in tmp_line) for tmp_line in new_lines]

if user_input.isdigit():
    print(lines[int(user_input) - 1])
else:
    for index, line in enumerate(lines, start=1):
        if line.startswith(user_input):
            print(index)
            break
