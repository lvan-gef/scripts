#! /usr/bin/env bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    STATE=$(hidutil property --get "UserKeyMapping" | grep "{")
    RESULT_CODE="$?"

    if [[ $RESULT_CODE -eq 0 ]]; then
        # esc is mapped to Caps_Lock
        hidutil property --set '{"UserKeyMapping":[]}' > /dev/null
    else
        # capslock is mapped to Caps_Lock
        hidutil property --set '{"UserKeyMapping":[ {"HIDKeyboardModifierMappingSrc":0x700000039, "HIDKeyboardModifierMappingDst":0x700000029} ]}' > /dev/null
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    STATE=$(xmodmap -pke | grep " 66 = " | grep "Caps_Lock")

    if [ -z "$STATE" ]; then
        # esc is mapped to Caps_Lock
        xmodmap -e "add Lock = Caps_Lock"
        xmodmap -e "keycode 66 = Caps_Lock"
    else
        # capslock is mapped to Caps_Lock
        xmodmap -e "clear Lock"
        xmodmap -e "keysym Caps_Lock = Escape"
    fi
fi;

# too update companion state
if [[ $# -eq 1 ]]; then
    case $1 in
        'u')
            NEW_STATE=$(xmodmap -pke | grep " 66 = " | awk '{ print $4 } ' | tr '[:upper:]' '[:lower:]' | tr -s '_' ' ')
            curl -H 'Content-Type: application/json' -d "{\"text\": \"$NEW_STATE\"}" -X POST 'http://localhost:8888/api/location/1/0/3/style'
            ;;
        *)
            echo 'Expected "u" for update state'
            ;;
    esac
fi
