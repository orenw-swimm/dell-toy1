set PATH="C:\Program Files\OpenSSL-Win64\bin\"
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout %1.key -out %1.crt -subj "/CN=%1" -days 3650
openssl pkcs12 -export -out %1.pfx -inkey %1.key -in %1.crt -certfile %1.crt -passout pass:
