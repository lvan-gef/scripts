import subprocess

pip_lijst = subprocess.getoutput('pip3 list').split('\n')[2:]
subprocess.call('pip3 install --upgrade pip', shell=True)
for pip in pip_lijst:
    subprocess.call(f'pip3 install -q --upgrade {pip.split(" ")[0]}',
                    shell=True)
