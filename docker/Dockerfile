FROM ubuntu

RUN \
    apt update && \
    apt upgrade -y && \
    apt update && \
    apt install -y apache2 && \
    apt install -y libapache2-mod-php && \
    apt install -y wget && \
    apt install -y unzip && \
    apt install -y php php-xml && \
    apt install -y php-mail && \
    echo no | apt install -y msmtp && \
    apt clean && \
    wget https://docs.aws.amazon.com/aws-sdk-php/v3/download/aws.zip && \
    mkdir /aws && \
    unzip aws.zip -d /aws && \
    sed -i "s:Listen 80$:Listen 8080:" /etc/apache2/ports.conf && \
    sed -i "s/VirtualHost \*:80/VirtualHost *:8080/" /etc/apache2/sites-enabled/000-default.conf && \
    chmod +x /var/log/apache2 && \
    chmod +r /var/log/apache2/error.log && \
    rm -rf /aws.zip /var/lib/apt/lists/\*

COPY start_all.sh /start_all.sh
COPY version.php /var/www/html
COPY v.php /var/www/html
COPY msmtprc /var/www/.msmtprc

RUN \
    chown www-data:www-data /var/www/.msmtprc && \
    chmod 600 /var/www/.msmtprc

WORKDIR /

ENTRYPOINT ["/bin/sh", "/start_all.sh"]

