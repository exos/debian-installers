#!/bin/sh

SHA_PACK="f804b730bb3dbf107c79602c51946ab020cf9223"

CORES_COUNT=$(cat /proc/cpuinfo | grep "processor" | wc -l)

if [ $(id -u) -ne 0 ]; then
  echo "You need execte this as root"
  exit 1
fi

echo "Installing sphinx client"

../../lib/sphinx-2.0.4-release-client.sh

if [ $? -ne 0 ]; then
  echo "Error instaling sphinx client"
  exit 55
fi

echo "Instaling dependences"

apt-get update && apt-get -y install php5 php5-dev

if [ $? -ne 0 ]; then
  echo "Error installing dependeces"
  exit 22
fi

echo "Changing folder"

mkdir /usr/src/pecl

cd /usr/src/pecl

echo "Download Sphinx PECL"

wget http://pecl.php.net/get/sphinx-1.2.0.tgz

if [ $? -ne 0 ]; then
  echo "Error downloading Sphinx PECL extension"
  exit 2
fi

echo "Check package integrity"

if [ $(sha1sum sphinx-1.2.0.tgz  | cut -d " " -f1) != $SHA_PACK ]; then
  echo "sha1sum don't match"
  exit 3
fi

echo "Uncompress"

tar -xf sphinx-1.2.0.tgz

if [ $? -ne 0 ]; then
  echo "Error uncompressing Sphinx"
  exit 4
fi

cd sphinx-1.2.0

echo "Preparing"

phpize && ./configure --with-sphinx=/usr

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

echo "Creating PHP configuration file"

echo "[sphinx]
extension=sphinx.so" > /etc/php5/conf.d/sphinx.ini

echo "Instalation is ok, remember you need restart the webserver or fastCGI daemon"