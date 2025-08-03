-- create database
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

-- create user
/*
in MySQL/MariaDB, users are defined as 'username'@'hostname'. 
'hostname' specifies where the user can connect from
- Typically, you'd specify a hostname/ip, like 192.168.1.100
- using % means any host is able to connect.
*/
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

-- set user permisions
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
FLUSH PRIVILEGES;