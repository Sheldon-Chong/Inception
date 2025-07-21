FROM debian:bullseye

RUN apt update && apt upgrade -y && \
    apt-get install -y curl php php-fpm php-mysql php-cli unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download WordPress
RUN mkdir -p /srv/www && \
    chown www-data: /srv/www && \
    curl https://wordpress.org/latest.tar.gz | tar zx -C /srv/www --strip-components=1 && \
    chown -R www-data:www-data /srv/www

WORKDIR /srv/www

COPY init_wordpress.sh /init_wordpress.sh 
COPY wp-config_new.php /wp-config_new.php

RUN chmod +x /init_wordpress.sh

# Start PHP's built-in server on port 8000
ENTRYPOINT [ "/init_wordpress.sh" ]