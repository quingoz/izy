# 🗄️ ESQUEMA DE BASE DE DATOS - IZY

## 1. DIAGRAMA ENTIDAD-RELACIÓN COMPLETO

```
                    ┌─────────────────┐
                    │    comercios    │
                    ├─────────────────┤
                    │ id (PK)         │
                    │ slug (UQ)       │
                    │ nombre          │
                    │ branding_json   │
                    │ lat, lng        │
                    │ is_active       │
                    └────────┬────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
         ┌──────▼──────┐     │     ┌──────▼──────────┐
         │  productos  │     │     │comercio_repartidor│
         ├─────────────┤     │     ├─────────────────┤
         │ id (PK)     │     │     │ comercio_id (FK)│
         │comercio_id  │     │     │repartidor_id(FK)│
         │ nombre      │     │     └─────────────────┘
         │ precio_usd  │     │
         │ precio_bs   │     │
         └──────┬──────┘     │
                │            │
                │            │
         ┌──────▼────────────▼──────┐
         │       pedidos            │
         ├──────────────────────────┤
         │ id (PK)                  │
         │ comercio_id (FK)         │
         │ cliente_id (FK)          │
         │ repartidor_id (FK)       │
         │ estado                   │
         │ tipo_pago                │
         │ total_usd, total_bs      │
         │ token_seguimiento (UQ)   │
         └──────┬───────────────────┘
                │
       ┌────────┼────────┐
       │        │        │
┌──────▼──────┐ │ ┌──────▼──────────┐
│pedido_items │ │ │ pedido_estados  │
├─────────────┤ │ ├─────────────────┤
│ id (PK)     │ │ │ id (PK)         │
│ pedido_id   │ │ │ pedido_id (FK)  │
│producto_id  │ │ │ estado_anterior │
│ cantidad    │ │ │ estado_nuevo    │
└─────────────┘ │ │ created_at      │
                │ └─────────────────┘
                │
         ┌──────▼──────┐
         │    users    │
         ├─────────────┤
         │ id (PK)     │
         │ name        │
         │ email (UQ)  │
         │ role        │
         │ fcm_token   │
         └──────┬──────┘
                │
                │ 1:1
                │
         ┌──────▼──────────┐
         │  repartidores   │
         ├─────────────────┤
         │ id (PK)         │
         │ user_id (FK)    │
         │ is_freelance    │
         │ current_lat     │
         │ current_lng     │
         │ status          │
         │ rating          │
         └─────────────────┘
```

---

## 2. DEFINICIÓN DE TABLAS

### 2.1 Tabla: `users`

**Descripción:** Almacena todos los usuarios del sistema (clientes, comercios, repartidores, admins)

```sql
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('cliente', 'comercio', 'repartidor', 'admin') NOT NULL DEFAULT 'cliente',
    comercio_id BIGINT UNSIGNED NULL COMMENT 'Solo para usuarios tipo comercio',
    fcm_token VARCHAR(500) NULL COMMENT 'Firebase Cloud Messaging token',
    avatar_url VARCHAR(500) NULL,
    email_verified_at TIMESTAMP NULL,
    phone_verified_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_role (role),
    INDEX idx_comercio (comercio_id),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Datos de Ejemplo:**
```sql
INSERT INTO users (name, email, phone, password, role) VALUES
('Juan Pérez', 'juan@example.com', '+58412123456', '$2y$10$...', 'cliente'),
('Pizzería Express', 'admin@pizzeria.com', '+58412234567', '$2y$10$...', 'comercio'),
('Carlos Ramos', 'carlos@example.com', '+58412345678', '$2y$10$...', 'repartidor');
```

---

### 2.2 Tabla: `comercios`

**Descripción:** Información de cada comercio/negocio en la plataforma

```sql
CREATE TABLE comercios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug VARCHAR(100) UNIQUE NOT NULL COMMENT 'URL amigable: pizzeria-express',
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    categoria ENUM('restaurante', 'farmacia', 'supermercado', 'licoreria', 'otro') DEFAULT 'restaurante',
    
    -- Branding
    branding_json JSON COMMENT '{colors: {primary, secondary}, logo_url, theme}',
    logo_url VARCHAR(500),
    banner_url VARCHAR(500),
    
    -- Ubicación
    lat DECIMAL(10, 8) NOT NULL,
    lng DECIMAL(11, 8) NOT NULL,
    direccion TEXT NOT NULL,
    ciudad VARCHAR(100),
    estado VARCHAR(100),
    
    -- Contacto
    telefono VARCHAR(20),
    email VARCHAR(255),
    whatsapp VARCHAR(20),
    
    -- Configuración
    horarios_json JSON COMMENT '{lunes: {open: "09:00", close: "22:00", closed: false}}',
    radio_entrega_km DECIMAL(5, 2) DEFAULT 5.00,
    tiempo_preparacion_min INT DEFAULT 30,
    
    -- Delivery fees
    delivery_fee_usd DECIMAL(8, 2) DEFAULT 2.00,
    delivery_fee_bs DECIMAL(10, 2) DEFAULT 0.00,
    pedido_minimo_usd DECIMAL(8, 2) DEFAULT 5.00,
    pedido_minimo_bs DECIMAL(10, 2) DEFAULT 0.00,
    
    -- Métodos de pago aceptados
    acepta_efectivo BOOLEAN DEFAULT TRUE,
    acepta_pago_movil BOOLEAN DEFAULT TRUE,
    acepta_transferencia BOOLEAN DEFAULT FALSE,
    acepta_tarjeta BOOLEAN DEFAULT FALSE,
    
    -- Estado
    is_active BOOLEAN DEFAULT TRUE,
    is_open BOOLEAN DEFAULT FALSE COMMENT 'Abierto/Cerrado en este momento',
    
    -- Estadísticas
    total_pedidos INT DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 5.00,
    total_reviews INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_slug (slug),
    INDEX idx_active (is_active),
    INDEX idx_location (lat, lng),
    INDEX idx_categoria (categoria),
    FULLTEXT idx_search (nombre, descripcion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Ejemplo de branding_json:**
```json
{
  "colors": {
    "primary": "#FF5722",
    "secondary": "#FFC107",
    "accent": "#4CAF50",
    "background": "#FFFFFF",
    "text": "#212121"
  },
  "logo_url": "https://cdn.izy.com/logos/pizzeria-express.png",
  "theme": "light",
  "fonts": {
    "heading": "Poppins",
    "body": "Roboto"
  }
}
```

**Ejemplo de horarios_json:**
```json
{
  "lunes": {"open": "09:00", "close": "22:00", "closed": false},
  "martes": {"open": "09:00", "close": "22:00", "closed": false},
  "miercoles": {"open": "09:00", "close": "22:00", "closed": false},
  "jueves": {"open": "09:00", "close": "22:00", "closed": false},
  "viernes": {"open": "09:00", "close": "23:00", "closed": false},
  "sabado": {"open": "10:00", "close": "23:00", "closed": false},
  "domingo": {"open": "10:00", "close": "20:00", "closed": false}
}
```

---

### 2.3 Tabla: `categorias`

**Descripción:** Categorías de productos dentro de cada comercio

```sql
CREATE TABLE categorias (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    comercio_id BIGINT UNSIGNED NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    icono VARCHAR(50) COMMENT 'Nombre del icono (Material Icons)',
    orden INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (comercio_id) REFERENCES comercios(id) ON DELETE CASCADE,
    INDEX idx_comercio (comercio_id),
    INDEX idx_orden (orden)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 2.4 Tabla: `productos`

**Descripción:** Productos/items del catálogo de cada comercio

```sql
CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    comercio_id BIGINT UNSIGNED NOT NULL,
    categoria_id BIGINT UNSIGNED NULL,
    
    -- Información básica
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    imagen_url VARCHAR(500),
    
    -- Precios
    precio_usd DECIMAL(10, 2) NOT NULL,
    precio_bs DECIMAL(12, 2) NOT NULL,
    precio_oferta_usd DECIMAL(10, 2) NULL,
    precio_oferta_bs DECIMAL(12, 2) NULL,
    
    -- Inventario
    stock INT DEFAULT 0,
    stock_ilimitado BOOLEAN DEFAULT FALSE,
    stock_minimo INT DEFAULT 5 COMMENT 'Alerta de stock bajo',
    
    -- Variantes (tamaños, extras, etc.)
    tiene_variantes BOOLEAN DEFAULT FALSE,
    variantes_json JSON COMMENT '[{name: "Tamaño", required: true, options: [{label: "S", price_usd: 0}]}]',
    
    -- Disponibilidad
    is_active BOOLEAN DEFAULT TRUE,
    is_destacado BOOLEAN DEFAULT FALSE,
    disponible_desde TIME NULL,
    disponible_hasta TIME NULL,
    
    -- Estadísticas
    total_ventas INT DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 5.00,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (comercio_id) REFERENCES comercios(id) ON DELETE CASCADE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
    INDEX idx_comercio (comercio_id),
    INDEX idx_categoria (categoria_id),
    INDEX idx_active (is_active),
    INDEX idx_destacado (is_destacado),
    FULLTEXT idx_search (nombre, descripcion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Ejemplo de variantes_json:**
```json
[
  {
    "name": "Tamaño",
    "required": true,
    "multiple": false,
    "options": [
      {"label": "Personal", "price_usd": 0, "price_bs": 0},
      {"label": "Mediana", "price_usd": 3, "price_bs": 100},
      {"label": "Familiar", "price_usd": 6, "price_bs": 200}
    ]
  },
  {
    "name": "Extras",
    "required": false,
    "multiple": true,
    "options": [
      {"label": "Queso extra", "price_usd": 1, "price_bs": 35},
      {"label": "Tocineta", "price_usd": 1.5, "price_bs": 50},
      {"label": "Champiñones", "price_usd": 0.75, "price_bs": 25}
    ]
  }
]
```

---

### 2.5 Tabla: `repartidores`

**Descripción:** Información de repartidores (exclusivos y freelance)

```sql
CREATE TABLE repartidores (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    
    -- Tipo
    is_freelance BOOLEAN DEFAULT FALSE,
    
    -- Ubicación actual
    current_lat DECIMAL(10, 8) NULL,
    current_lng DECIMAL(11, 8) NULL,
    last_location_update TIMESTAMP NULL,
    
    -- Estado
    status ENUM('disponible', 'ocupado', 'offline') DEFAULT 'offline',
    
    -- Vehículo
    vehiculo_tipo ENUM('moto', 'bicicleta', 'auto', 'pie') DEFAULT 'moto',
    placa_vehiculo VARCHAR(20),
    color_vehiculo VARCHAR(50),
    
    -- Documentación
    cedula VARCHAR(20),
    licencia_conducir VARCHAR(50),
    foto_cedula_url VARCHAR(500),
    foto_licencia_url VARCHAR(500),
    
    -- Estadísticas
    rating DECIMAL(3, 2) DEFAULT 5.00,
    total_entregas INT DEFAULT 0,
    total_rechazos INT DEFAULT 0,
    entregas_completadas_hoy INT DEFAULT 0,
    
    -- Ganancias
    ganancias_hoy_usd DECIMAL(10, 2) DEFAULT 0.00,
    ganancias_semana_usd DECIMAL(10, 2) DEFAULT 0.00,
    ganancias_mes_usd DECIMAL(10, 2) DEFAULT 0.00,
    
    -- Configuración
    radio_trabajo_km DECIMAL(5, 2) DEFAULT 3.00,
    acepta_pedidos BOOLEAN DEFAULT TRUE,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_freelance (is_freelance),
    INDEX idx_location (current_lat, current_lng),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 2.6 Tabla: `comercio_repartidor`

**Descripción:** Relación N:M entre comercios y repartidores exclusivos

```sql
CREATE TABLE comercio_repartidor (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    comercio_id BIGINT UNSIGNED NOT NULL,
    repartidor_id BIGINT UNSIGNED NOT NULL,
    
    -- Configuración
    comision_porcentaje DECIMAL(5, 2) DEFAULT 10.00 COMMENT 'Comisión del repartidor',
    prioridad INT DEFAULT 1 COMMENT 'Prioridad de asignación (1 = más alta)',
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (comercio_id) REFERENCES comercios(id) ON DELETE CASCADE,
    FOREIGN KEY (repartidor_id) REFERENCES repartidores(id) ON DELETE CASCADE,
    UNIQUE KEY unique_comercio_repartidor (comercio_id, repartidor_id),
    INDEX idx_comercio (comercio_id),
    INDEX idx_repartidor (repartidor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 2.7 Tabla: `direcciones`

**Descripción:** Direcciones guardadas de los clientes

```sql
CREATE TABLE direcciones (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    
    alias VARCHAR(100) COMMENT 'Casa, Oficina, etc.',
    calle TEXT NOT NULL,
    ciudad VARCHAR(100),
    estado VARCHAR(100),
    codigo_postal VARCHAR(20),
    referencia TEXT COMMENT 'Casa azul, al lado del banco, etc.',
    
    lat DECIMAL(10, 8) NOT NULL,
    lng DECIMAL(11, 8) NOT NULL,
    
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_location (lat, lng)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 2.8 Tabla: `pedidos`

**Descripción:** Pedidos realizados por clientes

```sql
CREATE TABLE pedidos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    comercio_id BIGINT UNSIGNED NOT NULL,
    cliente_id BIGINT UNSIGNED NOT NULL,
    repartidor_id BIGINT UNSIGNED NULL,
    
    -- Identificación
    numero_pedido VARCHAR(20) UNIQUE NOT NULL COMMENT 'IZY-20260331-0001',
    token_seguimiento VARCHAR(64) UNIQUE NOT NULL COMMENT 'Token público para tracking',
    
    -- Estado
    estado ENUM(
        'pendiente',
        'confirmado',
        'preparando',
        'listo',
        'en_camino',
        'entregado',
        'cancelado'
    ) DEFAULT 'pendiente',
    
    -- Montos
    subtotal_usd DECIMAL(10, 2) NOT NULL,
    subtotal_bs DECIMAL(12, 2) NOT NULL,
    delivery_fee_usd DECIMAL(8, 2) DEFAULT 0.00,
    delivery_fee_bs DECIMAL(10, 2) DEFAULT 0.00,
    descuento_usd DECIMAL(8, 2) DEFAULT 0.00,
    descuento_bs DECIMAL(10, 2) DEFAULT 0.00,
    total_usd DECIMAL(10, 2) NOT NULL,
    total_bs DECIMAL(12, 2) NOT NULL,
    
    -- Pago
    tipo_pago ENUM('efectivo', 'pago_movil', 'transferencia', 'tarjeta') NOT NULL,
    vuelto_de DECIMAL(12, 2) NULL COMMENT 'Para pagos en efectivo',
    pago_movil_json JSON COMMENT '{banco, telefono, referencia, monto, fecha}',
    comprobante_url VARCHAR(500) COMMENT 'URL del comprobante de pago',
    pago_verificado BOOLEAN DEFAULT FALSE,
    
    -- Dirección de entrega
    direccion_json JSON NOT NULL COMMENT '{calle, ciudad, referencia, lat, lng}',
    
    -- Tiempos
    tiempo_estimado_minutos INT DEFAULT 30,
    fecha_confirmacion TIMESTAMP NULL,
    fecha_listo TIMESTAMP NULL,
    fecha_en_camino TIMESTAMP NULL,
    fecha_entregado TIMESTAMP NULL,
    fecha_cancelado TIMESTAMP NULL,
    
    -- Notas
    notas_cliente TEXT,
    notas_comercio TEXT,
    razon_cancelacion TEXT,
    
    -- Calificación
    rating_comercio DECIMAL(3, 2) NULL,
    rating_repartidor DECIMAL(3, 2) NULL,
    comentario_rating TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (comercio_id) REFERENCES comercios(id),
    FOREIGN KEY (cliente_id) REFERENCES users(id),
    FOREIGN KEY (repartidor_id) REFERENCES repartidores(id) ON DELETE SET NULL,
    INDEX idx_comercio (comercio_id),
    INDEX idx_cliente (cliente_id),
    INDEX idx_repartidor (repartidor_id),
    INDEX idx_estado (estado),
    INDEX idx_token (token_seguimiento),
    INDEX idx_numero (numero_pedido),
    INDEX idx_created (created_at),
    INDEX idx_tipo_pago (tipo_pago)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Ejemplo de pago_movil_json:**
```json
{
  "banco": "Banesco",
  "telefono": "04121234567",
  "referencia": "123456789",
  "monto": 350.50,
  "fecha": "2026-03-31 14:30:00"
}
```

**Ejemplo de direccion_json:**
```json
{
  "calle": "Av. Principal de Los Ruices, Edif. Torre Empresarial, Piso 5",
  "ciudad": "Caracas",
  "estado": "Miranda",
  "referencia": "Torre azul al lado del C.C. Los Ruices",
  "lat": 10.4806,
  "lng": -66.8037
}
```

---

### 2.9 Tabla: `pedido_items`

**Descripción:** Items/productos de cada pedido

```sql
CREATE TABLE pedido_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pedido_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NOT NULL,
    
    -- Snapshot del producto al momento del pedido
    nombre_producto VARCHAR(255) NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario_usd DECIMAL(10, 2) NOT NULL,
    precio_unitario_bs DECIMAL(12, 2) NOT NULL,
    subtotal_usd DECIMAL(10, 2) NOT NULL,
    subtotal_bs DECIMAL(12, 2) NOT NULL,
    
    -- Variantes seleccionadas
    variantes_json JSON COMMENT '[{name: "Tamaño", value: "Mediana", price_usd: 3}]',
    
    notas TEXT COMMENT 'Sin cebolla, extra salsa, etc.',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    INDEX idx_pedido (pedido_id),
    INDEX idx_producto (producto_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Ejemplo de variantes_json:**
```json
[
  {
    "name": "Tamaño",
    "value": "Mediana",
    "price_usd": 3.00,
    "price_bs": 100.00
  },
  {
    "name": "Extras",
    "value": ["Queso extra", "Tocineta"],
    "price_usd": 2.50,
    "price_bs": 85.00
  }
]
```

---

### 2.10 Tabla: `pedido_estados`

**Descripción:** Historial de cambios de estado de pedidos

```sql
CREATE TABLE pedido_estados (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pedido_id BIGINT UNSIGNED NOT NULL,
    
    estado_anterior VARCHAR(50) NULL,
    estado_nuevo VARCHAR(50) NOT NULL,
    
    user_id BIGINT UNSIGNED NULL COMMENT 'Quién cambió el estado',
    user_role VARCHAR(50) COMMENT 'comercio, repartidor, sistema',
    
    notas TEXT,
    metadata_json JSON COMMENT 'Datos adicionales del cambio',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_pedido (pedido_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 2.11 Tabla: `repartidor_ubicaciones`

**Descripción:** Historial de ubicaciones GPS del repartidor durante entregas

```sql
CREATE TABLE repartidor_ubicaciones (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    repartidor_id BIGINT UNSIGNED NOT NULL,
    pedido_id BIGINT UNSIGNED NULL COMMENT 'Si está en entrega activa',
    
    lat DECIMAL(10, 8) NOT NULL,
    lng DECIMAL(11, 8) NOT NULL,
    accuracy DECIMAL(6, 2) COMMENT 'Precisión en metros',
    speed DECIMAL(6, 2) COMMENT 'Velocidad en m/s',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (repartidor_id) REFERENCES repartidores(id) ON DELETE CASCADE,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE SET NULL,
    INDEX idx_repartidor (repartidor_id),
    INDEX idx_pedido (pedido_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 2.12 Tabla: `notificaciones`

**Descripción:** Registro de notificaciones enviadas

```sql
CREATE TABLE notificaciones (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    
    tipo ENUM('pedido', 'promocion', 'sistema', 'chat') NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    mensaje TEXT NOT NULL,
    
    data_json JSON COMMENT 'Datos adicionales para deep linking',
    
    leida BOOLEAN DEFAULT FALSE,
    fecha_lectura TIMESTAMP NULL,
    
    enviada_push BOOLEAN DEFAULT FALSE,
    fecha_envio_push TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_leida (leida),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 2.13 Tabla: `configuraciones`

**Descripción:** Configuraciones globales del sistema

```sql
CREATE TABLE configuraciones (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(100) UNIQUE NOT NULL,
    valor TEXT NOT NULL,
    tipo ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    descripcion TEXT,
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_clave (clave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Datos iniciales:**
```sql
INSERT INTO configuraciones (clave, valor, tipo, descripcion) VALUES
('tasa_usd_bs', '35.50', 'number', 'Tasa de cambio USD a Bs'),
('comision_plataforma_porcentaje', '10', 'number', 'Comisión de la plataforma sobre pedidos'),
('radio_busqueda_repartidores_km', '3', 'number', 'Radio para buscar repartidores freelance'),
('tiempo_aceptacion_pedido_segundos', '300', 'number', 'Tiempo para que repartidor acepte pedido'),
('mantenimiento_activo', 'false', 'boolean', 'Modo mantenimiento');
```

---

## 3. MIGRACIONES LARAVEL

### 3.1 Comando de Creación

```bash
php artisan make:migration create_users_table
php artisan make:migration create_comercios_table
php artisan make:migration create_productos_table
php artisan make:migration create_pedidos_table
# ... etc
```

### 3.2 Ejemplo de Migración

```php
// database/migrations/2026_03_31_000001_create_comercios_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('comercios', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 100)->unique();
            $table->string('nombre');
            $table->text('descripcion')->nullable();
            $table->enum('categoria', ['restaurante', 'farmacia', 'supermercado', 'licoreria', 'otro'])
                  ->default('restaurante');
            
            // Branding
            $table->json('branding_json')->nullable();
            $table->string('logo_url', 500)->nullable();
            $table->string('banner_url', 500)->nullable();
            
            // Ubicación
            $table->decimal('lat', 10, 8);
            $table->decimal('lng', 11, 8);
            $table->text('direccion');
            $table->string('ciudad', 100)->nullable();
            $table->string('estado', 100)->nullable();
            
            // Contacto
            $table->string('telefono', 20)->nullable();
            $table->string('email')->nullable();
            $table->string('whatsapp', 20)->nullable();
            
            // Configuración
            $table->json('horarios_json')->nullable();
            $table->decimal('radio_entrega_km', 5, 2)->default(5.00);
            $table->integer('tiempo_preparacion_min')->default(30);
            
            // Delivery fees
            $table->decimal('delivery_fee_usd', 8, 2)->default(2.00);
            $table->decimal('delivery_fee_bs', 10, 2)->default(0.00);
            $table->decimal('pedido_minimo_usd', 8, 2)->default(5.00);
            $table->decimal('pedido_minimo_bs', 10, 2)->default(0.00);
            
            // Métodos de pago
            $table->boolean('acepta_efectivo')->default(true);
            $table->boolean('acepta_pago_movil')->default(true);
            $table->boolean('acepta_transferencia')->default(false);
            $table->boolean('acepta_tarjeta')->default(false);
            
            // Estado
            $table->boolean('is_active')->default(true);
            $table->boolean('is_open')->default(false);
            
            // Estadísticas
            $table->integer('total_pedidos')->default(0);
            $table->decimal('rating', 3, 2)->default(5.00);
            $table->integer('total_reviews')->default(0);
            
            $table->timestamps();
            
            // Índices
            $table->index('slug');
            $table->index('is_active');
            $table->index(['lat', 'lng']);
            $table->index('categoria');
            $table->fullText(['nombre', 'descripcion']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('comercios');
    }
};
```

---

## 4. SEEDERS

### 4.1 DatabaseSeeder Principal

```php
// database/seeders/DatabaseSeeder.php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            ConfiguracionSeeder::class,
            UserSeeder::class,
            ComercioSeeder::class,
            CategoriaSeeder::class,
            ProductoSeeder::class,
            RepartidorSeeder::class,
        ]);
    }
}
```

### 4.2 Seeder de Configuraciones

```php
// database/seeders/ConfiguracionSeeder.php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ConfiguracionSeeder extends Seeder
{
    public function run(): void
    {
        $configuraciones = [
            ['clave' => 'tasa_usd_bs', 'valor' => '35.50', 'tipo' => 'number', 'descripcion' => 'Tasa de cambio USD a Bs'],
            ['clave' => 'comision_plataforma_porcentaje', 'valor' => '10', 'tipo' => 'number', 'descripcion' => 'Comisión de la plataforma'],
            ['clave' => 'radio_busqueda_repartidores_km', 'valor' => '3', 'tipo' => 'number', 'descripcion' => 'Radio de búsqueda de repartidores'],
            ['clave' => 'tiempo_aceptacion_pedido_segundos', 'valor' => '300', 'tipo' => 'number', 'descripcion' => 'Tiempo para aceptar pedido'],
            ['clave' => 'mantenimiento_activo', 'valor' => 'false', 'tipo' => 'boolean', 'descripcion' => 'Modo mantenimiento'],
        ];
        
        foreach ($configuraciones as $config) {
            DB::table('configuraciones')->updateOrInsert(
                ['clave' => $config['clave']],
                $config
            );
        }
    }
}
```

---

## 5. ÍNDICES Y OPTIMIZACIÓN

### 5.1 Índices Críticos para Performance

```sql
-- Búsqueda de comercios cercanos
CREATE INDEX idx_comercios_location ON comercios(lat, lng, is_active);

-- Búsqueda de repartidores disponibles
CREATE INDEX idx_repartidores_disponibles ON repartidores(status, current_lat, current_lng, is_freelance);

-- Pedidos por comercio y estado
CREATE INDEX idx_pedidos_comercio_estado ON pedidos(comercio_id, estado, created_at);

-- Tracking de pedidos
CREATE INDEX idx_pedidos_tracking ON pedidos(token_seguimiento, estado);

-- Productos activos por comercio
CREATE INDEX idx_productos_comercio_active ON productos(comercio_id, is_active, categoria_id);
```

### 5.2 Particionamiento (Opcional para escala)

```sql
-- Particionar tabla de ubicaciones por mes
ALTER TABLE repartidor_ubicaciones
PARTITION BY RANGE (YEAR(created_at) * 100 + MONTH(created_at)) (
    PARTITION p202603 VALUES LESS THAN (202604),
    PARTITION p202604 VALUES LESS THAN (202605),
    PARTITION p202605 VALUES LESS THAN (202606),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

---

## 6. BACKUP Y MANTENIMIENTO

### 6.1 Script de Backup

```bash
#!/bin/bash
# backup_izy.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/izy"
DB_NAME="izy_production"
DB_USER="izy_user"

# Crear backup
mysqldump -u $DB_USER -p $DB_NAME | gzip > $BACKUP_DIR/izy_$DATE.sql.gz

# Mantener solo últimos 30 días
find $BACKUP_DIR -name "izy_*.sql.gz" -mtime +30 -delete

echo "Backup completado: izy_$DATE.sql.gz"
```

### 6.2 Limpieza de Datos Antiguos

```sql
-- Eliminar ubicaciones de repartidores mayores a 30 días
DELETE FROM repartidor_ubicaciones 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Archivar pedidos entregados mayores a 90 días
-- (Mover a tabla de archivo o exportar)
```
