#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

apt update

apt -y install \
    net-tools \
    mysql-server \
    python3-pip \
    python3-venv \
    pkg-config \
    default-libmysqlclient-dev \
    nginx

mkdir /home/ubuntu/myapp
cd /home/ubuntu/myapp
python3 -m venv .
source ./bin/activate
pip install \
    flask \
    flask-mysqldb \
    flask-cors

# ==================== NOVA PARTE PARA CRIAR AS TABELAS ====================

# Aguarda 15 segundos para garantir que a rede e o RDS estejam prontos para conexões
sleep 15

# Executa o conteúdo do db.sql dentro do banco RDS automaticamente
mysql -h ${db_host} -u myapp_user -p"myapp_passwd" myapp <<'EOF'
${sql_content}
EOF

# Permissões do GitHub Actions (Garante que o deploy funcione)
chown -R ubuntu:ubuntu /home/ubuntu/myapp
chown -R ubuntu:ubuntu /var/www/html

# Permissoes do Nginx   
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html;

    server_name _;

    # Rota padrão para entregar o FrontEnd (HTML/CSS/JS)
    location / {
        try_files $uri $uri/ =404;
    }

    # Proxy Reverso: Redireciona tudo que for /api/ para o Flask interno (porta 5000)
    location /api/ {
        proxy_pass http://127.0.0.1:5000/; # A barra no final é obrigatória!
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Reinicia o Nginx para ele ler a nova configuração de Proxy
systemctl restart nginx