#!/bin/bash

# Based off the lutris install script https://lutris.net/games/install/29680/view
# Some snippets taken from https://github.com/z0z0z/mf-install

# Requirements:
# installed and patched game
# wget, protontricks, proton

# Tested with: GE-Proton7-15

check_env() {
    [ -z "$1" ] && echo "$2 is not set" && exit 1
}

check_dir() {
    [ ! -d "$1/$2" ] && echo "$1 isn't a valid path" && exit 1
}

if [ $# -eq 0 ]
  then
    echo init.sh: missing params
    echo "usage: fix-gears.sh <appid> [-flatpak]"
    exit 1
fi
appid=$1
NUMSTEPS="5"

# checking dl directory
if [ ! -d "./dl" ]; then
    echo setting up downloads directory
    mkdir dl
fi

# overriding protontricks if using flatpak version - otherwise look for protontricks on PATH
if [ "$2" = "-flatpak" ]; then
    overrides=$(dirname "$(realpath bin/protontricks)")
    export PATH="$overrides:$PATH"
fi

echo checking env...
check_env "$PROTON" PROTON
check_env "$WINEPREFIX" WINEPREFIX
check_dir "$WINEPREFIX" drive_c

set -e

# put proton to PATH
if [ -d "$PROTON/files" ]; then
    prefix="files"
elif [ -d "$PROTON/dist" ]; then
    prefix="dist"
fi

export PATH="$PROTON/$prefix/bin:$PROTON:$PATH"

# these might not be needed
export WINESERVER="$PROTON/$prefix/bin/wineserver"
export WINELOADER="$PROTON/$prefix/bin/wine"
export WINEDLLPATH="$PROTON/$prefix/lib/wine:$PROTON/$prefix/lib64/wine"

# setting up steam path - override STEAM_COMPAT_CLIENT_INSTALL_PATH if not on SteamDeck/default install
steampath=${STEAM_COMPAT_CLIENT_INSTALL_PATH:-"/home/$USER/.local/share/Steam"}

# confirm settings
echo using protontricks -\> $(which protontricks)
echo using proton -\> $(which proton)
echo using appid -\> $appid
echo using prefix -\> $WINEPREFIX
echo using steampath -\> $steampath
echo

read -p "STEP 0/$NUMSTEPS Done. Press any key to procede... Next: downloading gfwl and launcher patch"

echo checking downloads:
if  [ -f "./dl/gfwl.exe" ]; then
    echo file [gfwl.exe] exists
else
    wget http://fs2.download82.com/software/bbd8ff9dba17080c0c121804efbd61d5/games-for-windows-live/gfwlivesetup.exe \
    -O dl/gfwl.exe
fi

if  [ -f "./dl/default.htm" ]; then
    echo file [default.htm] exists
else
    wget https://pastebin.com/raw/CyU6gZYg -O dl/default.htm
fi
echo
read -p "STEP 1/$NUMSTEPS Done. Press any key to procede... Next: installing dependencies with protontricks"


# installing os dependencies
echo setting up install environment

protontricks -v $appid \
    arial physx xact_x64 d3dx9 d3dx10 d3dx10_43 d3dcompiler_42 d3dcompiler_43 d3dcompiler_46 d3dcompiler_47

echo
read -p "STEP 2/$NUMSTEPS Done. Press any key to procede... Next: installing GFWL"


# installing gfwl
echo installing GFWL..
STEAM_COMPAT_CLIENT_INSTALL_PATH="$steampath" \
STEAM_COMPAT_DATA_PATH=$(dirname "$(realpath $WINEPREFIX)") \
proton run ./dl/gfwl.exe
echo
read -p "STEP 3/$NUMSTEPS Done. Press any key to procede... Next: patching the game launcher"


# working around the game launcher
echo fixing the game launcher...
cp ./dl/default.htm $WINEPREFIX/drive_c/users/steamuser/AppData/Roaming/Microsoft\ Games/Gears\ of\ War/CurrentSite/default.htm
echo
read -p "STEP 4/$NUMSTEPS Done. Press any key to procede... Next: final prefix changes"

# 
echo setting prefix to windows 7 and enabling virtual desktop
protontricks -v $appid win7 vd=800x600

echo "STEP 5/$NUMSTEPS Done."
echo

echo "cleaning up. if it fails close the wine processes manually, or restart your steamdeck before trying to run the game"

wineserver -k

echo "set your game launch parameters in steam to the following:"
echo "DXVK_ASYNC=1 PROTON_NO_ESYNC=1 PROTON_NO_FSYNC=1 %command%"
echo Have Fun!