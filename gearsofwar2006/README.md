# Gears of War (2006) SteamDeck/Proton configurer

Based off the official lutris install script for the game:
https://lutris.net/games/install/29680/view

Tested with GE-Proton7-15

## Requirements:
installed game, wget, protontricks, proton

## Usage:
`fix-gears.sh <appid> [-flatpak]`

## Example:
```sh
PROTON=/home/deck/.local/share/Steam/compatibilitytools.d/GE-Proton7-15 \
WINEPREFIX=/home/deck/.local/share/Steam/steamapps/compatdata/13371337/pfx \
./fix-gears.sh 13371337 -flatpak
```