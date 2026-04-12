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
	-d libxi \
	-d alsa-lib \
	-d alsa-plugins \
	-d alsa-plugins-pulse \
	"$appdir"

chmod 755 "$appdir"

############################################

ln -s usr/share/icons/hicolor/512x512/net.sourceforge.quakespasm.Quakespasm.png "$appdir"/

############################################

export APPIMAGE_EXTRACT_AND_RUN=1
"$tools_dir"/appimagetool.AppImage --standalone --preserve_cwd deploy "$appdir"/usr/share/applications/net.sourceforge.quakespasm.Quakespasm.desktop

############################################

rdfind -makesymlinks true . # Replace duplicate files with symlinks

"$tools_dir"/appimagetool.AppImage "$appdir"
mv *.AppImage "$out_dir"/
