#!/bin/sh

VERSION=$1

rm -rf build
mkdir -p build

cd build
qmake ..
make -j8

cd -

cat << EOF > qt-swupdate.conf
{
        "version": "$VERSION",
        "color": "#EEEEEE"
}
EOF
sed -i "s/version:.*/version: $VERSION/" ./nfpm.yaml

nfpm pkg -p deb

