#!/bin/bash
#!/bin/bash

# Exit on errors
set -e
if  [[ -e build ]];then
  rm -rf build
fi

mkdir build
cd build

# Clone the ModSecurity repository
git clone https://github.com/owasp-modsecurity/ModSecurity.git
cd ModSecurity

export CFLAGS="-g -O0"

# Initialize and update submodules
git submodule init
git submodule update --recursive
./build.sh
# Configure and build ModSecurity
./configure
make
make install
cd ..

# Clone the ModSecurity-nginx connector repository
git clone https://github.com/owasp-modsecurity/ModSecurity-nginx

# Download, extract, and enter the Nginx source directory
wget https://nginx.org/download/nginx-1.25.3.tar.gz
tar -xvf nginx-1.25.3.tar.gz
cd nginx-1.25.3

# Create nginx user
useradd -r -M -s /sbin/nologin -d /usr/local/nginx nginx || echo "nginx user already exists"

# Configure Nginx with ModSecurity dynamic module
# Note: Corrected the dashes and module path
./configure --user=nginx --group=nginx --with-pcre-jit \
--with-http_proxy_module --with-debug --with-compat --with-http_ssl_module \
--with-http_realip_module --add-dynamic-module=../ModSecurity-nginx \
--http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log \
--with-http_dav_module --with-http_slice_module --with-http_v2_module \
--with-http_addition_module --with-threads

# Build and install Nginx
make
make modules
make install

# Link nginx to the system path
ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/

# Copy ModSecurity configuration files to Nginx directory
cp ../ModSecurity/modsecurity.conf-recommended /usr/local/nginx/conf/modsecurity.conf
cp ../ModSecurity/unicode.mapping /usr/local/nginx/conf/

# Backup the original nginx.conf file
cp /usr/local/nginx/conf/nginx.conf{,.bak}

# Assume nginx.conf provided by user is in the parent directory
# If not, you need to modify the path accordingly
cp ../nginx.conf /usr/local/nginx/conf/nginx.conf

# Enable ModSecurity in the nginx configuration
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /usr/local/nginx/conf/modsecurity.conf

# Clone the OWASP CRS (Core Rule Set)
git clone https://github.com/SpiderLabs/owasp-modsecurity-crs /usr/local/nginx/conf/owasp-crs

# Copy the CRS setup file
cp /usr/local/nginx/conf/owasp-crs/crs-setup.conf.example /usr/local/nginx/conf/owasp-crs/crs-setup.conf

# Include OWASP CRS configuration in ModSecurity
echo -e "Include owasp-crs/crs-setup.conf\nInclude owasp-crs/rules/*.conf" >> /usr/local/nginx/conf/modsecurity.conf

# Setup Nginx service
# Assume nginx.service provided by user is in the parent directory
# If not, you need to modify the path accordingly
cp ../nginx.service /etc/systemd/system/nginx.service

# Reload systemd, start and enable Nginx service
systemctl daemon-reload
systemctl start nginx
systemctl enable nginx
