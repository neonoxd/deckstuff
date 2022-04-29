# Gears of War (2006) SteamDeck/Proton configurer

Based on the official lutris install script for the game:
https://lutris.net/games/install/29680/view

Tested with GE-Proton7-15

## Requirements:
installed game, wget, protontricks, proton

## Usage:
`PROTON=path/to/proton WINEPREFIX=path/to/prefix fix-gears.sh <appid> [-flatpak] [y]`

## Example:
```sh
PROTON=/home/deck/.local/share/Steam/compatibilitytools.d/GE-Proton7-15 \
WINEPREFIX=/home/deck/.local/share/Steam/steamapps/compatdata/13371337/pfx \
./fix-gears.sh 13371337 -flatpak y
```

## Notes:
The script _should_ just work on your Steam Deck, given that you have the prerequesites available

After you somehow installed the game, add it to Steam as a non steam game, with proton enabled, and try to launch it once, it will create a prefix for you

You can optionally provide `STEAM_COMPAT_CLIENT_INSTALL_PATH` aswell, it will be passed to the proton command that install gfwl