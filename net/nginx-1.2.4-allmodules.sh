#!/bin/sh

SHA_PACK="e3de0b2b82095f26e96bdb461ba36472d3e7cdda"
SHA_INITS="814c930560f15d4e605d91fe2c5cdd4b6d204256"
SRC_URL="http://nginx.org/download/nginx-1.2.4.tar.gz"
DEPENDS="build-essential libc6 libpcre3 libpcre3-dev libpcrecpp0 libssl0.9.8 libssl-dev zlib1g zlib1g-dev lsb-base"

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

echo "Download Nginx"

wget $SRC_URL 

if [ $? -ne 0 ]; then
  echo "Error downloading Nginx"
  exit 2
fi

echo "Check package integrity"

if [ $(sha1sum nginx-1.2.4.tar.gz  | cut -d " " -f1) != $SHA_PACK ]; then
  echo "sha1sum don't match"
  exit 3
fi

echo "Uncompress"

tar -xf nginx-1.2.4.tar.gz

if [ $? -ne 0 ]; then
  echo "Error uncompressing Nginx"
  exit 4
fi

cd nginx-1.2.4

echo "Preparing"

./configure --sbin-path=/usr/sbin --conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid \
--lock-path=/var/lock/nginx.lock --http-log-path=/var/log/nginx/access.log \
--http-client-body-temp-path=/var/lib/nginx/body \
--http-proxy-temp-path=/var/lib/nginx/proxy \
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi --with-debug \
--with-http_stub_status_module --with-http_flv_module --with-http_ssl_module \
--with-http_dav_module --with-ipv6 --with-http_gzip_static_module

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

echo "Downloading init script file"

wget http://exodica.com.ar/debian-installers/files/net/nginx/init.sctipt-1.2.0

if [ $? -ne 0 ]; then
  echo "Error downloading init-script file"
  exit 8
fi

echo "Check integrity"

if [ $(sha1sum init.sctipt-1.2.0  | cut -d " " -f1) != $SHA_INITS ]; then
  echo "Error cheking init-script file integrity"
  exit 9
fi

mv init.sctipt-1.2.0 /etc/init.d/nginx

echo "Creating folders and permisits"

mkdir -p /var/lib/nginx/body
chown -R www-data:www-data /var/lib/nginx
chmod +x /etc/init.d/nginx

echo "Creating logrotate conf"

echo "/var/log/nginx/*.log {
 daily
 missingok
 rotate 52
 compress
 delaycompress
 notifempty
 create 640 root adm
 sharedscripts
 postrotate
  [ ! -f /var/run/nginx.pid ] || kill -USR1 \`cat /var/run/nginx.pid\`
 endscript
}
" > /etc/logrotate.d/nginx 

echo "Adding Nginx as services"
update-rc.d nginx defaults

echo "Starting nginx"
/etc/init.d/nginx start

if [ $? -ne 0 ]; then
  echo "Error starting service"
  exit 9
fi

echo "Instalation is ok"
