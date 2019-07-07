#!/bin/sh
set -e

src_dir=$PWD
build_dir=${RISK_OF_RAIN_BUILD_DIR:-/tmp/Risk_of_Rain_build}
out_dir=${RISK_OF_RAIN_OUT_DIR:-/tmp/out}
Risk_of_Rain_zip=${RISK_OF_RAIN_ZIP:-Risk_of_Rain_v1.3.0_DRM-Free_Linux_.zip}

if [ ! -f "$Risk_of_Rain_zip" ]; then
    printf '\nFile not found: %s\n' "$Risk_of_Rain_zip"
    echo 'The Risk of Rain data is missing. Please copy the zip file to this' \
        'directory or set the correct location with the environment variable' \
        'RISK_OF_RAIN_ZIP.'
    exit 1
fi

dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y unzip wget \
        libidn11:i386 \
        libstdc++6:i386 \
        zlib1g:i386 \
        libxxf86vm1:i386 \
        libgl1-mesa-glx:i386 \
        libcurl3:i386 \
        libopenal1:i386 \
        libxrandr2:i386 \
        libglu1-mesa:i386

[ ! -e "$build_dir" ] && mkdir -p "$build_dir"
cd "$build_dir"

wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage
./linuxdeploy-x86_64.AppImage --appimage-extract
mv squashfs-root linuxdeploy-root

mkdir app/
unzip "$src_dir/$Risk_of_Rain_zip" -d app/
cp "$src_dir/Risk_of_Rain.desktop" app/

# Make the AppDir.
linuxdeploy-root/usr/bin/linuxdeploy --appdir=AppDir

# Add the assets to the AppDir.
mkdir -p AppDir/usr/share/Risk_of_Rain/
#cp -vR app/assets AppDir/usr/share/Risk_of_Rain/
# Bleh
cp -vR app/assets AppDir/usr/bin/

# Add the binary and metadata to the AppDir.
linuxdeploy-root/usr/bin/linuxdeploy \
    --appdir=AppDir \
    --executable=app/Risk_of_Rain \
    --library=/lib/i386-linux-gnu/libc.so.6 \
    --library=/lib/i386-linux-gnu/libcom_err.so.2 \
    --library=/lib/i386-linux-gnu/libdl.so.2 \
    --library=/lib/i386-linux-gnu/libgpg-error.so.0 \
    --library=/lib/i386-linux-gnu/libkeyutils.so.1 \
    --library=/lib/i386-linux-gnu/libpthread.so.0 \
    --library=/lib/i386-linux-gnu/libresolv.so.2 \
    --library=/lib/i386-linux-gnu/librt.so.1 \
    --library=/lib/i386-linux-gnu/libz.so.1 \
    --library=/usr/lib/i386-linux-gnu/libX11.so.6 \
    --library=/usr/lib/i386-linux-gnu/libdrm.so.2 \
    --library=/usr/lib/i386-linux-gnu/libglapi.so.0 \
    --library=/usr/lib/i386-linux-gnu/libp11-kit.so.0 \
    --library=/usr/lib/i386-linux-gnu/libstdc++.so.6 \
    --library=/usr/lib/i386-linux-gnu/libxcb-dri2.so.0 \
    --library=/usr/lib/i386-linux-gnu/libxcb-dri3.so.0 \
    --library=/usr/lib/i386-linux-gnu/libxcb.so.1 \
    --library=/usr/lib/i386-linux-gnu/mesa/libGL.so.1 \
    --desktop-file=app/Risk_of_Rain.desktop \
    --icon-file=app/assets/icon.png \
    --output=appimage \
    && mkdir -p "$out_dir" \
    && mv Risk_of_Rain*.AppImage "$out_dir"
