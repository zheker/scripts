#!/bin/bash

export HOST=`hostname`
export password=`pwgen 10 1`
echo "Password is ${password}"

echo "Generating CA private key: "
openssl genrsa -aes256 -out ca-key.pem -passout pass:${password} 4096

echo "Generating CA public key:"
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem -passin pass:${password} -subj "/CN=${HOST}/O=Triangu/C=UA"

echo "Generating server key with CA:"
openssl genrsa -out server-key.pem 4096

echo "Generating server csr:"
openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr

echo subjectAltName = DNS:$HOST,IP:10.10.10.20,IP:127.0.0.1 >> extfile.cnf
echo extendedKeyUsage = serverAuth >> extfile.cnf

echo "Generating signed server certificatre:"
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf -passin pass:${password}

echo "Generating client key:"
openssl genrsa -out key.pem 4096

echo "Generating client csr"
openssl req -subj '/CN=client' -new -key key.pem -out client.csr

echo extendedKeyUsage = clientAuth >> extfile.cnf

echo "Generating client signed certificate:"
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile.cnf -passin pass:${password}

# cleanup
rm -v client.csr server.csr
chmod -v 0400 ca-key.pem key.pem server-key.pem
chmod -v 0444 ca.pem server-cert.pem cert.pem
