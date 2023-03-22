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

do_step() {
    [ -z "$2" ] && echo -e "do you want to procede? ${GREEN}(y)es${NC} (s)kip step ${RED}(q)uit${NC}"
    [ -z "$2" ] && read -p "? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ $2 =~ ^[Yy]$ ]]
    then
        $1
    elif [[ $REPLY =~ ^[Ss]$ ]]  || [[ $2 =~ ^[Ss]$ ]]
    then
        echo -e ${YELLOW}skipped step${NC}
    else
        exit 1
    fi
}

setup_downloads() {
    # check or download gfwl and launcher hack
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
}

configure_prefix() {
    # installing os dependencies
    echo setting up install environment

    protontricks -v $appid \
        arial physx xact_x64 d3dx9 d3dx10 d3dx10_43 d3dcompiler_42 d3dcompiler_43 d3dcompiler_46 d3dcompiler_47

    echo
}

install_gfwl() {
    # installing gfwl
    echo installing GFWL..
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$steampath" \
    STEAM_COMPAT_DATA_PATH=$(dirname "$(realpath $WINEPREFIX)") \
    proton run ./dl/gfwl.exe
    echo
}

fix_launcher() {
    # working around the game launcher
    echo fixing the game launcher...
    cp -v ./dl/default.htm $WINEPREFIX/drive_c/users/steamuser/AppData/Roaming/Microsoft\ Games/Gears\ of\ War/CurrentSite/default.htm
    echo
}

finalize_prefix() {
    # might also work if its done along with the first prefix configuration
    echo setting prefix to windows 7 and enabling virtual desktop
    protontricks -v $appid win7 vd=800x600
}

cleanup_wineprocesses() {
    # these might not be needed
    export WINESERVER="$PROTON/$prefix/bin/wineserver"
    export WINELOADER="$PROTON/$prefix/bin/wine"
    export WINEDLLPATH="$PROTON/$prefix/lib/wine:$PROTON/$prefix/lib64/wine"
    wineserver -k
}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m'

if [ $# -eq 0 ]
  then
    echo -e ${RED}init.sh: missing params${NC}
    echo "usage: fix-gears.sh [-flatpak] [y]"
    exit 1
fi
appid=$APPID
NUMSTEPS="5"


# checking dl directory
if [ ! -d "./dl" ]; then
    echo setting up downloads directory
    mkdir dl
fi

echo -e ${YELLOW}checking environment...${NC}
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

# setting up steam path - override STEAM_COMPAT_CLIENT_INSTALL_PATH if not on SteamDeck/default install
steampath=${STEAM_COMPAT_CLIENT_INSTALL_PATH:-"/home/$USER/.local/share/Steam"}

# overriding protontricks if using flatpak version - otherwise look for protontricks on PATH
if [ "$1" = "-flatpak" ]; then
    overrides=$(dirname "$(realpath bin/protontricks)")
    export PATH="$overrides:$PATH"
fi

# confirm settings
echo using protontricks -\> $(which protontricks)
echo using proton -\> $(which proton)
echo using appid -\> $appid
echo using prefix -\> $WINEPREFIX
echo using steampath -\> $steampath
echo -e "${YELLOW}only procede if these look okay${NC}"
echo

echo -e "${WHITE}---------------------------------------------------------------------------${NC}"
echo -e "${WHITE}STEP 0/$NUMSTEPS Done.${NC} Next: downloading gfwl and launcher patch"


do_step setup_downloads $2
echo -e "${WHITE}---------------------------------------------------------------------------${NC}"
echo -e "${WHITE}STEP 1/$NUMSTEPS Done.${NC} Next: installing dependencies with protontricks"


do_step configure_prefix $2
echo -e "${WHITE}---------------------------------------------------------------------------${NC}"
echo -e "${WHITE}STEP 2/$NUMSTEPS Done.${NC} Next: patching the game launcher"


do_step fix_launcher $2
echo -e "${WHITE}---------------------------------------------------------------------------${NC}"
echo -e "${WHITE}STEP 3/$NUMSTEPS Done.${NC} Next: final prefix changes"


do_step finalize_prefix $2
echo -e "${WHITE}---------------------------------------------------------------------------${NC}"
echo -e "${WHITE}STEP 4/$NUMSTEPS Done.${NC} Next: installing GFWL"

do_step install_gfwl $2
echo -e "${WHITE}---------------------------------------------------------------------------${NC}"
echo -e "${WHITE}STEP 5/$NUMSTEPS Done.${NC}"
echo

echo -e "${WHITE}set your game launch parameters in Steam to the following:${NC}"
echo -e "${YELLOW}PROTON_NO_ESYNC=1 PROTON_NO_FSYNC=1 %command%${NC}"
echo


echo "attempting cleanup... if it fails, close the wine processes manually, or restart your steamdeck before trying to run the game"
do_step cleanup_wineprocesses

echo Have Fun!