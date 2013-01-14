#!/bin/sh

SHA_PACK="65d22e4e183cee8888c797300d8fdbb5c530c740" 
SRC_URL="http://nodejs.org/dist/v0.8.17/node-v0.8.17.tar.gz"
DEPENDS="build-essential libssl-dev libreadline-dev"
PACKNAME="node-v0.8.17.tar.gz"
FOLDERNAME="node-v0.8.17"

CORES_COUNT=$(cat /proc/cpuinfo | grep "processor" | wc -l)

if [ $(id -u) -ne 0 ]; then
  echo "You need execte this as root"
  exit 1
fi

echo "Instaling dependences"

apt-get update && apt-get -y install $DEPENDS 

if [ $? -ne 0 ]; then
  echo "Error installing dependeces"
  exit 22
fi

echo "Changing folder"

cd /usr/src

echo "Downloading Node.js"

wget $SRC_URL

if [ $? -ne 0 ]; then
  echo "Error downloading Node.js"
  exit 2
fi

echo "Checking package integrity"

if [ $(sha1sum $PACKNAME  | cut -d " " -f1) != $SHA_PACK ]; then
  echo "sha1sum don't match"
  exit 3
fi

echo "Decompressing..."

tar -xf $PACKNAME

if [ $? -ne 0 ]; then
  echo "Error decompressing Node.js"
  exit 4
fi

cd $FOLDERNAME

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
