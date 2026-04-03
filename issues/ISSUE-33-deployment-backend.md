# Issue #33: Deployment Backend

**Epic:** Testing & Deployment  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 5

---

## Descripción

Preparar y desplegar backend Laravel en servidor de producción con configuraciones de seguridad y performance.

## Objetivos

- Configurar servidor de producción
- Deploy con zero-downtime
- SSL/HTTPS configurado
- Supervisor para queues
- Reverb en producción
- Backups automáticos

## Tareas Técnicas

### 1. Configuración de Servidor

```bash
# Instalar dependencias
sudo apt update
sudo apt install nginx php8.3-fpm php8.3-mysql php8.3-redis php8.3-mbstring php8.3-xml php8.3-curl
sudo apt install mysql-server redis-server supervisor

# Instalar Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

### 2. Nginx Configuration

```nginx
server {
    listen 80;
    server_name api.izy.com;
    root /var/www/izy-backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

### 3. Supervisor para Queues

```ini
[program:izy-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/izy-backend/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=4
redirect_stderr=true
stdout_logfile=/var/www/izy-backend/storage/logs/worker.log
stopwaitsecs=3600
```

### 4. Supervisor para Reverb

```ini
[program:izy-reverb]
command=php /var/www/izy-backend/artisan reverb:start
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/izy-backend/storage/logs/reverb.log
```

### 5. Deploy Script

```bash
#!/bin/bash

cd /var/www/izy-backend

# Pull latest code
git pull origin main

# Install dependencies
composer install --no-dev --optimize-autoloader

# Run migrations
php artisan migrate --force

# Clear and cache config
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Restart services
sudo supervisorctl restart izy-worker:*
sudo supervisorctl restart izy-reverb
sudo systemctl reload php8.3-fpm
sudo systemctl reload nginx
```

### 6. SSL con Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.izy.com
```

### 7. Backup Automático

```bash
#!/bin/bash
# /etc/cron.daily/izy-backup

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/izy"

# Backup database
mysqldump -u root -p izy_production > $BACKUP_DIR/db_$DATE.sql

# Backup storage
tar -czf $BACKUP_DIR/storage_$DATE.tar.gz /var/www/izy-backend/storage

# Delete backups older than 7 days
find $BACKUP_DIR -type f -mtime +7 -delete
```

## Definición de Hecho (DoD)

- [ ] Servidor configurado correctamente
- [ ] SSL/HTTPS funcionando
- [ ] Queues procesándose
- [ ] Reverb en producción
- [ ] Backups automáticos
- [ ] Deploy script funcional
- [ ] Monitoreo configurado

## Comandos de Verificación

```bash
# Verificar servicios
sudo systemctl status nginx
sudo systemctl status php8.3-fpm
sudo supervisorctl status

# Verificar SSL
curl https://api.izy.com

# Test API
curl https://api.izy.com/api/health
```

## Dependencias

- Issue #32: Optimización de Performance

## Siguiente Issue

Issue #34: Deployment Frontend (PWA)
