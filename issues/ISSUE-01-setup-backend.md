# Issue #1: Setup Inicial del Proyecto Backend

**Epic:** Backend Core & Database  
**Prioridad:** Alta  
**Estimación:** 1 día  
**Sprint:** Sprint 0

---

## Descripción

Configurar el entorno de desarrollo Laravel 11 con todas las dependencias necesarias para el proyecto IZY multi-tenant.

## Objetivos

- Instalar y configurar Laravel 11 con PHP 8.3
- Configurar MySQL/MariaDB local
- Instalar Redis para cache y queues
- Configurar Laravel Reverb para WebSockets
- Setup Laravel Sanctum para autenticación
- Configurar Laravel Telescope para debugging

## Tareas Técnicas

### 1. Instalación de Laravel
```bash
composer create-project laravel/laravel izy-backend "11.*"
cd izy-backend
php artisan --version
```

### 2. Configuración de Base de Datos
- Crear base de datos MySQL: `izy_dev`
- Configurar `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=izy_dev
DB_USERNAME=root
DB_PASSWORD=
```

### 3. Instalar Dependencias
```bash
composer require laravel/sanctum
composer require laravel/reverb
composer require laravel/telescope --dev
php artisan install:broadcasting
php artisan telescope:install
```

### 4. Configurar Redis
```env
REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
```

### 5. Configurar CORS
```bash
php artisan config:publish cors
```

Editar `config/cors.php`:
```php
'paths' => ['api/*', 'broadcasting/auth'],
'allowed_origins' => ['http://localhost:*'],
'supports_credentials' => true,
```

### 6. Estructura de Carpetas
```
app/
├── Http/
│   ├── Controllers/
│   │   ├── Auth/
│   │   ├── Cliente/
│   │   ├── Comercio/
│   │   └── Repartidor/
│   ├── Middleware/
│   │   └── IdentifyTenant.php
│   └── Requests/
├── Models/
│   ├── Scopes/
│   │   └── TenantScope.php
│   └── Traits/
│       └── BelongsToTenant.php
├── Events/
├── Jobs/
├── Policies/
└── Services/
```

### 7. Configurar Logging
```env
LOG_CHANNEL=daily
LOG_LEVEL=debug
```

## Definición de Hecho (DoD)

- [ ] `php artisan serve` ejecuta sin errores en `http://localhost:8000`
- [ ] Conexión a MySQL funcional (ejecutar `php artisan migrate:status`)
- [ ] Redis conectado (`redis-cli ping` retorna PONG)
- [ ] Telescope accesible en `/telescope`
- [ ] Sanctum instalado y publicado
- [ ] Reverb configurado
- [ ] `.env.example` actualizado con todas las variables
- [ ] Estructura de carpetas creada

## Comandos de Verificación

```bash
# Verificar instalación
php artisan about

# Verificar conexión DB
php artisan migrate:status

# Verificar Redis
redis-cli ping

# Limpiar cache
php artisan config:clear
php artisan cache:clear

# Iniciar servidor
php artisan serve
```

## Notas Importantes

- Trabajar en entorno local (XAMPP)
- PHP 8.3+ requerido
- MySQL 8.0+ o MariaDB 10.11+
- Redis debe estar ejecutándose

## Dependencias

Ninguna (primer issue)

## Siguiente Issue

Issue #2: Crear Esquema de Base de Datos
