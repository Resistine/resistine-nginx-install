#!/bin/bash
#!/bin/bash

# Exit on errors
set -e
if  [[ -e build ]];then
  rm -rf build
fi

mkdir build
cd build
apt update
apt upgrade -y
apt install -y build-essential libgeoip-dev liblmdb-dev libyajl-dev systemctl autoconf automake libtool libpcre3 libpcre3-dev libcurl4 ssdeep python3-ssdeep libpcre2-dev autotools-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev git

# Clone the ModSecurity repository
git clone https://github.com/owasp-modsecurity/ModSecurity.git
cd ModSecurity

export CFLAGS="-g -O0"

# Initialize and update submodules
git submodule init
git submodule update --recursive

./build.sh
autoupdate
libtoolize
aclocal
./build.sh
# Configure and build ModSecurity
./configure --with-geoip --with-pcre2 --with-lmdb --with-jayl
make
make install
cd ..

# Clone the ModSecurity-nginx connector repository
git clone https://github.com/owasp-modsecurity/ModSecurity-nginx

# Download, extract, and enter the Nginx source directory
git clone https://github.com/nginx/nginx.git
cd nginx*
git submodule init
git submodule update --recursive

# Create nginx user
useradd -r -M -s /sbin/nologin -d /usr/local/nginx nginx || echo "nginx user already exists"

# Configure Nginx with ModSecurity dynamic module
# Note: Corrected the dashes and module path
auto/configure --user=nginx --group=nginx --with-pcre-jit \
--with-stream --with-debug --with-compat --with-http_ssl_module \
--with-http_realip_module --add-dynamic-module=../ModSecurity-nginx \
--http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log \
--with-http_dav_module --with-http_slice_module --with-http_v2_module \
--with-http_addition_module --with-threads

# Build and install Nginx
make
make modules
make install

mkdir -p /var/log/nginx
# Link nginx to the system path
if  [[ -e /usr/local/sbin/nginx ]]; then
  rm -f /usr/local/sbin/nginx
fi
ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/
# Copy ModSecurity configuration files to Nginx directory
cp -f ../ModSecurity/modsecurity.conf-recommended /usr/local/nginx/conf/modsecurity.conf
cp -f ../ModSecurity/unicode.mapping /usr/local/nginx/conf/

# Backup the original nginx.conf file
cp -f /usr/local/nginx/conf/nginx.conf{,.bak}

# Assume nginx.conf provided by user is in the parent directory
# If not, you need to modify the path accordingly
cp -f ./nginx.conf /usr/local/nginx/conf/nginx.conf

# Enable ModSecurity in the nginx configuration
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /usr/local/nginx/conf/modsecurity.conf

# Clone the OWASP CRS (Core Rule Set)
if [ -e /tmp/owasp-crs ]; then
  rm -rf /tmp/owasp-crs
fi
git clone https://github.com/SpiderLabs/owasp-modsecurity-crs /tmp/owasp-crs
cp -rf /tmp/owasp-crs /usr/local/nginx/conf/
# Copy the CRS setup file
cp -f /usr/local/nginx/conf/owasp-crs/crs-setup.conf.example /usr/local/nginx/conf/owasp-crs/crs-setup.conf

# Include OWASP CRS configuration in ModSecurity
echo -e "Include owasp-crs/crs-setup.conf\nInclude owasp-crs/rules/*.conf" >> /usr/local/nginx/conf/modsecurity.conf

# Setup Nginx service
# Assume nginx.service provided by user is in the parent directory
# If not, you need to modify the path accordingly
cp -f ./nginx.service /etc/systemd/system/nginx.service
ln -sf /usr/local/nginx/conf /etc/nginx
ln -sf /usr/local/nginx/sbin/nginx /usr/sbin/

# Reload systemd, start and enable Nginx service
systemctl enable nginx.service
systemctl start nginx
