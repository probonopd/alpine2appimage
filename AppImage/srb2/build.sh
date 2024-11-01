#!/bin/sh
set -eux

src_dir=${SRC_DIR:-/src}
out_dir=${OUT_DIR:-/out}
appdir="$out_dir"/srb2.AppDir

apk update && apk add file patchelf

"$src_dir"/witchery-compose \
	-k /etc/apk/keys \
	-X https://dl-cdn.alpinelinux.org/alpine/edge/main \
	-X https://dl-cdn.alpinelinux.org/alpine/edge/community \
	-X https://dl-cdn.alpinelinux.org/alpine/edge/testing \
	-d srb2 \
	-d mesa-gl \
	-d libx11 \
	-d libxext \
	-d alsa-lib \
	-d alsa-plugins \
	-d alsa-plugins-pulse \
	"$appdir"

chmod 775 "$appdir"
sed -i 's/Icon=.*/Icon=srb2/' "$appdir"/usr/share/applications/srb2.desktop
sed -i 's/Exec=.*/Exec=srb2/' "$appdir"/usr/share/applications/srb2.desktop
ln -s usr/share/pixmaps/srb2.png "$appdir"/srb2.png

"$src_dir"/appimagetool.AppImage --appimage-extract

# This old version of patchelf doesn't work with binaries over a certain size
# https://github.com/NixOS/patchelf/issues/305
rm squashfs-root/usr/bin/patchelf

squashfs-root/AppRun -s deploy "$appdir"/usr/share/applications/srb2.desktop

# Demangle ld-musl, which appimagetool messes up with patchelf.
cp /lib/ld-musl-$(uname -m).so.1 "$appdir"/lib/

export VERSION=$(apk --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/testing list srb2 | grep -v fetch | cut -d- -f2)
export ARCH=$(uname -m)
squashfs-root/AppRun "$appdir"
mv Sonic_Robo_Blast_2*.AppImage "$out_dir"/
