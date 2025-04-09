#! /usr/bin/env bash

VENV="venv"

# check if there is a env
if [ ! -d "$VENV" ]; then
	python3 -m venv venv
fi;

# source venv
source venv/bin/activate

# update deps
pip install --upgrade -r requirements.txt

# run python script
$VENV/bin/python3 main.py
