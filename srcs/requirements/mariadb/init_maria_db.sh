#!/bin/bash

service mariadb start


echo "test" > database.sql

# Source the .env file to load environment variables
source ./example.env

# Use the variables in a here-document
cat <<EOF > db1.sql
-- SQL script preview:
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
FLUSH PRIVILEGES;
EOF

# kill $(cat /var/run/mysqld/mysqld.pid)
mysqladmin shutdown

# this will execute mysqsld as PID 1
exec mysqld

# below will execute mysqld, but not as pid 1. Use "ps -p 1"
# mysqld
