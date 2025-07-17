# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name api.turrfzone.com;

    # Redirect all HTTP to HTTPS
    return 301 https://$host$request_uri;
}

# HTTPS server block
server {
    listen 443 ssl;
    server_name api.turrfzone.com;

    # SSL certs from certbot
    ssl_certificate /etc/letsencrypt/live/api.turrfzone.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.turrfzone.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    # Recommended security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    # Proxy requests to your .NET backend
    location / {
        proxy_pass http://localhost:5126;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support (if needed)
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Con    nection "upgrade";
    }
}
