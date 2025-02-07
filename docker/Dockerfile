FROM ubuntu

RUN apt update
RUN apt upgrade -y
RUN apt install -y apache2
RUN apt install -y libapache2-mod-php
RUN apt install -y php php-xml php-mbstring
RUN apt install -y php-mail
RUN echo no | apt install -y msmtp
RUN apt install -y wget unzip
RUN apt clean
RUN wget https://docs.aws.amazon.com/aws-sdk-php/v3/download/aws.zip
RUN mkdir /aws
RUN unzip aws.zip -d /aws
RUN sed -i "s:Listen 80$:Listen 8080:" /etc/apache2/ports.conf
RUN sed -i "s/VirtualHost \*:80/VirtualHost *:8080/" /etc/apache2/sites-enabled/000-default.conf
RUN sed -i 's@.*sendmail_path.*@sendmail_path = "/usr/bin/msmtp -t"@' /etc/php/8.3/apache2/php.ini
RUN chmod +x /var/log/apache2
RUN chmod +r /var/log/apache2/error.log
RUN rm -rf /aws.zip /var/lib/apt/lists/\*
RUN mkdir /var/www/html/safeitem40

COPY start_all.sh /start_all.sh
COPY version.php /var/www/html
COPY v.php /var/www/html
COPY safeitem.php /var/www/html
COPY safeitem40.php /var/www/html
COPY msmtprc /var/www/.msmtprc
COPY safeitem40/ /var/www/html/safeitem40/
COPY dojo-release-1.8.3/ /var/www/html/dojo-release-1.8.3/

RUN chown www-data:www-data /var/www/.msmtprc
RUN chmod 600 /var/www/.msmtprc

WORKDIR /

ENTRYPOINT ["/bin/sh", "/start_all.sh"]

