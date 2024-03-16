#!/bin/bash

echo "Generating self-signed certificates..."
pushd sslcerts/
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem -config <( cat server.csr.cnf )
openssl x509 -in rootCA.pem -inform PEM -out rootCA.crt 
openssl req -new -sha256 -nodes -out server.csr -newkey rsa:2048 -keyout server.key -config <( cat server.csr.cnf )
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile v3.ext
openssl genrsa -out mongodb.key 2048
openssl req -new -key mongodb.key -out mongodb.csr -config <( cat mongodb.cnf )
openssl x509 -req -in mongodb.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out mongodb.crt -days 500 -sha256
cat mongodb.key mongodb.crt > mongodb.pem
popd
