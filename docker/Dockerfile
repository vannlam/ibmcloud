FROM ubuntu

RUN \
    apt update && \
    apt upgrade -y && \
    apt install -y apache2 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/\*

COPY start_all.sh /start_all.sh

WORKDIR /

ENTRYPOINT ["/bin/sh", "/start_all.sh"]

