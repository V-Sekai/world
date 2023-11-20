# README

Tested on msys2 Windows 11, Rocky Linux and Fedora 36.

## Standard operating procedure

1. Fetch this repository
1. Ensure git email and name are setup.
1. On Windows use msys2.
1. Login to ssh key
1. run `./update_godot_v_sekai.sh` to release the branch.
1. run `./release_godot_v_sekai.sh` to update the io branch.

## Readme for fire

```
scoop install msys2
msys2
pacman -S git python3 ssh-pageant
# copy
# eval $(/usr/bin/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME")
# export PATH=/mingw64/bin/:$PATH
# To the end of ~/.bashrc
git config --global user.name "K. S. Ernest (iFire) Lee"
git config --global user.email "ernest.lee@chibifire.com"
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts
```
