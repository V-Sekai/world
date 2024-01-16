# Install

1. Install dependencies.

```
sudo apt install python3-pip
pip3 install -r requirements.txt 
```

2. For vsproj

```
wget https://github.com/mstorsjo/llvm-mingw/releases/download/20231128/llvm-mingw-20231128-ucrt-macos-universal.tar.xz
tar xvf https://github.com/mstorsjo/llvm-mingw/releases/download/20231128/llvm-mingw-20231128-ucrt-macos-universal.tar.xz
MINGW_PREFIX=~/Documents/2024-01/llvm-mingw-20231128-ucrt-macos-universal scons vsproj=yes use_vsproj2=yes vsproj_gen_only=yes p=windows
```