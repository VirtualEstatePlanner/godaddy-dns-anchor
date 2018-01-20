FROM alpine:latest
LABEL maintainer georgegeorgulas@gmail.com

RUN \
# prepare apk
                                  apk update && \
                                 apk upgrade && \
# install packages
            apk add --update bash curl dcron && \
# clean up ask for smaller layer size
                     rm -rf /var/cache/apk/*

# Declare GoDaddy API environment variables as secrets for env_secret_expand command
ENV $GODADDY_API_KEY="DOCKER-SECRET->GODADDY_API_KEY"
ENV $GODADDY_API_SECRET="DOCKER-SECRET->GODADDY_API_SECRET"



# add crontab file
COPY \
                                 crontab.txt /crontab.txt

# add scripts
COPY \
                       env_secrets_expand.sh /env_secrets_expand.sh

COPY \
                       godaddy-dns-anchor.sh /godaddy-dns-anchor.sh

COPY \
                                    entry.sh /entry.sh

RUN \
# make scripts executable
            chmod 755 /godaddy-dns-anchor.sh && \
                                   /entry.sh && \
                       env_secrets_expand.sh && \

# load crontab file into crontab
                            /usr/bin/crontab /crontab.txt

ENTRYPOINT ["/entry.sh"]
