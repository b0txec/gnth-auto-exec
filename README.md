# gnth-auto-exec
![Young Frankenstein by Horsenburger](https://16colo.rs/pack/mist1024/HORSENBURGER-YOUNG_FRANKENSTEIN.PNG)


auto-execution tool for gobuster, nmap, thcdump and hydra

i just cant remember all the commands and how to compile them, got tired of searching and forgeting were i stored them, so i created simple scripts to automate the process

i use [these-wrodlists](https://github.com/danielmiessler/SecLists) for the wordlists most of the times

in general the tools runs and works as intended, i have not found any errors jet, but will keep working on them since i do use them myself


> [!NOTE]
> You need to have the given tools installed.

[gobuster](https://github.com/OJ/gobuster)
[nmap](https://github.com/nmap/nmap)
[tcp-dump](https://github.com/the-tcpdump-group/tcpdump)
[hydra](https://github.com/vanhauser-thc/thc-hydra)


```bash
sudo apt update
sudo apt install lolcat -y
```


- [ ] linked wordlists for faster use
- [ ] rotating fingerprints for gobuster and hydra
- [ ] add a config/install file.. ?


> [!IMPORTANT]
> I have not made the tools used by these scripts, these scripts are only auto-execution.


> [!CAUTION]
> This tool is ment for speeding pen-testing process, don't be a skid, don't attack things you don't own.
