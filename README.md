# Readme

This repository is the submission for “42’s Inception” project 

<aside>
<img src="https://www.notion.so/icons/table_gray.svg" alt="https://www.notion.so/icons/table_gray.svg" width="40px" />

</aside>

# ⌨️ Starting the server

To understand what the final project looks like, I recommend running this server first, and playing around.

### Preparing the server

- By default, when ran, my server will be accessible via `https://localhost`. For my server to be accessed via `shechong.42.fr` (as I will be referring to in later examples), you will need to include the following line in `/etc/host`:
    
    ```
    127.0.0.1     local.example.com
    ```
    
    `/etc/hosts` is a file that translates hostnames (like `www.example.com`) into their corresponding IP addresses (like `192.168.1.100`). 
    
- When starting my server, a `.env` file will need to be present in the `/srcs` folder. This file must contain certain key-value parameters. These parameters are used throughout the container in the form of env variables. Fill-in `env.template` and rename it to `.env` to make this program work.

### Running the server

- `make` to build the server
- `make clean` stop the server
- `make fclean` to delete stop the container and delete volumes. This can be considered performing a full shutdown on the server
- `make re` to re-build the server. Effectively full reset of the server.

All containers are built from scratch, meaning no pre-built images are pulled from external sources. Each of my containers use the base image “Debian Bullseye”. This version as of August 2025 is the penultimate **stable** version of Debian (Meaning the 2nd latest version of Debian).

### Accessing the website

Once the server has initiated, it can be accessed through any browser. To access the server, you can use `https://localhost` . 

---

# 📖 Understanding the basics of this project

This server utilizes 3 Docker containers. 

> A **Docker container** is a lightweight, self-contained package that bundles an application together with everything it needs to run.
> 
> 
> This includes aspects such as:
> 
> - code
> - runtime
> - system libraries
> - configuration files
> 
> such that it behaves the same no matter where it is started from (a laptop, another machine, a cloud server.
> 

## Virtual Machines vs Containers

Containers can be best understood when compared with Virtual Machines, as both work similarly. Below is a visual diagram, comparing the Virtualization Stack Architecture of a system using a VM, versus a system using a Docker container. 

![image.png](/readme/image.png)

A virtual machine (VM) emulates an entire physical computer. Each VM includes its own full guest operating system (Linux, Windows, etc.) running on top of a hypervisor such as VMware ESXi or KVM. 

- Because every VM carries a complete OS kernel, device drivers, and system libraries, it is large (gigabytes), slow to boot (tens of seconds to minutes), and relatively heavy on RAM and CPU.
- VMs provide strong isolation and can run different OS families on the same host.

![image.png](/srcs/image%201.png)

Docker containers, share the host machine’s kernel (meaning if the host kernel is Linux, only can distributions of Linux run atop it). A container package together binaries, libraries, and configuration files.

- A container starts almost instantly (milliseconds to a second)
- Consumes far less memory and CPU because it does not its own OS.
- While containers offer less isolation depth (they all run on the same kernel), they are very portable, making it practical to run dozens of containers on a single host

## Services

Each container has a running service. To understand how to final server works, we need to understand what each service does. 

### MySQL and MariaDB

> **MySQL** is a Relational database management system that stores data in tables. Data that is stored can be accessed and queried by using Structured Query Language (SQL), via SQL statements such as `SELECT`, `INSERT`, `UPDATE`, and `DELETE`.
> 

> **MariaDB** is Open-source fork of MySQL, meaning it utilizes the same SQL syntax, however offers additional storage engines and performance improvements.
> 
- Installed using `apt-get install mariadb-server -y`
https://mariadb.com/docs/server/mariadb-quickstart-guides/installing-mariadb-server-guide
- Can be configured by editing the `/etc/mysql/mariadb.conf.d/50-server.cnf` file
https://mariadb.com/docs/server/server-management/install-and-upgrade-mariadb/configuring-mariadb/configuring-mariadb-with-option-files

### WordPress and PHP

PHP is a Server-side scripting language designed for web development. 

- It is typically embedded inside HTML pages, and is used to produce dynamic HTML content and make interactive websites
    
    ```yaml
    <!DOCTYPE html>
    <html>
    <head><title>PHP in HTML</title></head>
    <body>
        <?php echo "<h1>Hello World</h1>"; ?>
    </body>
    </html>
    ```
    
- It is executed by an interpreter or PHP-FPM.

**WordPress** is an open-source content-management system (CMS) written in PHP. It provides themes, plugins, and an admin interface so non-developers can build and maintain blogs or full websites. When installed, it is a 

- install Wordpress: https://developer.wordpress.org/advanced-administration/before-install/howto-install/

### Nginx, CGI and PHP-FPM

> Nginx is a server that listens on ports 80/443. Its aim is to listen to incoming HTTP requests that are formed by a browser when a user types the url to the server. Nginx will respond by serving static files directly. Alternatively, it may act as a reverse proxy by forwarding the PHP request to an external program to be processed, and will return the output of this program back to the client.
> 

This program executed by a server to process a request is known as **CGI** (Common Gateway Interface). Traditionally, CGI will create a new process for every incoming request. If the dynamic is generated by PHP, it will create a new PHP process for each request. However, this leads to slower server performance under high load.

This is where FastCGI is introduced, a successor to old-school CGI. The concept of fastCGI is that there are a pool of worker-processors that are ready to handle

PHP-FPM is the FastCGI Process Manager for PHP. During runtime, PHP-FPM keeps a pool of worker processes ready to handle requests forwarded from a web server like Nginx. [Read about configuring nginx fastCGI](/srcs/https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)

CGI and FastCGI are both server-side protocols, meaning they are simply a set of standardized instructions that tell Nginx, and any other web server how it should execute and utilize CGI, while PHP-FPM is an implementation of FastCGI. 

## Dockerized WordPress Architecture Overview

The high-level overview of how my containers connect to each other, to ultimately deliver WordPress pages to the user as is required by this project:

![image.png](/srcs/image%202.png)

- Nginx — a webserver — is listening on 443, and awaiting any incoming connections. Nginx’s aim is to connect to clients, and deliver requested web pages to them to be viewed in the browser.
- When accessing a url like `https://shechong.42.fr` or `https://domain.42.fr`, it will be wrapped in http request format, and accessing specifically using `https://` means the request is sent to port `443` (Port 443 is the default gateway for HTTPS).
- Nginx which was listening on 443 receives the request, and is ready to establish a connection. It receives the request from the user.
- Nginx may do internal processing to deliver a web page back to the user, or forward it to a service like php-fpm, if the request uri requires further processing. In my project structure, my service - php-fpm resides in another container, meaning it is essential to connect these containers together to allow for communication.

## Dockerfiles

Container images are built using Dockerfiles. Because I have 3 containers, each container needs its own Docker File. 

> A Dockerfile is a plain-text recipe of instructions that tells Docker how to build a container image. These instructions include:
> 
> - `FROM` to specify the base image to build from (e.g., `FROM ubuntu:22.04`). Docker will pull a preexisting image from Docker Hub that matches the requested image.
> - `RUN` to execute shell commands to install any necessary packages or perform setup for a container (e.g., `RUN apt-get update && apt-get install -y nginx`).
> - `COPY` or `ADD` to place any code on the host machine into the image (e.g., `COPY . /var/www/html`).
> - `WORKDIR` to set the default directory for subsequent commands
> - `ENV` to define environment variables
> - `EXPOSE` to declare which ports this image, when ran as a container will listen on
> - `CMD` or `ENTRYPOINT` to declare the default process that runs when a container starts

Docker Files are instructions to build images, and from these images we may create containers, which are individual running instances of the image.

![image.png](/srcs/image%203.png)

## Docker Compose

When building and starting up multiple containers, managing multiple Dockerfiles can become a headache when done manually. You often need to

- Start containers in a specific order if one container depends on another running container (WordPress depends on mariaDB to run)
- Link them together using a shared network, so containers can communicate with each other
- Run tests on containers to check whether they are up and running

Amongst many other things. Fortunately, Docker allows provides an all-in-one solution. A docker-compose.yml file is a single document that describes how to setup an entire multi-container application stack so Docker Compose can start all containers up by simply calling `docker compose up` . 

Instead of building and starting each container manually, you…

- List every service/container to be created (web server like Nginx, database like MariaDB, cache, etc.), and within each service, list:
    - the image or Dockerfile to use,
    - environment variables,
    - port mappings
    - volume mounts
    - networks they belong to
    - other containers they depend on

Compose reads this file, builds or pulls the needed images, creates the defined networks and volumes, and starts the services in the correct order. 

<aside>
<img src="https://www.notion.so/icons/push-pin_gray.svg" alt="https://www.notion.so/icons/push-pin_gray.svg" width="40px" />

- An example of what a `docker-compose.yml` file looks like
    
    ```yaml
    services:
      db:
        image: mariadb:10.11
        restart: unless-stopped
        environment:
          MARIADB_ROOT_PASSWORD: rootpass
          MARIADB_DATABASE: wordpress
        volumes:
          - db_data:/var/lib/mysql
    
      wordpress:
        image: wordpress:6-php-fpm
        restart: unless-stopped
        environment:
          WORDPRESS_DB_HOST: db
          WORDPRESS_DB_NAME: wordpress
          WORDPRESS_DB_USER: wpuser
          WORDPRESS_DB_PASSWORD: wppass
        volumes:
          - wp_data:/var/www/html
    
      nginx:
        image: nginx:alpine
        restart: unless-stopped
        ports:
          - "80:80"
        volumes:
          - wp_data:/var/www/html:ro
          - ./nginx.conf:/etc/nginx/nginx.conf:ro
        depends_on:
          - wordpress
    
    volumes:
      db_data:
      wp_data:
    ```
    
</aside>

Utilizing the Docker compose file, I am able to connect my containers together by making them share the same network Docker Network, and utilize volumes to allow data within containers to persistently store data on the host machine, even after container sessions have been closed or rebooted.

![image.png](/srcs/image%204.png)

---

# What my server supports

This section aims to explain in detail the capabilities and specifications of this server. These are based on 42’s requirements for the Inception project.

## ⚙️ Configurable settings

The `.env` file contains several configurable key value parameters to specify how the server should initialize. These values are substituted into other files during the startup process . Refer to `env.template` to see the parameters that have to be filled.

## 👤 USERS

My server, upon startup has two users, 

- one being the admin (has full control of the site),
- and another an author (able to create blogposts).

Use the below command to view users in WordPress

```bash
docker exec wordpress bash -c "wp user list --allow-root"
```

In Wordpress, you may login as these users by accessing `https://shechong.42.fr/wp-login.php`.

## 🧰 SERVER DATA PERSISTENCE

Any comments, users, posts or pages created will remain when the website is accessed, despite any container shutdowns, server shutdowns, or host-machine shutdowns.

Data within a container is volatile, and can be reset if the container is re-built. Docker manages long-term, persistent data using volumes. 

Several volume types exists. For me, I am using Docker **bind mounts,** which allows the data of a container to be stored to a specified path on my host machine, rather than being managed by Docker (which is the default behavior for Docker Volumes).

- My server has two volumes, one used by MariaDB and another by WordPress. View the volumes using
    
    ```bash
    docker volume ls
    ```
    
- Of the listed volumes, you may inspect a volume, to view more details about it.
    
    ```bash
    docker volume inspect <name>
    ```
    
    With `inspect` on a volume, you can verify that it is binded to the host machine, with the following lines: 
    
    - `"o": "bind"`: the Docker volume is a direct link to a host directory, rather than a Docker-managed storage location.
    - `"device": "/home/<login name>/data/mariadb"` specifies the **host directory** that Docker will use for the volume as a **bind mount**. In other words, this is the directory indicates where the data will stored.
- To erase the website data and start clean, simply remove the `/data` directory.
- 🧪 **How to test persistent volume on my server**
    
    Comments, posts and users are stored in MariaDB volume, while color themes, uploaded files, website settings and plugins are stored in the WordPress volume. To verify that these volumes store data persistently, we should check if these aspects are preserved after a server restart. Below is an step-by-step example to test this:
    
    1. Access `https://shechong.42.fr`
    2. Access a blog page
    3. Scroll to the *comments* section, and fill in the details
    4. Click “post comment” (it will post the comment as an anonymous user)
    5. Stop the server, or call `make` again.
    6. Go back to the blog page. The comment should remain. This means that the `mariadb` volume is working successfully.

## 🔒 SECURITY

### www-data user

> **www-data user**: The `www-data` user (belonging to the `www-data` group) is the standard user that webservers run as. By default, most Linux distributions already have this user included.
> 

The permissions of this user is purposely limited so that the webserver doesn’t have too much control of the operating system. The specific limits to this user are that:

- Has a **home directory** of `/var/www`
- Has **limited filesystem permissions** — it can only read/write/execute files if:
    - The files are owned by `www-data`
    - OR the group has access and `www-data` is in that group
    - OR world (`other`) permissions allow access

To view this user, run `cat /etc/passwd | grep www-data`. You will see "`www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin`”

### Digital certificate:

> A digital certificate is an electronic document that proves the identity of a website. Only when a website is equipped with digital certificate, can it be accessed using `https` (`s` for secure).
> 

The Nginx server is equipped with the certificate to allow the website to be accessible. 

- In the Makefile, commands are used to generate the certificate.
    - `openssl req -out <output path for the newly created .csr file>`  creates the `.csr` file (certificate signing request file). This file is passed onto a certificate generation tool, for a certificate to be generated.
    - `openSSL x509 -in <.csr file>` generates the self-signed certificate by passing in the `.csr` file.
- The files generated from the Makefile are passed into In the the nginx config file — `/srcs/requirements/nginx/conf`.
    
    ```verilog
    ssl_certificate     /self_signed_certificate.pem;
    ssl_certificate_key /private.key;
    ssl_dhparam         /dhparam.pem;
    ```
    
- 🧪 **How to view the certificate on chrome:**
    1. Ensure that the server is running
    2. Access `https://shechong.42.fr` on chrome
    3. A panel of details about the certificate are shown, defined earlier in the Makefile
        
        *E.g. Common Name (CN), Organization (O), Organizational Unit (OU)*
        
    4. At the top left within the search bar, a `Not secure` indicator is present. Click on it
    5. Click on `Certificate details` 
    
    Note: My server only supports the ssl protocols `TLSv1.2` and `TLSv1.3`. You may view them in the `/srcs/requirements/nginx/conf`
    
    ```
    ssl_protocols TLSv1.2 TLSv1.3;
    ```
    

# 💟 Resilience by isolating services

This project utilizes 3 containers that are connected to each other, with each container hosting a different service. 

By isolating each service into its own container, any errors that a service encounters will be contained, and do not affect the other services. Using the `restart: always` parameter, Docker will reload any containers that encounter a crash, ensuring that the server stays alive. 

- 🧪 **Test server resilience**
    - Kill
        
        ```bash
        docker exec mariadb pkill mysqld
        ```
        
    - Kill WordPress
        
        ```bash
        docker exec wordpress pkill php-fpm7.4
        ```
        

# 🌐 Networks

Utilizing docker networks, all 3 of my servers are connected together as hosts of the the same network. 

- To view networks created for this server, run
    
    ```
    docker network ls
    ```
    
- To see what ports a container is listening to, use
    
    ```bash
    docker exec -it <container name> ss -tln
    ```
    

The networks I’m using is of type “Bridge”

> A bridge network connects containers together, but isolates them from the host machine, allowing only specified ports to be exposed. It essentially functions as a virtual switch.
> 

below is the relevant section of the `docker-compose.yml` file that establishes a networked name “inception”, of type “bridge”.

```yaml
networks:
  inception:
    name: inception
    driver: bridge
```

In contrast, using a host network (which isn’t allowed in Inception) will have the container share the network of the host machine. This means the container uses the host's IP address, and can access all network resources and ports on the host machine as if it were a process running directly on the host, eliminating the need for port mapping. This is generally less secure and has no isolation.

# ❔ Other details about this server

### Running programs as PID 1

> PID1 is the first Linux user-mode process created. All processes from this point are to be a fork of PID1. You can start any program as PID 1 using the `exec <program>` command.
> 
> 
> The responsibilities of PID 1 include the following:
> 
> - **Handling signals such as `SIGTERM`,`SIGQUIT`:**
> Because PID1 is responsible for handling signals, you’d want to ensure that the program running as PID1 has explicit handling for crucial signals, such as knowing how to shut down when `SIGTERM` is called.
> - By extension, this means another responsibility of PID1 is to reap zombie processes (child processes that finish but aren't cleaned up), especially during shut downs.
> - **Assigned control to PID1:**
> If PID 1 shuts down or crashes, the whole container shuts down.

Below are the containers that my server runs, alongside their PID1 process:

- `Nginx`: nginx
- `MariaDB`: mysqld
- `WordPress`: php-fpm7.4

Check that processes are PID1 using the following commands:

```bash
docker exec nginx cat /proc/1/status
docker exec wordpress ps -p 1 -o pid,comm
docker exec mariadb ps -p 1 -o pid,comm
```