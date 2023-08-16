#!/usr/bin/env bash

#set versions here, use actual tag names (including the "v") get from
#https://github.com/syncthing/syncthing/tags
#https://github.com/syncthing/syncthing-macos/tags
ST_TAG='v1.23.7'
STM_TAG='v1.23.6-1'

BUILD_DIR="$HOME/Downloads"
STM_REPO='syncthing/syncthing-macos'
ST_APP='Build/Products/Release/Syncthing.app'

#auto-install dependencies if needed (requires Homebrew)
for f in trash:macos-trash gsed:gnu-sed; do
  if ! hash "${f%%:*}" &>/dev/null; then brew install --quiet "${f##*:}"; fi
done

cd "$BUILD_DIR" || exit 1
[[ -d ${STM_REPO##*/} ]] && trash "${STM_REPO##*/}"
git clone --depth 1 --branch "${STM_TAG}" "https://github.com/$STM_REPO"
cd "${STM_REPO##*/}" || exit 1
git submodule update --init
gsed -i.bak "0,/^SYNCTHING_VERSION=\".*$/{s//SYNCTHING_VERSION=\"${ST_TAG/#v}\"/}" syncthing/Scripts/syncthing-resource.sh
plutil -replace CFBundleShortVersionString -string "${ST_TAG/#v}" syncthing/Info.plist
read -r _ ID _ < <(security find-identity -v -p codesigning | grep Develop | head -1)
[[ -n $ID ]] && export SYNCTHING_APP_CODE_SIGN_IDENTITY=$ID
make clean
gsed -i.bak 's/^\([[:space:]]*MACOSX_DEPLOYMENT_TARGET =\).*;$/\1 10.14.6;/' Pods/Pods.xcodeproj/project.pbxproj
gsed -i.bak 's/^\([[:space:]]*MACOSX_DEPLOYMENT_TARGET =\).*;$/\1 10.14.6;/' syncthing.xcodeproj/project.pbxproj
make release

if [[ -d "$ST_APP" ]]; then
  codesign --verbose --force --deep -o runtime --sign "${SYNCTHING_APP_CODE_SIGN_IDENTITY}" "${ST_APP}/Contents/Frameworks/Sparkle.framework/Versions/A/Resources/AutoUpdate.app"
  codesign --verbose --force -o runtime --sign "${SYNCTHING_APP_CODE_SIGN_IDENTITY}" "${ST_APP}/Contents/Frameworks/Sparkle.framework/Versions/A"
  codesign --force --deep --options=runtime --sign "${SYNCTHING_APP_CODE_SIGN_IDENTITY}" "${ST_APP}"
  open -R "${ST_APP}"
fi
