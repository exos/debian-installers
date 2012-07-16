#!/bin/sh

SHA_PACK="168794dcfb4644ac02dcce863c04b351399b0863"
SHA_CPATCH="37182ac745bbcd8d8c9a10ee1782feb76331a5a4"
SHA_INITS="99911d42e7b3f800ad0379c2c8e1f01c8b7029ba"

CORES_COUNT=$(cat /proc/cpuinfo | grep "processor" | wc -l)

if [ $(id -u) -ne 0 ]; then
  echo "You need execte this as root"
  exit 1
fi

echo "Instaling dependences"

apt-get update && apt-get -y install libmysql++-dev build-essential patch

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

cd sphinx-2.0.4-release

echo "Preparing"

./configure --prefix=/usr --sysconfdir=/etc --datadir=/var/lib/sphinx --with-mysql

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

echo "Creating uset sphinx"

groupadd sphinx && useradd --system --home-dir /var/lib/sphinx  sphinx --gid sphinx


if [ $? -ne 0 ]; then
  echo "Error creating user sphinx"
  exit 8
fi

echo "Moving configuration to /etc"

mv sphinx.conf.dist /etc/sphinx.conf

echo "Downloading configuration patch"

wget http://exodica.com.ar/debian-installers/files/net/sphinx/config-2.0.4-release-1.patch

if [ $? -ne 0 ]; then
  echo "Error downloading onfiguration patch file"
  exit 9
fi

echo "Check integrity"

if [ $(sha1sum config-2.0.4-release-1.patch  | cut -d " " -f1) != $SHA_CPATCH ]; then
  echo "Error cheking configuration patch file integrity"
  exit 10
fi

patch /etc/sphinx.conf config-2.0.4-release-1.patch


echo "Downloading init script"

wget http://exodica.com.ar/debian-installers/files/net/sphinx/init.script-2.0.4-release

if [ $? -ne 0 ]; then
  echo "Error downloading init sctipt file"
  exit 11
fi

echo "Check integrity"

if [ $(sha1sum init.script-2.0.4-release  | cut -d " " -f1) != $SHA_INITS ]; then
  echo "Error cheking init-script file integrity"
  exit 12
fi

mv init.script-2.0.4-release /etc/init.d/searchd

echo "Creating folders and permisits"

mkdir /var/log/sphinx
mkdir -p /var/lib/sphinx/data
mkdir -p /var/lib/sphinx/binlog
mkdir /var/run/sphinx
touch /var/run/sphinx/searchd.pid

chown sphinx:sphinx /var/log/sphinx
chown -R sphinx:sphinx /var/lib/sphinx
chown -R sphinx:sphinx /var/run/sphinx

chmod +x /etc/init.d/searchd


echo "Adding Shpinx as services"
update-rc.d searchd defaults

echo "Starting searchd"
/etc/init.d/searchd start

if [ $? -ne 0 ]; then
  echo "Error starting service"
  exit 13
fi

echo "Instalation is ok"