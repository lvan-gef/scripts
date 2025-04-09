import os
import requests
from bs4 import BeautifulSoup
import json


def main():
    url = 'https://www.soundboard.ianlangeberg.nl'
    audio_tag = 'audio'
    downloaded = 'gedownload.json'

    if os.path.exists(downloaded):
        with open(downloaded, 'r') as f:
            data = json.load(f)
    else:
        data = []

    print('Connecting to:', url)
    req = requests.get(url)
    if req.status_code != 200:
        print("Website return code is not 200")
        exit(1)

    soup = BeautifulSoup(req.text)

    for _type in soup.find_all('div', class_='group'):
        # create dir per group
        dir_name = _type.get('id')
        try:
            os.mkdir(dir_name)
        except FileExistsError:
            pass

        # found all audio tags
        for audio in _type.find_all(audio_tag):
            title = audio.get('title').replace(' ', '_')
            sub_url = audio.get('src')

            new_url = f'{url}/{sub_url}'
            new_path = f'{dir_name}/{title}.mp3'
            if new_path in data:
                continue

            print(f'Download {title}: {new_url}')
            download = requests.get(f'{new_url}')
            if download.status_code != 200:
                print(f'failed to download url: {new_url}')
                continue
            with open(new_path, 'bw') as f:
                f.write(download.content)
            data.append(new_path)

    with open(downloaded, 'w') as f:
        json.dump(data, f, indent=4)


if __name__ == '__main__':
    main()
