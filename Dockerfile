FROM mongo:latest

# configure the shell before the first RUN
SHELL ["/bin/bash", "-ex", "-o", "pipefail", "-c"]

RUN mkdir -p /home/mongodb/scripts /home/mongodb/ssl

ADD scripts /home/mongodb/scripts
ADD sslcerts/mongodb.cnf /home/mongodb/ssl
ADD sslcerts/mongodb.pem /home/mongodb/ssl
ADD sslcerts/rootCA.pem /home/mongodb/ssl
ADD sslcerts/rootCA.crt /home/mongodb/ssl
ADD mongod.conf /home/mongodb
ADD .env /home/mongodb/.env

WORKDIR /home/mongodb/ssl

WORKDIR /home/mongodb

RUN chmod +x /home/mongodb/scripts/*

RUN apt-get update && apt-get install -y apt-utils curl \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN mkdir /usr/share/ca-certificates/extra
RUN cp ./ssl/rootCA.crt /usr/share/ca-certificates/extra/rootCA.crt
RUN dpkg-reconfigure -p critical ca-certificates

CMD ["/bin/bash", "/home/mongodb/scripts/run.sh"]
