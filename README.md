# godaddy-dns-anchor
Creates dynamic DNS for godaddy-registered domains using environment variables for your $GODADDY_API_KEY, $GODADDY_SECRET, $HOST, and $DOMAIN (in the format yourdomain.tld)


To use docker secrets for those values, set the value of the environent variable to /run/secrets/<secret_name>.
