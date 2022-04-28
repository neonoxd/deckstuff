#!/bin/bash
# parts taken from https://github.com/z0z0z/mf-install

if [ -d "$PROTON/files" ]; then
        prefix="files"
elif [ -d "$PROTON/dist" ]; then
    prefix="dist"
fi

export PATH="$PROTON/$prefix/bin:$PATH"
export WINESERVER="$PROTON/$prefix/bin/wineserver"
export WINELOADER="$PROTON/$prefix/bin/wine"
export WINEDLLPATH="$PROTON/$prefix/lib/wine:$PROTON/$prefix/lib64/wine"

wineserver -k