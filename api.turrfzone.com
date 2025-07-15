server {
    listen 80;
    server_name api.turrfzone.com;

    # Redirect all HTTP to HTTPS
    location / {
        proxy_pass http://localhost:5125;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

server {
    listen 443 ssl;
    server_name api.turrfzone.com;

    # SSL files from Let's Encrypt (Certbot will put them here)
    ssl_certificate /etc/letsencrypt/live/api.turrfzone.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.turrfzone.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://localhost:5125;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
