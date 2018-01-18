FROM alpine:latest
LABEL maintainer georgegeorgulas@gmail.com

RUN \
                                apk update && \
                               apk upgrade && \
          apk add --update bash curl dcron && \
                     rm -rf /var/cache/apk/*

COPY \
                  crontab.txt /crontab.txt

COPY \
               DNS-Anchor-georgulas-com.sh /DNS-Anchor-georgulas-com.sh

COPY \
                                  entry.sh /entry.sh

RUN \
    chmod 755 /DNS-Anchor-georgulas-com.sh /entry.sh && \
             /usr/bin/crontab /crontab.txt

CMD ["/entry.sh"]
