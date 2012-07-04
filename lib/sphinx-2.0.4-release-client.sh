#!/bin/sh

SHA_PACK="168794dcfb4644ac02dcce863c04b351399b0863"

CORES_COUNT=$(cat /proc/cpuinfo | grep "processor" | wc -l)

if [ $(id -u) -ne 0 ]; then
  echo "You need execte this as root"
  exit 1
fi

echo "Instaling dependences"

apt-get update && apt-get -y install libmysql++-dev build-essential

if [ $? -ne 0 ]; then
  echo "Error installing dependeces"
  exit 22
fi

echo "Changing folder"

cd /usr/src

echo "Download Sphinx"

wget http://sphinxsearch.com/files/sphinx-2.0.4-release.tar.gz

if [ $? -ne 0 ]; then
  echo "Error downloading Sphinx"
  exit 2
fi

echo "Check package integrity"

if [ $(sha1sum sphinx-2.0.4-release.tar.gz  | cut -d " " -f1) != $SHA_PACK ]; then
  echo "sha1sum don't match"
  exit 3
fi

echo "Uncompress"

tar -xf sphinx-2.0.4-release.tar.gz

if [ $? -ne 0 ]; then
  echo "Error uncompressing Sphinx"
  exit 4
fi

cd sphinx-2.0.4-release/libsphinxclient

echo "Preparing"

./configure --prefix=/usr

if [ $? -ne 0 ]; then
  echo "Error preparing install"
  exit 5
fi

echo "Compiling"

make -j $CORES_COUNT

if [ $? -ne 0 ]; then
  echo "Error compiling"
  exit 6
fi

echo "Installing"

make install

if [ $? -ne 0 ]; then
  echo "Error installing"
  exit 7
fi

echo "Instalation is ok"