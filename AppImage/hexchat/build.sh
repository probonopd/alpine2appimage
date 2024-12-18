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
	"$appdir"

chmod 755 "$appdir"

############################################

find "$appdir" || true

# Parsing svg is a pain for AppImage thumbnailers, hence use png
# ImageMagick even fails to convert the svg, hence we have to grab a png from their website
apk add imagemagick
wget -q "https://avatars.githubusercontent.com/u/1938483?s=200&v=4" -O hexchat.png
magick hexchat.png -resize 128@ "$appdir"/usr/share/icons/hicolor/128x128/apps/io.github.Hexchat.png
cp "$appdir"/usr/share/icons/hicolor/128x128/apps/io.github.Hexchat.png .
rm hexchat.png

############################################

# Remove extraneous symlinks (to busybox)
find "$appdir"/usr/bin/ -type l -delete

# Remove extraneous binaries and directories
rm -rf "$appdir"/bin/
rm -rf "$appdir"/sbin/
find "$appdir"/usr/bin/ -type f -not -name "$PACKAGE" -delete # FIXME: It would be better not have those installed in the first place...
rm -rf "$appdir"/usr/sbin/
rm -rf "$appdir"/usr/libexec/
rm -rf "$appdir"/usr/share/udhcpc
rm -rf "$appdir"/etc/
rm -rf "$appdir"/dev/
rm -rf "$appdir"/var/
rm -rf "$appdir"/proc/
rm -rf "$appdir"/tmp/

############################################

export APPIMAGE_EXTRACT_AND_RUN=1
"$tools_dir"/appimagetool.AppImage -s deploy "$appdir"/usr/share/applications/*.desktop

############################################

# No post-post-processing needed for this application

############################################

rdfind -makesymlinks true . # Replace duplicate files with symlinks

"$tools_dir"/appimagetool.AppImage "$appdir"
mv *.AppImage "$out_dir"/
