# qt-swupdate
An example implementation for [swupdate](https://github.com/sbabic/swupdate) used by a qt application. This is a proof of concept and not meant for production yet.

# Build
If you want to compile the binary just run:
```
qmake qt-swupdate.pro
make -j
```

If you want to build and package the binary you can use the build.sh script. However, [nfpm](https://nfpm.goreleaser.com/) is required to generate the Debian package.

