# Issue #2: Crear Esquema de Base de Datos

**Epic:** Backend Core & Database  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 1

---

## Descripción

Implementar todas las migraciones necesarias para el esquema de base de datos multi-tenant de IZY según la documentación en `03_DATABASE_SCHEMA.md`.

## Objetivos

- Crear 13 migraciones con todas las tablas del sistema
- Implementar relaciones foreign keys correctamente
- Crear índices para optimización de queries
- Validar que las migraciones sean reversibles

## Tareas Técnicas

### 1. Crear Migraciones Base

```bash
php artisan make:migration create_users_table
php artisan make:migration create_comercios_table
php artisan make:migration create_categorias_table
php artisan make:migration create_productos_table
php artisan make:migration create_repartidores_table
php artisan make:migration create_comercio_repartidor_table
php artisan make:migration create_direcciones_table
php artisan make:migration create_pedidos_table
php artisan make:migration create_pedido_items_table
php artisan make:migration create_pedido_estados_table
php artisan make:migration create_repartidor_ubicaciones_table
php artisan make:migration create_notificaciones_table
php artisan make:migration create_configuraciones_table
```

### 2. Migración: users

**Archivo:** `database/migrations/xxxx_create_users_table.php`

```php
Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('email')->unique();
    $table->string('phone', 20)->unique()->nullable();
    $table->string('password');
    $table->enum('role', ['cliente', 'comercio', 'repartidor', 'admin'])->default('cliente');
    $table->foreignId('comercio_id')->nullable()->constrained('comercios')->onDelete('set null');
    $table->string('fcm_token', 500)->nullable();
    $table->string('avatar_url', 500)->nullable();
    $table->timestamp('email_verified_at')->nullable();
    $table->timestamp('phone_verified_at')->nullable();
    $table->boolean('is_active')->default(true);
    $table->timestamp('last_login_at')->nullable();
    $table->rememberToken();
    $table->timestamps();
    
    $table->index('email');
    $table->index('phone');
    $table->index('role');
    $table->index('comercio_id');
    $table->index('is_active');
});
```

### 3. Migración: comercios

```php
Schema::create('comercios', function (Blueprint $table) {
    $table->id();
    $table->string('slug', 100)->unique();
    $table->string('nombre');
    $table->text('descripcion')->nullable();
    $table->enum('categoria', ['restaurante', 'farmacia', 'supermercado', 'licoreria', 'otro'])->default('restaurante');
    
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
    
    $table->index('slug');
    $table->index('is_active');
    $table->index(['lat', 'lng']);
    $table->index('categoria');
    $table->fullText(['nombre', 'descripcion']);
});
```

### 4. Migración: categorias

```php
Schema::create('categorias', function (Blueprint $table) {
    $table->id();
    $table->foreignId('comercio_id')->constrained()->onDelete('cascade');
    $table->string('nombre', 100);
    $table->text('descripcion')->nullable();
    $table->string('icono', 50)->nullable();
    $table->integer('orden')->default(0);
    $table->boolean('is_active')->default(true);
    $table->timestamps();
    
    $table->index('comercio_id');
    $table->index('orden');
});
```

### 5. Migración: productos

```php
Schema::create('productos', function (Blueprint $table) {
    $table->id();
    $table->foreignId('comercio_id')->constrained()->onDelete('cascade');
    $table->foreignId('categoria_id')->nullable()->constrained()->onDelete('set null');
    
    $table->string('nombre');
    $table->text('descripcion')->nullable();
    $table->string('imagen_url', 500)->nullable();
    
    // Precios
    $table->decimal('precio_usd', 10, 2);
    $table->decimal('precio_bs', 12, 2);
    $table->decimal('precio_oferta_usd', 10, 2)->nullable();
    $table->decimal('precio_oferta_bs', 12, 2)->nullable();
    
    // Inventario
    $table->integer('stock')->default(0);
    $table->boolean('stock_ilimitado')->default(false);
    $table->integer('stock_minimo')->default(5);
    
    // Variantes
    $table->boolean('tiene_variantes')->default(false);
    $table->json('variantes_json')->nullable();
    
    // Disponibilidad
    $table->boolean('is_active')->default(true);
    $table->boolean('is_destacado')->default(false);
    $table->time('disponible_desde')->nullable();
    $table->time('disponible_hasta')->nullable();
    
    // Estadísticas
    $table->integer('total_ventas')->default(0);
    $table->decimal('rating', 3, 2)->default(5.00);
    
    $table->timestamps();
    
    $table->index('comercio_id');
    $table->index('categoria_id');
    $table->index('is_active');
    $table->index('is_destacado');
    $table->fullText(['nombre', 'descripcion']);
});
```

### 6. Migración: repartidores

```php
Schema::create('repartidores', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
    
    $table->boolean('is_freelance')->default(false);
    
    // Ubicación actual
    $table->decimal('current_lat', 10, 8)->nullable();
    $table->decimal('current_lng', 11, 8)->nullable();
    $table->timestamp('last_location_update')->nullable();
    
    // Estado
    $table->enum('status', ['disponible', 'ocupado', 'offline'])->default('offline');
    
    // Vehículo
    $table->enum('vehiculo_tipo', ['moto', 'bicicleta', 'auto', 'pie'])->default('moto');
    $table->string('placa_vehiculo', 20)->nullable();
    $table->string('color_vehiculo', 50)->nullable();
    
    // Documentación
    $table->string('cedula', 20)->nullable();
    $table->string('licencia_conducir', 50)->nullable();
    $table->string('foto_cedula_url', 500)->nullable();
    $table->string('foto_licencia_url', 500)->nullable();
    
    // Estadísticas
    $table->decimal('rating', 3, 2)->default(5.00);
    $table->integer('total_entregas')->default(0);
    $table->integer('total_rechazos')->default(0);
    $table->integer('entregas_completadas_hoy')->default(0);
    
    // Ganancias
    $table->decimal('ganancias_hoy_usd', 10, 2)->default(0.00);
    $table->decimal('ganancias_semana_usd', 10, 2)->default(0.00);
    $table->decimal('ganancias_mes_usd', 10, 2)->default(0.00);
    
    // Configuración
    $table->decimal('radio_trabajo_km', 5, 2)->default(3.00);
    $table->boolean('acepta_pedidos')->default(true);
    
    $table->boolean('is_active')->default(true);
    $table->timestamps();
    
    $table->index('status');
    $table->index('is_freelance');
    $table->index(['current_lat', 'current_lng']);
    $table->index('is_active');
});
```

### 7. Migración: comercio_repartidor (Pivot)

```php
Schema::create('comercio_repartidor', function (Blueprint $table) {
    $table->id();
    $table->foreignId('comercio_id')->constrained()->onDelete('cascade');
    $table->foreignId('repartidor_id')->constrained()->onDelete('cascade');
    
    $table->decimal('comision_porcentaje', 5, 2)->default(10.00);
    $table->integer('prioridad')->default(1);
    
    $table->boolean('is_active')->default(true);
    $table->timestamps();
    
    $table->unique(['comercio_id', 'repartidor_id']);
    $table->index('comercio_id');
    $table->index('repartidor_id');
});
```

### 8. Migración: direcciones

```php
Schema::create('direcciones', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    
    $table->string('alias', 100)->nullable();
    $table->text('calle');
    $table->string('ciudad', 100)->nullable();
    $table->string('estado', 100)->nullable();
    $table->string('codigo_postal', 20)->nullable();
    $table->text('referencia')->nullable();
    
    $table->decimal('lat', 10, 8);
    $table->decimal('lng', 11, 8);
    
    $table->boolean('is_default')->default(false);
    $table->timestamps();
    
    $table->index('user_id');
    $table->index(['lat', 'lng']);
});
```

### 9. Migración: pedidos

```php
Schema::create('pedidos', function (Blueprint $table) {
    $table->id();
    $table->foreignId('comercio_id')->constrained();
    $table->foreignId('cliente_id')->constrained('users');
    $table->foreignId('repartidor_id')->nullable()->constrained('repartidores')->onDelete('set null');
    
    // Identificación
    $table->string('numero_pedido', 20)->unique();
    $table->string('token_seguimiento', 64)->unique();
    
    // Estado
    $table->enum('estado', [
        'pendiente', 'confirmado', 'preparando', 
        'listo', 'en_camino', 'entregado', 'cancelado'
    ])->default('pendiente');
    
    // Montos
    $table->decimal('subtotal_usd', 10, 2);
    $table->decimal('subtotal_bs', 12, 2);
    $table->decimal('delivery_fee_usd', 8, 2)->default(0.00);
    $table->decimal('delivery_fee_bs', 10, 2)->default(0.00);
    $table->decimal('descuento_usd', 8, 2)->default(0.00);
    $table->decimal('descuento_bs', 10, 2)->default(0.00);
    $table->decimal('total_usd', 10, 2);
    $table->decimal('total_bs', 12, 2);
    
    // Pago
    $table->enum('tipo_pago', ['efectivo', 'pago_movil', 'transferencia', 'tarjeta']);
    $table->decimal('vuelto_de', 12, 2)->nullable();
    $table->json('pago_movil_json')->nullable();
    $table->string('comprobante_url', 500)->nullable();
    $table->boolean('pago_verificado')->default(false);
    
    // Dirección de entrega
    $table->json('direccion_json');
    
    // Tiempos
    $table->integer('tiempo_estimado_minutos')->default(30);
    $table->timestamp('fecha_confirmacion')->nullable();
    $table->timestamp('fecha_listo')->nullable();
    $table->timestamp('fecha_en_camino')->nullable();
    $table->timestamp('fecha_entregado')->nullable();
    $table->timestamp('fecha_cancelado')->nullable();
    
    // Notas
    $table->text('notas_cliente')->nullable();
    $table->text('notas_comercio')->nullable();
    $table->text('razon_cancelacion')->nullable();
    
    // Calificación
    $table->decimal('rating_comercio', 3, 2)->nullable();
    $table->decimal('rating_repartidor', 3, 2)->nullable();
    $table->text('comentario_rating')->nullable();
    
    $table->timestamps();
    
    $table->index('comercio_id');
    $table->index('cliente_id');
    $table->index('repartidor_id');
    $table->index('estado');
    $table->index('token_seguimiento');
    $table->index('numero_pedido');
    $table->index('created_at');
    $table->index('tipo_pago');
});
```

### 10. Migración: pedido_items

```php
Schema::create('pedido_items', function (Blueprint $table) {
    $table->id();
    $table->foreignId('pedido_id')->constrained()->onDelete('cascade');
    $table->foreignId('producto_id')->constrained();
    
    $table->string('nombre_producto');
    $table->integer('cantidad');
    $table->decimal('precio_unitario_usd', 10, 2);
    $table->decimal('precio_unitario_bs', 12, 2);
    $table->decimal('subtotal_usd', 10, 2);
    $table->decimal('subtotal_bs', 12, 2);
    
    $table->json('variantes_json')->nullable();
    $table->text('notas')->nullable();
    
    $table->timestamp('created_at')->useCurrent();
    
    $table->index('pedido_id');
    $table->index('producto_id');
});
```

### 11. Migración: pedido_estados

```php
Schema::create('pedido_estados', function (Blueprint $table) {
    $table->id();
    $table->foreignId('pedido_id')->constrained()->onDelete('cascade');
    
    $table->string('estado_anterior', 50)->nullable();
    $table->string('estado_nuevo', 50);
    
    $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null');
    $table->string('user_role', 50)->nullable();
    
    $table->text('notas')->nullable();
    $table->json('metadata_json')->nullable();
    
    $table->timestamp('created_at')->useCurrent();
    
    $table->index('pedido_id');
    $table->index('created_at');
});
```

### 12. Migración: repartidor_ubicaciones

```php
Schema::create('repartidor_ubicaciones', function (Blueprint $table) {
    $table->id();
    $table->foreignId('repartidor_id')->constrained()->onDelete('cascade');
    $table->foreignId('pedido_id')->nullable()->constrained()->onDelete('set null');
    
    $table->decimal('lat', 10, 8);
    $table->decimal('lng', 11, 8);
    $table->decimal('accuracy', 6, 2)->nullable();
    $table->decimal('speed', 6, 2)->nullable();
    
    $table->timestamp('created_at')->useCurrent();
    
    $table->index('repartidor_id');
    $table->index('pedido_id');
    $table->index('created_at');
});
```

### 13. Migración: notificaciones

```php
Schema::create('notificaciones', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    
    $table->enum('tipo', ['pedido', 'promocion', 'sistema', 'chat']);
    $table->string('titulo');
    $table->text('mensaje');
    
    $table->json('data_json')->nullable();
    
    $table->boolean('leida')->default(false);
    $table->timestamp('fecha_lectura')->nullable();
    
    $table->boolean('enviada_push')->default(false);
    $table->timestamp('fecha_envio_push')->nullable();
    
    $table->timestamp('created_at')->useCurrent();
    
    $table->index('user_id');
    $table->index('leida');
    $table->index('created_at');
});
```

### 14. Migración: configuraciones

```php
Schema::create('configuraciones', function (Blueprint $table) {
    $table->id();
    $table->string('clave', 100)->unique();
    $table->text('valor');
    $table->enum('tipo', ['string', 'number', 'boolean', 'json'])->default('string');
    $table->text('descripcion')->nullable();
    
    $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();
    
    $table->index('clave');
});
```

## Definición de Hecho (DoD)

- [ ] Todas las 13 migraciones creadas
- [ ] `php artisan migrate` ejecuta sin errores
- [ ] Todas las foreign keys configuradas correctamente
- [ ] Índices creados en campos críticos
- [ ] `php artisan migrate:rollback` funciona correctamente
- [ ] Verificar estructura en MySQL con `SHOW TABLES;`
- [ ] Verificar relaciones con `SHOW CREATE TABLE pedidos;`

## Comandos de Verificación

```bash
# Ejecutar migraciones
php artisan migrate

# Ver estado
php artisan migrate:status

# Rollback
php artisan migrate:rollback

# Fresh (limpiar y recrear)
php artisan migrate:fresh

# Verificar en MySQL
mysql -u root -p izy_dev
> SHOW TABLES;
> DESCRIBE pedidos;
```

## Notas Importantes

- Respetar el orden de las migraciones (foreign keys)
- Usar tipos de datos exactos según documentación
- Todos los campos JSON deben ser nullable
- Índices en campos de búsqueda frecuente

## Dependencias

- Issue #1: Setup Inicial del Proyecto Backend

## Siguiente Issue

Issue #3: Implementar Modelos Eloquent
