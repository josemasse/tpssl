# Changement des permissions pour la clé privée
chmod 400 server.key

# Création du fichier de configuration de la requête de certificat
touch server.conf

# Ajout du contenu du fichier de configuration de la requête de certificat
cat > server.conf << EOL
[ req ]
default_bits = 2048
encrypt_key = yes
distinguished_name = req_dn
x509_extensions = cert_type
prompt = no
[ req_dn ]
C=FR
ST=France
L=LRY
O=iut
OU=r&t
CN=www.rt.iut
emailAddress=admin@rt.iut
[ cert_type ]
nsCertType = server
EOL

# Génération de la requête de certificat
openssl req -config server.conf -new -sha256 -key server.key > server.csr

# Création du fichier d'extensions pour le certificat
touch v3.ext

# Ajout du contenu du fichier d'extensions pour le certificat
cat > v3.ext << EOL
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = www.rt.iut
DNS.2 = localhost
EOL

# Génération du certificat
openssl x509 -req -sha256 -extfile v3.ext -in server.csr -out server.crt -CA ca.crt -CAkey ca.key -CAcreateserial -CAserial ca.srl

echo "<VirtualHost _DEFAULT_:443>
ServerName localhost:443
DocumentRoot /var/www/html
SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
#On installe les certificats et clé pour ce serveur Web
# Server Certificate:
SSLCertificateFile /etc/ssl/server.crt
# Server Private Key :
SSLCertificateKeyFile /etc/ssl/server.key
# Server Certificate Chain CA :
SSLCertificateChainFile /etc/ssl/ca.crt
</VirtualHost>" > /etc/apache2/sites-available/default-ssl.conf

# Activation du module SSL d'Apache
a2enmod ssl

# Activation du virtualhost SSL
a2ensite default-ssl

# Redémarrage du serveur Apache
systemctl restart apache2
