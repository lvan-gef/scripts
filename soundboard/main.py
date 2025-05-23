import json
import sys
from pathlib import Path

import requests
from bs4 import BeautifulSoup


def main():
    url = 'https://www.soundboard.ianlangeberg.nl'
    audio_tag = 'audio'
    download_path = Path('download')
    downloaded = download_path.joinpath('gedownload.json')

    if downloaded.exists():
        with open(downloaded, 'r') as f:
            data = json.load(f)
        data = [Path(path) for path in data]
    else:
        data = []

    print('Connecting to:', url)
    req = requests.get(url)
    if req.status_code != 200:
        print('Website return code is not 200', file=sys.stderr)
        exit(1)

    soup = BeautifulSoup(req.text, 'lxml')
    try:
        for _type in soup.find_all('div', class_='group'):
            for audio in _type.find_all(audio_tag):
                title = audio.get('title').replace(' ', '_')
                sub_url = audio.get('src')

                dir_name = download_path.joinpath(_type.get('id'))
                if not dir_name.exists():
                    try:
                        dir_name.mkdir(exist_ok=True, parents=True)
                    except PermissionError as pe:
                        print(f'Error could not create dir: {dir_name}, message: {pe}',
                              file=sys.stderr)
                        exit(2)

                new_url = f'{url}/{sub_url}'
                new_path = Path('.'.join([str(dir_name.joinpath(title)), 'mp3']))
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
        print('\nUser did stop the script')
    except Exception as e:
        print(e, file=sys.stderr)
    finally:
        with open(downloaded, 'w') as f:
            json.dump([str(path) for path in data], f, indent=4)


if __name__ == '__main__':
    main()
