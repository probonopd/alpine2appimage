#!/bin/sh
set -eux

[ -z "${PACKAGE}" ] && exit 1

export VERSION=$(apk --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/testing list "$PACKAGE" | grep -v fetch | cut -d- -f2)
export ARCH=$(uname -m)

src_dir=${SRC_DIR:-/src}
out_dir=${OUT_DIR:-/out}
tools_dir=${TOOLS_DIR:-/tools}
appdir="$out_dir"/"$PACKAGE".AppDir

apk update && apk add file rdfind

"$tools_dir"/witchery-compose \
	-k /etc/apk/keys \
	-X https://dl-cdn.alpinelinux.org/alpine/edge/main \
	-X https://dl-cdn.alpinelinux.org/alpine/edge/community \
	-X https://dl-cdn.alpinelinux.org/alpine/edge/testing \
	-d "$PACKAGE" \
	-d mesa-gl \
	-d mesa-egl \
	-d libx11 \
	-d libxext \
	-d alsa-lib \
	-d alsa-plugins \
	-d alsa-plugins-pulse \
	"$appdir"

chmod 755 "$appdir"

############################################

sed -i 's/Icon=.*/Icon=srb2/' "$appdir"/usr/share/applications/srb2.desktop
sed -i 's/Exec=.*/Exec=srb2/' "$appdir"/usr/share/applications/srb2.desktop
ln -s usr/share/pixmaps/srb2.png "$appdir"/srb2.png

############################################

export APPIMAGE_EXTRACT_AND_RUN=1
"$tools_dir"/appimagetool.AppImage -s deploy "$appdir"/usr/share/applications/"$PACKAGE".desktop

############################################

# We need to cd to the data directory before starting the game so it can find its files.
# Would be better to set SRB2WADDIR, but that doesn't work with relative paths due to a bug.
sed -i 's|exec|cd share/games/SRB2; exec|' "$appdir"/AppRun

############################################

rdfind -makesymlinks true . # Replace duplicate files with symlinks

"$tools_dir"/appimagetool.AppImage "$appdir"
mv *.AppImage "$out_dir"/