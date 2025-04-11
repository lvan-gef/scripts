#! /usr/bin/env bash

URL='https://www.soundboard.ianlangeberg.nl'
AUDIO_TAG='<audio'
DOWNLOADED='gedownload.txt'
DPATH=$(pwd)

# if we have downloaded something load so we dont have to redownload it again
arr=()
if [ -e $DOWNLOADED ]; then
    while IFS= read -r line; do
        arr+=("$line")
    done < $DOWNLOADED
fi

# get website
echo "Connecting to: $URL"
PAGE=$(curl -s "$URL")
RETURN_CODE=$?
if [ $RETURN_CODE -ne 0 ]; then
    echo "curl failed with return code: $RETURN_CODE"
    exit 1
fi

# get all audio tags
AUDIO_TAGS_ARRAY=()
while IFS= read -r tag; do
    AUDIO_TAGS_ARRAY+=("$tag")
done < <(echo "$PAGE" | grep "$AUDIO_TAG")

if [ ${#AUDIO_TAGS_ARRAY[@]} -eq 0 ]; then
    echo "No matches found for pattern: $AUDIO_TAG"
    exit 1
fi

# download all file
DOWNLOAD_LIST=""
for tag in "${AUDIO_TAGS_ARRAY[@]}"; do
    TITLE=$(echo "$tag" | sed -n 's/.*title="\([^"]*\)".*/\1/p' | tr ' ' '_' | tr -dc '[:alnum:]_' | tr '[:upper:]' '[:lower:]')

    if [[ -n "$TITLE" ]] && [[ ! "$TITLE" =~ ^[[:space:]]*$ ]]; then
        PSUBURL=$(echo "$tag" | sed -n 's/.*src="\([^"]*\)".*/\1/p')
        TYPE=$(echo "$PSUBURL" | awk 'BEGIN {FS="/"} {print $(NF-1)}' | tr ' ' '_' | tr -dc '[:alnum:]_-' | tr '[:upper:]' '[:lower:]')
        SUBDIR="$DPATH/$TYPE"
        SUBURL=$(echo "$PSUBURL" | tr ' ' '%20')
        FULLNAME="$SUBDIR/$TITLE.mp3"

        if [[ ! -d "$SUBDIR" ]]; then
            mkdir "$SUBDIR"
        fi

        echo "Download: $URL/$PSUBURL > $TITLE.mp3"

        curl -s "$URL/$SUBURL" -o "$FULLNAME"
        RETURN_CODE=$?
        if [ $RETURN_CODE -ne 0 ]; then
            echo "curl failed with return code: $RETURN_CODE"
        else
            # START really dont know how to add a newline to it so dont mess with the '"' should add beginning of line
            DOWNLOAD_LIST+="$TYPE/$TITLE.mp3
"
            # END really dont know how to add a newline to it so dont mess with the '"' should add beginning of line
        fi
    fi;
done

if [[ -n "$DOWNLOAD_LIST" ]]; then
    echo "not empty"
    echo "$DOWNLOAD_LIST" >> "$DOWNLOADED"
fi
