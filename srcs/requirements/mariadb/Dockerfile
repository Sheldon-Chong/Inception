FROM debian:bullseye

# Install MariaDB server and client in a single layer and clean up
RUN apt update && apt upgrade -y && \
    apt-get install mariadb-server -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY example.env /example.env
COPY init_maria_db.sh /init_maria_db.sh
COPY init_database.sql /init_database.sql
RUN chmod +x /init_maria_db.sh

ENTRYPOINT [ "/init_maria_db.sh" ]