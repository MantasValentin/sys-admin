# Generating an RSA Private Key:
openssl genrsa -out private.key 2048

# Creating a Certificate Signing Request (CSR) with the private key:
openssl req -new -key private.key -out request.csr

# Signing the CSR with your CA:
openssl x509 -req -in request.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out signed_cert.crt -days 365



#!/bin/bash

# Step 1: Create Root CA

# Generate root CA private key
openssl genrsa -aes256 -out root-ca.key 4096

# Generate root CA certificate
openssl req -x509 -new -nodes -key root-ca.key -sha256 -days 3650 -out root-ca.crt

# Step 2: Create Intermediate CA

# Generate intermediate CA private key
openssl genrsa -aes256 -out intermediate-ca.key 4096

# Generate intermediate CA CSR
openssl req -new -key intermediate-ca.key -out intermediate-ca.csr

# Sign intermediate CA certificate with root CA
openssl x509 -req -in intermediate-ca.csr -CA root-ca.crt -CAkey root-ca.key -CAcreateserial -out intermediate-ca.crt -days 1825 -sha256

# Step 3: Create Server Certificate

# Generate server private key
openssl genrsa -out server.key 2048

# Generate server CSR
openssl req -new -key server.key -out server.csr

# Sign server certificate with intermediate CA
openssl x509 -req -in server.csr -CA intermediate-ca.crt -CAkey intermediate-ca.key -CAcreateserial -out server.crt -days 365 -sha256

# Create certificate chain file
cat server.crt intermediate-ca.crt > server-chain.crt

echo "CA setup and certificate generation complete."