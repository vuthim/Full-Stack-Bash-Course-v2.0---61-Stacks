# 🔒 STACK 52: SSL/TLS CERTIFICATES

## Generate Self-Signed Cert
```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```

## Let's Encrypt (Certbot)
```bash
apt install certbot python3-certbot-nginx
certbot --nginx -d example.com -d www.example.com
# Auto-renewal
certbot renew --dry-run
```

## OpenSSL Commands
```bash
# View certificate
openssl x509 -in cert.pem -text -noout

# Check expiry
openssl x509 -in cert.pem -dates -noout

# Convert formats
openssl x509 -in cert.cer -inform DER -outform PEM -out cert.pem
```

## ✅ Stack 52 Complete!