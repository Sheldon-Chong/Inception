#!/bin/bash

service mariadb start

# Source the .env file to load environment variables
source ./example.env
eval "cat <<EOF >db1.sql
$(cat init_database.sql)
EOF"

mysql < db1.sql

# kill $(cat /var/run/mysqld/mysqld.pid)
mysqladmin -u root -p${ROOT_PASSWORD} shutdown

# this will execute mysqsld as PID 1
# without exec, it will not be PID 1
# use "ps -p 1" to verify that mysqld is process1
exec mysqld
