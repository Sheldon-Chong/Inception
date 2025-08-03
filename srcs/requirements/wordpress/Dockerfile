FROM debian:bullseye

ENV WORDPRESS_ROOT=/var/www/html
ENV WEB_USER=www-data
ENV WEB_GROUP=www-data

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        curl \
        php \
        php-fpm \
        php-mysql \
        php-cli \
        unzip \
        less \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# -- Download WordPress CLI --
# so that we can use it from bash, and automate the creation of users
RUN curl  --remote-name https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv    wp-cli.phar /usr/local/bin/wp

# # -- Download less --
# # less is a command-line pager program.
# # lets you view/scroll-through text output a screen at a time.
# # WP-CLI uses less to display paged output by default.
# RUN apt-get install -y less

# Download the latest WordPress archive and pass value in to tar to extract to wordpress root
# --strip-components=1 removes the top-level directory from the archive.
RUN mkdir -p ${WORDPRESS_ROOT} && \
    curl https://wordpress.org/latest.tar.gz | \ 
        tar zx --directory ${WORDPRESS_ROOT} --strip-components=1 && \
    chown --recursive ${WEB_USER}:${WEB_GROUP} ${WORDPRESS_ROOT}

# var/log directory is used to store log files for the system and applications.
# run/php contains files to comunicate between webserver and php-fpm
# change owner of both of these directories to the web user
RUN mkdir -p /var/log && chown --recursive ${WEB_USER}:${WEB_GROUP} /var/log
RUN mkdir -p /run/php && chown --recursive ${WEB_USER}:${WEB_GROUP} /run/php

COPY ./tools/init_wordpress.sh /init_wordpress.sh 
RUN chmod +x /init_wordpress.sh

#modify PHP-FPM config to listen on TCP port 9000 on all interfaces (all interfaces is 0.0.0.0)
RUN sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf

WORKDIR ${WORDPRESS_ROOT}
USER www-data

ENTRYPOINT [ "/init_wordpress.sh" ]



# RUN sed -i "s/^pm\.max_children\s*=.*/pm.max_children = 30/" /etc/php/7.4/fpm/pool.d/www.conf
# RUN sed -i "s/^pm\.start_servers\s*=.*/pm.start_servers = 8/" /etc/php/7.4/fpm/pool.d/www.conf
# RUN sed -i "s/^pm\.min_spare_servers\s*=.*/pm.min_spare_servers = 4/" /etc/php/7.4/fpm/pool.d/www.conf
# RUN sed -i "s/^pm\.max_spare_servers\s*=.*/pm.max_spare_servers = 12/" /etc/php/7.4/fpm/pool.d/www.conf



# # Download WordPress
# RUN mkdir -p /srv/www && \
#     # download latest wordpress version, and extract contents
#     curl https://wordpress.org/latest.tar.gz | \
#     tar zx -C /srv/www --strip-components=1 && \
    
#     # - www-data is a standard user and group to be used by web servers like Nginx.
#     # - files/processes in www-data have limited permissions for security, preventing web applications from having root access.
#     chown --recursive ${WEB_USER}:${WEB_GROUP} /srv/www