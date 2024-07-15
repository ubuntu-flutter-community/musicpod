#!/usr/bin/env bash
# build app
flutter build linux --release
# create directory for appimage generation if not exists
mkdir -p appimage/musicpod.AppDir/opt/musicpod
# copy app contents to it
cp -r build/linux/x64/release/bundle/ appimage/musicpod.AppDir/opt/musicpod
# copy icon
cp snap/gui/musicpod.png appimage/musicpod.AppDir/music-app.png
# create runner
cat > appimage/musicpod.AppDir/AppRun <<EOF
#!/bin/sh

function readlink_file()
{
    next_path=\$1
    while [ "\$i" != 10 ] && [ "x\$next_path" != "x\$path" ]; do
        path=\$next_path
        next_path=\$(readlink "\$path" || echo \$path)
        i=\`expr \$i + 1\`
    done
    echo "\$path"
}

function basedir()
{
    file=\$(readlink -f "\$1") || \$(readlink_file "\$1")
    echo \$(cd "\$(dirname "\$file")" && pwd -P)
}

cd \$(basedir "\$0") && opt/musicpod/bundle/musicpod
EOF
# make it executable
chmod +x appimage/musicpod.AppDir/AppRun
# copy .desktop file
cp snap/gui/musicpod.desktop appimage/musicpod.AppDir/
# make appimage
cd appimage && ~/Applications/appimagetool musicpod.AppDir
cd ..
