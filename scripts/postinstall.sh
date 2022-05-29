#!/bin/sh

systemctl daemon-reload
systemctl start qt-swupdate
systemctl enable qt-swupdate
