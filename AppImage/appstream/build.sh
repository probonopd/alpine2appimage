#!/bin/sh
set -eux

export VERSION=$(apk --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/testing list "$PACKAGE" | grep -v fetch | cut -d- -f2)
export ARCH=$(uname -m)

src_dir=${SRC_DIR:-/src}
out_dir=${OUT_DIR:-/out}
tools_dir=${TOOLS_DIR:-/tools}
appdir="$out_dir"/"$PACKAGE".AppDir

apk update && apk add file patchelf

"$tools_dir"/witchery-compose \
	-k /etc/apk/keys \
	-X https://dl-cdn.alpinelinux.org/alpine/edge/main \
	-X https://dl-cdn.alpinelinux.org/alpine/edge/community \
	-X https://dl-cdn.alpinelinux.org/alpine/edge/testing \
	-d "$PACKAGE" \
	"$appdir"

chmod 755 "$appdir"

############################################

mkdir -p "$appdir"/usr/share/applications/
cat > "$appdir"/usr/share/applications/appstreamcli.desktop <<\EOF
[Desktop Entry]
Type=Application
Name=appstreamcli
Comment=Tool to validate AppStream metadata on the command line
Exec=appstreamcli
Icon=appstreamcli
Categories=Utility;
Terminal=true
EOF

mkdir -p "$appdir"/usr/share/pixmaps/
wget https://github.com/ximion/appstream/raw/main/docs/images/src/png/appstream-logo.png -O "$appdir"/usr/share/pixmaps/appstreamcli.png

ln -s usr/share/pixmaps/appstreamcli.png "$appdir"/appstreamcli.png

############################################

"$tools_dir"/appimagetool.AppImage --appimage-extract

# This old version of patchelf doesn't work with binaries over a certain size
# https://github.com/NixOS/patchelf/issues/305
rm squashfs-root/usr/bin/patchelf

squashfs-root/AppRun -s deploy "$appdir"/usr/share/applications/appstreamcli.desktop

# Demangle ld-musl, which appimagetool messes up with patchelf.
cp /lib/ld-musl-$(uname -m).so.1 "$appdir"/lib/

############################################

# No post-processing needed for this application

############################################

squashfs-root/AppRun "$appdir"
mv *.AppImage "$out_dir"/
