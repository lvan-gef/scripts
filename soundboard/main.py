import os
import json
import sys

import requests
from bs4 import BeautifulSoup

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
        print('Website return code is not 200', file=sys.stderr)
        exit(1)

    soup = BeautifulSoup(req.text)

    try:
        for _type in soup.find_all('div', class_='group'):
            dir_name = _type.get('id')
            try:
                os.mkdir(dir_name)
            except FileExistsError:
                pass
            except PermissionError as pe:
                print(f'Error could not create dir: {dir_name}, message: {pe}',
                      file=sys.stderr)
                exit(2)

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
                    print(f'failed to download url: {new_url}', file=sys.stderr)
                    continue
                with open(new_path, 'bw') as f:
                    f.write(download.content)
                data.append(new_path)
    except KeyboardInterrupt:
        print('User did stop the script')
    except Exception as e:
        print(e, file=sys.stderr)
    finally:
        with open(downloaded, 'w') as f:
            json.dump(data, f, indent=4)


if __name__ == '__main__':
    main()
