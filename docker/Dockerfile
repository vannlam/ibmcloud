FROM ubuntu

RUN \
    apt update && \
    apt upgrade -y && \
    apt install -y apache2 sendmail php php-mail php-mbstring php-fpm libapache2-mod-php wget unzip && \
    apt clean
RUN \
    mkdir /etc/mail/auth && \
    chmod 700 /etc/mail/auth
RUN \
    echo 'AuthInfo:your.smtp.server "U:safeitem@lam-s.com" "P:fR8@Bj1$BMAhY1F" "M:PLAIN"' > /etc/mail/auth/client-info 
RUN \
    makemap hash /etc/mail/auth/client-info < /etc/mail/auth/client-info && \
    chmod 600 /etc/mail/auth/client-info && \
    chmod 600 /etc/mail/auth/client-info.db 
RUN \
    sed -i "s@MAILER_DEFINITIONS@define(\`SMART_HOST\',\`mail15.lwspanel.com\')dnl\ndefine(\`RELAY_MAILER_ARGS\', \`TCP $h 587\')dnl\ndefine(\`confAUTH_MECHANISMS\', \`EXTERNAL GSSAPI DIGEST-MD5 CRAM-MD5 LOGIN PLAIN\')dnl\nFEATURE(\`authinfo\',\`hash -o /etc/mail/auth/client-info.db\')dnl\nMAILER_DEFINITIONS@" /etc/mail/sendmail.mc 
RUN \
    wget https://docs.aws.amazon.com/aws-sdk-php/v3/download/aws.zip && \
    mkdir /aws && \
    unzip aws.zip -d /aws && \
    sed -i "s:Listen 80$:Listen 8080:" /etc/apache2/ports.conf && \
    sed -i "s/VirtualHost \*:80/VirtualHost *:8080/" /etc/apache2/sites-enabled/000-default.conf && \
    echo "Y Y Y" | /usr/sbin/sendmailconfig 
RUN \
    chmod +x /var/log/apache2 \
    chmod +r /var/log/apache2/error.log \
    rm -rf /aws.zip /var/lib/apt/lists/\*

COPY start_all.sh /start_all.sh
COPY version.php /var/www/html
COPY v.php /var/www/html

WORKDIR /

ENTRYPOINT ["/bin/sh", "/start_all.sh"]

