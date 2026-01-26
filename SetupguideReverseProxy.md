# =========================
# 1️⃣ Install Nginx
# =========================
sudo apt update
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

# =========================
# 2️⃣ Install Certbot for SSL
# =========================
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d agiledevops.nl
# Follow prompts to get HTTPS and choose to redirect HTTP → HTTPS

# =========================
# 3️⃣ Configure Nginx for WebSocket Reverse Proxy
# =========================
sudo nano /etc/nginx/sites-available/agiledevops.nl
# Replace the file with this content:

cat <<EOL | sudo tee /etc/nginx/sites-available/agiledevops.nl
server {
    listen 443 ssl http2;
    server_name agiledevops.nl;

    ssl_certificate /etc/letsencrypt/live/agiledevops.nl/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/agiledevops.nl/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location /ws/ {
        proxy_pass http://127.0.0.1:8081/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }
}

server {
    listen 80;
    server_name agiledevops.nl;
    return 301 https://\$host\$request_uri;
}
EOL

# Enable site and reload Nginx
sudo ln -sf /etc/nginx/sites-available/agiledevops.nl /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# =========================
# 4️⃣ Run Godot WebSocket Server on VPS
# =========================
# Make sure your Godot server is listening on 127.0.0.1:8081
# Example in Godot 4 GDScript:
# var web_error = webPeer.create_server(8081)
