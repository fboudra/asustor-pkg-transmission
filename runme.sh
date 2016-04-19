#!/bin/sh

set -ex

WORKSPACE=$(pwd)

LIBIDN_URL="http://ftp.gnu.org/gnu/libidn/libidn-1.32.tar.gz"
LIBEVENT_URL="https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz"
CURL_URL="https://curl.haxx.se/download/curl-7.48.0.tar.bz2"
TRANSMISSION_URL="https://download.transmissionbt.com/files/transmission-2.92.tar.xz"

wget --progress=dot -e dotbytes=2M \
  ${LIBIDN_URL} \
  ${LIBEVENT_URL} \
  ${CURL_URL} \
  ${TRANSMISSION_URL}
tar -xf libidn-*.tar.gz
tar -xf libevent-*.tar.gz
tar -xf curl-*.tar.bz2
tar -xf transmission-*.tar.xz

. ~/bin/asustor-build-env

cd ${WORKSPACE}/libidn-*/
[ -x configure ] && ./configure \
  --host=${ARCH}-asustor-linux-gnu \
  --target=${ARCH}-asustor-linux-gnu \
  --build=x86_64-pc-linux-gnu \
  --prefix=${PREFIX}
make -j$(getconf _NPROCESSORS_ONLN)
sudo make install

cd ${WORKSPACE}/libevent-*/
[ -x configure ] && ./configure \
  --host=${ARCH}-asustor-linux-gnu \
  --target=${ARCH}-asustor-linux-gnu \
  --build=x86_64-pc-linux-gnu \
  --prefix=${PREFIX}
make -j$(getconf _NPROCESSORS_ONLN)
sudo make install

cd ${WORKSPACE}/curl-*/
[ -x configure ] && ./configure \
  --host=${ARCH}-asustor-linux-gnu \
  --target=${ARCH}-asustor-linux-gnu \
  --build=x86_64-pc-linux-gnu \
  --prefix=${PREFIX}
make -j$(getconf _NPROCESSORS_ONLN)
sudo make install

cd ${WORKSPACE}/transmission-*/
[ -x configure ] && ./configure \
  --host=${ARCH}-asustor-linux-gnu \
  --target=${ARCH}-asustor-linux-gnu \
  --build=x86_64-pc-linux-gnu \
  --prefix=${PREFIX}/transmission \
  --enable-cli
make -j$(getconf _NPROCESSORS_ONLN)
sudo make install

cd ${WORKSPACE}
rm -rf libidn-* libevent-* curl-* transmission-*

cp -a /usr/local/AppCentral/transmission/bin/* \
  transmission/bin/
cp -a /usr/local/AppCentral/transmission/share/transmission/web/* \
  transmission/www/

yaml-to-json.py config.yaml > transmission/CONTROL/config.json
apkg-tool create transmission
