#!/bin/sh
# Create the final disk image

rm -rf build/framework
mkdir build/framework
cp -R build/"${PROJECT_NAME}".framework build/framework
hdiutil create -ov -srcfolder build/framework -fs HFS+ -volname "Kaazing ${PROJECT_NAME}" "build/framework/${PROJECT_NAME}.dmg"
