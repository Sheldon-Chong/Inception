#!/bin/bash
service mariadb start


# Generates an SQL file by reading'init_database.sql' and writing them into 'db1.sql' using a herdoc and command substitution.
# 'eval allows variable and command expansion within the SQL content.
eval "cat <<EOF >db1.sql
$(cat init_database.sql)
EOF"


mysql < db1.sql

# Shuts down the MariaDB server using the mysqladmin tool.
# shutting down the MariaDB server requires sufficient permissions, hence we shut down as root user
mysqladmin -u root -p${ROOT_PASSWORD} shutdown

# this will execute mysqsld as PID 1, by replacing the current shell
# without exec, it will not be PID 1
# use "ps -p 1" to verify that mysqld is process1
exec mysqld