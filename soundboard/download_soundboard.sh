#! /usr/bin/env bash

VENV="venv"

# check if there is a env
if [ ! -d "$VENV" ]; then
    echo "Create venv"
    python3 -m venv venv

    # source venv
    source venv/bin/activate

    # update deps
    "$VENV/bin/pip" install --upgrade -r requirements.txt
else
    # source venv
    source venv/bin/activate
fi;

# run python script
"$VENV/bin/python3" main.py
