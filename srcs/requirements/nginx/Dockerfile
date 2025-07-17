FROM debian:latest

# Update package list and install nginx
RUN apt update && apt upgrade -y && apt install -y nginx

# Create necessary directories
RUN mkdir -p /var/www/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy index.html
COPY index.html /var/www/html/index.html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"] 





