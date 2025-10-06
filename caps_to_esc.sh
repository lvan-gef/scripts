#! /usr/bin/env bash

get_state() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local state=$(hidutil property --get "UserKeyMapping" | grep "{")
        local result_code="$?"

        if [[ $result_code -eq 0 ]]; then
            echo "Esc"
        else
            echo "Caps"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        local state=$(xmodmap -pke | grep " 66 = " | grep "Caps_Lock")

        if [ -z "$state" ]; then
            echo "Esc"
        else
            echo "Caps"
        fi
    fi
}

new_state() {
    local cur_state=$(get_state)

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [ "$cur_state" = "Caps" ]; then
            hidutil property --set '{"UserKeyMapping":[ {"HIDKeyboardModifierMappingSrc":0x700000039, "HIDKeyboardModifierMappingDst":0x700000029} ]}' > /dev/null
            echo "Esc"
        else
            hidutil property --set '{"UserKeyMapping":[]}' > /dev/null
            echo "Caps"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ "$cur_state" = "Caps" ]; then
            xmodmap -e "clear Lock"
            xmodmap -e "keysym Caps_Lock = Escape"
            echo "Esc"
        else
            xmodmap -e "add Lock = Caps_Lock"
            xmodmap -e "keycode 66 = Caps_Lock"
            echo "Caps"
        fi
    fi
}

if [[ $# -eq 1 ]]; then
    case $1 in
        'u')
            CUR_STATE=$(new_state)
            curl -H 'Content-Type: application/json' -d "{\"text\": \"$CUR_STATE\"}" -X POST 'http://localhost:8888/api/location/1/0/3/style'
            ;;
        's')
            CUR_STATE=$(get_state)
            curl -H 'Content-Type: application/json' -d "{\"text\": \"$CUR_STATE\"}" -X POST 'http://localhost:8888/api/location/1/0/3/style'
            ;;
        *)
            echo 'Expected "u" for update state or "s" for current state'
            ;;
    esac
fi
