FROM centos:latest
MAINTAINER http://www.xiaoxin.tech
ENV TIME_ZOME Asia/Shanghai
ARG PV="php-5.6.38"

ADD $PV.tar.gz /tmp

RUN yum update -y && yum -y install gcc gcc-c++ make gd-devel bison epel-release libxml2-devel openssl.x86_64 openssl-devel.x86_64 libcurl.x86_64 libcurl-devel.x86_64 libjpeg.x86_64 libpng.x86_64 freetype.x86_64 libjpeg-devel.x86_64 libpng-devel.x86_64 freetype-devel.x86_64 libjpeg-devel libmcrypt libmcrypt-devel m4 autoconf \
    && mkdir /data && cd /tmp/$PV/php && ./configure --prefix=/data/php --with-config-file-path=/data/php/etc --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr-enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-fpm --enable-mbstring --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mysqli=mysqlnd --with-mysql=mysqlnd --with-pdo-mysql --disable-fileinfo && make -j 4 && make install && cp php.ini-production /data/php/etc/php.ini && cp /data/php/etc/php-fpm.conf.default /data/php/etc/php-fpm.conf \
    && groupadd www-data \
    && useradd -g www-data www-data \
    && cd /tmp/$PV/redis \
    && /data/php/bin/phpize \
    && ./configure --with-php-config=/data/php/bin/php-config \
    && make -j 4 \
    && make install \
    && cd /tmp/$PV/yaf \
    && /data/php/bin/phpize \
    && ./configure --with-php-config=/data/php/bin/php-config \
    && make \
    && make install \
    && cd /tmp/$PV/php \
    && sed -i '/;daemonize/a\daemonize = no' /data/php/etc/php-fpm.conf \
    && sed -i 's/127.0.0.1\:9000/0.0.0.0\:9001/g' /data/php/etc/php-fpm.conf \
    && sed -i 's/nobody/www\-data/g' /data/php/etc/php-fpm.conf \
    && echo "[yaf]" >> /data/php/etc/php.ini \
    && echo "extension=yaf.so" >> /data/php/etc/php.ini \
    && echo "yaf.lowcase_path=1" >> /data/php/etc/php.ini \
    && echo "" >> /data/php/etc/php.ini \
    && echo "extension=redis.so" >> /data/php/etc/php.ini \
    && echo "${TIME_ZOME}" > /etc/timezone \
    && ln -sf /usr/share/zoneinfo/${TIME_ZOME} /etc/localtime \
    && rm -rf /tmp/php* \
    && yum clean all \
    && yum -y remove gcc gcc-c++ make

WORKDIR /data/php/
EXPOSE 9001
CMD ["sbin/php-fpm","-y","etc/php-fpm.conf","-c","etc/php.ini"]


