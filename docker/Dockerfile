FROM ubuntu

RUN \
    apt update && \
    apt upgrade -y && \
    apt install -y apache2 php libapache2-mod-php && \
    apt clean && \
    sed -i "s:Listen 80$:Listen 8080:" /etc/apache2/ports.conf && \
    sed -i "s/VirtualHost \*:80/VirtualHost *:8080/" /etc/apache2/sites-enabled/000-default.conf && \
    rm -rf /var/lib/apt/lists/\*

COPY start_all.sh /start_all.sh
COPY version.php /var/www/html

WORKDIR /

ENTRYPOINT ["/bin/sh", "/start_all.sh"]

