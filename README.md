# compile-syncthing-macos

Build script to generate macOS app bundle for Syncthing.

See [here](https://github.com/syncthing/syncthing-macos/issues/200)

## Use

1. download `compile-syncthing-macos.sh` and save the script anywhere you like
2. edit the script (optional) to change versions and build dir variables:
```
ST_TAG='v1.23.7'
STM_TAG='v1.23.6-1'
BUILD_DIR="$HOME/Downloads" 
```
3. execute the script: `./compile-syncthing-macos.sh`
4. after a couple of minutes, you should end up with a shiny new app bundle.

## Notes

I have only used this on a couple of my own personal machines, so limited testing has been done. You should have Homebrew and Xcode installed on your machine for this to work.
