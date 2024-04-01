FROM php:7.2-apache

# This image is not to be used on a production server!
# I use it for local development on old projects (hence the PHP version).

# Install gd, iconv, mbstring, mysql, soap, sockets extensions
# see example at https://hub.docker.com/_/php/
RUN apt-get update
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxslt-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli pdo pdo_mysql xsl


# Install xdebug. Couldn't connect to it in my boot2docker instance, useful
# nonetheless.
# IMPORTANT: These settings are not recommended for production servers!
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN echo ';xdebug.scream=1' >> cxdebug.ini \
    && echo 'xdebug.remote_enable=1' >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo 'xdebug.remote_autostart=1' >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo 'xdebug.remote_connect_back=1' >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo 'xdebug.remote_port=9000' >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo 'xdebug.remote_mode=req' >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo 'xdebug.remote_handler=dbgp' >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo 'xdebug.remote_log=/tmp/php5-xdebug.log' >> /usr/local/etc/php/conf.d/xdebug.ini


## enable mod_rewrite
RUN a2enmod rewrite

# make the webroot a volume
VOLUME /var/www/html/


# support jwilder/nginx-proxy resp. docker-gen
# You may wan to overwrite VIRTUAL_HOST in your Docker file.
EXPOSE 80
ENV VIRTUAL_HOST site.local
ENV UPSTREAM_NAME web-site


# Add a PHP config file. The file was copied from a php53 dotdeb package and
# lightly modified (mostly for improving debugging). This may not be the best
# idea.
COPY config/php.ini /usr/local/etc/php/

#EOF
