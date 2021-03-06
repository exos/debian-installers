#!/bin/sh

SHA_PACK="892790553b8121ba8624d8293d0cb7d8b01094d7"

CORES_COUNT=$(cat /proc/cpuinfo | grep "processor" | wc -l)

if [ $(id -u) -ne 0 ]; then
  echo "You need execte this as root"
  exit 1
fi

echo "Instaling dependences"

apt-get update && apt-get -y install build-essential 

if [ $? -ne 0 ]; then
  echo "Error installing dependeces"
  exit 22
fi

echo "Changing folder"

cd /usr/src

echo "Downloading Node.js"

wget http://nodejs.org/dist/v0.8.1/node-v0.8.1.tar.gz

if [ $? -ne 0 ]; then
  echo "Error downloading Node.js"
  exit 2
fi

echo "Checking package integrity"

if [ $(sha1sum node-v0.8.1.tar.gz  | cut -d " " -f1) != $SHA_PACK ]; then
  echo "sha1sum don't match"
  exit 3
fi

echo "Decompressing..."

tar -xf node-v0.8.1.tar.gz

if [ $? -ne 0 ]; then
  echo "Error decompressing Node.js"
  exit 4
fi

cd node-v0.8.1

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
exit 0