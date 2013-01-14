#!/bin/sh

SHA_PACK="9e388d2c070b15136da1277f4d21f1c788694b12"
SHA_CPATCH="9b35f6ea7fc18548e5394788e3235af56c6b6b61"
SHA_INITS="0166d8204f06a0417f9cdd8d0e870cccac711f18"

CORES_COUNT=$(cat /proc/cpuinfo | grep "processor" | wc -l)

if [ $(id -u) -ne 0 ]; then
  echo "You need execte this as root"
  exit 1
fi

echo "Instaling dependences"

apt-get update && apt-get -y install build-essential patch

if [ $? -ne 0 ]; then
  echo "Error installing dependeces"
  exit 22
fi

echo "Changing folder"

cd /usr/src

echo "Download Redis"

wget http://redis.googlecode.com/files/redis-2.4.15.tar.gz

if [ $? -ne 0 ]; then
  echo "Error downloading Redis"
  exit 2
fi

echo "Check package integrity"

if [ $(sha1sum redis-2.4.15.tar.gz  | cut -d " " -f1) != $SHA_PACK ]; then
  echo "sha1sum don't match"
  exit 3
fi

echo "Uncompress"

tar -xf redis-2.4.15.tar.gz

if [ $? -ne 0 ]; then
  echo "Error uncompressing Redis"
  exit 4
fi

cd redis-2.4.15

echo "Compiling"

make -j $CORES_COUNT

if [ $? -ne 0 ]; then
  echo "Error compiling"
  exit 6
fi


echo "Downloading config patch"

wget http://exodica.com.ar/debian-installers/files/net/redis/redis-conf.patch.2.4.15

if [ $? -ne 0 ]; then
  echo "Error downloading config patch file"
  exit 5
fi

echo "Check integrity"

if [ $(sha1sum redis-conf.patch.2.4.15 | cut -d " " -f1) != $SHA_CPATCH ]; then
  echo "Error cheking config patch file integrity"
  exit 9
fi

echo "Apply patch";

patch redis.conf < redis-conf.patch.2.4.15

echo "Installing"

mkdir -p /etc/redis && \
cp redis.conf /etc/redis/redis.conf && \
cp src/redis-benchmark /usr/bin && \
cp src/redis-cli /usr/bin && \
cp src/redis-server /usr/bin && \
cp src/redis-check-aof /usr/bin && \
cp src/redis-check-dump /usr/bin

if [ $? -ne 0 ]; then
  echo "Error installing"
  exit 7
fi

echo "Downloading init script file"

wget http://exodica.com.ar/debian-installers/files/net/redis/init.script-2.4.15

if [ $? -ne 0 ]; then
  echo "Error downloading init-script file"
  exit 8
fi

echo "Check integrity"

if [ $(sha1sum init.script-2.4.15  | cut -d " " -f1) != $SHA_INITS ]; then
  echo "Error cheking init-script file integrity"
  exit 9
fi

mv init.script-2.4.15 /etc/init.d/redis-server

echo "Creating user"

groupadd redis
useradd  --system --no-create-home -d /var/lib/redis --gid redis -s /bin/false redis

echo "Creating folders and permisits"

mkdir -p /var/run/redis
mkdir -p /var/lib/redis
mkdir -p /var/log/redis

chown -R redis:redis /var/lib/redis
chown -R redis:redis /var/run/redis
chown -R redis:redis /var/log/redis

chmod +x /etc/init.d/redis-server

echo "Set logrotate rulez"

echo "/var/log/redis/*.log {
        weekly
        missingok
        copytruncate
        rotate 12
        compress
        notifempty
}" > /etc/logrotate.d/redis-server

echo "Adding Redis as services"
update-rc.d redis-server defaults

echo "Starting Redis"
/etc/init.d/redis-server start

if [ $? -ne 0 ]; then
  echo "Error starting service"
  exit 9
fi

echo "Instalation is ok"