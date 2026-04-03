# Issue #3: Implementar Modelos Eloquent

**Epic:** Backend Core & Database  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 1

---

## Descripción

Crear todos los modelos Eloquent con sus relaciones, scopes, traits y métodos auxiliares para interactuar eficientemente con la base de datos.

## Objetivos

- Crear 10+ modelos Eloquent
- Implementar trait `BelongsToTenant` para multi-tenancy
- Crear Global Scope `TenantScope`
- Definir todas las relaciones entre modelos
- Crear factories para testing

## Tareas Técnicas

### 1. Crear Trait BelongsToTenant

**Archivo:** `app/Models/Traits/BelongsToTenant.php`

```php
<?php

namespace App\Models\Traits;

use App\Models\Scopes\TenantScope;

trait BelongsToTenant
{
    protected static function bootBelongsToTenant()
    {
        static::addGlobalScope(new TenantScope);
        
        static::creating(function ($model) {
            if (!$model->comercio_id && $tenantId = config('app.tenant_id')) {
                $model->comercio_id = $tenantId;
            }
        });
    }
    
    public function comercio()
    {
        return $this->belongsTo(\App\Models\Comercio::class);
    }
}
```

### 2. Crear Global Scope TenantScope

**Archivo:** `app/Models/Scopes/TenantScope.php`

```php
<?php

namespace App\Models\Scopes;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Scope;

class TenantScope implements Scope
{
    public function apply(Builder $builder, Model $model)
    {
        if ($tenantId = config('app.tenant_id')) {
            $builder->where($model->getTable() . '.comercio_id', $tenantId);
        }
    }
}
```

### 3. Modelo User

```bash
php artisan make:model User
```

```php
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'name', 'email', 'phone', 'password', 'role', 
        'comercio_id', 'fcm_token', 'avatar_url'
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'phone_verified_at' => 'datetime',
        'last_login_at' => 'datetime',
        'is_active' => 'boolean',
        'password' => 'hashed',
    ];

    // Relaciones
    public function comercio()
    {
        return $this->belongsTo(Comercio::class);
    }

    public function repartidor()
    {
        return $this->hasOne(Repartidor::class);
    }

    public function pedidos()
    {
        return $this->hasMany(Pedido::class, 'cliente_id');
    }

    public function direcciones()
    {
        return $this->hasMany(Direccion::class);
    }

    public function notificaciones()
    {
        return $this->hasMany(Notificacion::class);
    }

    // Scopes
    public function scopeByRole($query, $role)
    {
        return $query->where('role', $role);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    // Métodos
    public function isCliente()
    {
        return $this->role === 'cliente';
    }

    public function isComercio()
    {
        return $this->role === 'comercio';
    }

    public function isRepartidor()
    {
        return $this->role === 'repartidor';
    }
}
```

### 4. Modelo Comercio

```bash
php artisan make:model Comercio
```

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Comercio extends Model
{
    protected $fillable = [
        'slug', 'nombre', 'descripcion', 'categoria',
        'branding_json', 'logo_url', 'banner_url',
        'lat', 'lng', 'direccion', 'ciudad', 'estado',
        'telefono', 'email', 'whatsapp',
        'horarios_json', 'radio_entrega_km', 'tiempo_preparacion_min',
        'delivery_fee_usd', 'delivery_fee_bs',
        'pedido_minimo_usd', 'pedido_minimo_bs',
        'acepta_efectivo', 'acepta_pago_movil', 'acepta_transferencia', 'acepta_tarjeta',
        'is_active', 'is_open'
    ];

    protected $casts = [
        'branding_json' => 'array',
        'horarios_json' => 'array',
        'lat' => 'decimal:8',
        'lng' => 'decimal:8',
        'is_active' => 'boolean',
        'is_open' => 'boolean',
        'acepta_efectivo' => 'boolean',
        'acepta_pago_movil' => 'boolean',
        'acepta_transferencia' => 'boolean',
        'acepta_tarjeta' => 'boolean',
    ];

    // Relaciones
    public function productos()
    {
        return $this->hasMany(Producto::class);
    }

    public function categorias()
    {
        return $this->hasMany(Categoria::class);
    }

    public function pedidos()
    {
        return $this->hasMany(Pedido::class);
    }

    public function repartidores()
    {
        return $this->belongsToMany(Repartidor::class, 'comercio_repartidor')
                    ->withPivot('comision_porcentaje', 'prioridad', 'is_active')
                    ->withTimestamps();
    }

    public function users()
    {
        return $this->hasMany(User::class);
    }

    // Métodos
    public function isOpen()
    {
        return $this->is_open && $this->is_active;
    }

    public function getDistanceTo($lat, $lng)
    {
        // Fórmula Haversine
        $earthRadius = 6371; // km
        $dLat = deg2rad($lat - $this->lat);
        $dLng = deg2rad($lng - $this->lng);
        
        $a = sin($dLat/2) * sin($dLat/2) +
             cos(deg2rad($this->lat)) * cos(deg2rad($lat)) *
             sin($dLng/2) * sin($dLng/2);
        
        $c = 2 * atan2(sqrt($a), sqrt(1-$a));
        
        return $earthRadius * $c;
    }

    public function canDeliver($lat, $lng)
    {
        $distance = $this->getDistanceTo($lat, $lng);
        return $distance <= $this->radio_entrega_km;
    }
}
```

### 5. Modelo Producto

```bash
php artisan make:model Producto
```

```php
<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Model;

class Producto extends Model
{
    use BelongsToTenant;

    protected $fillable = [
        'comercio_id', 'categoria_id', 'nombre', 'descripcion', 'imagen_url',
        'precio_usd', 'precio_bs', 'precio_oferta_usd', 'precio_oferta_bs',
        'stock', 'stock_ilimitado', 'stock_minimo',
        'tiene_variantes', 'variantes_json',
        'is_active', 'is_destacado',
        'disponible_desde', 'disponible_hasta'
    ];

    protected $casts = [
        'variantes_json' => 'array',
        'is_active' => 'boolean',
        'is_destacado' => 'boolean',
        'stock_ilimitado' => 'boolean',
        'tiene_variantes' => 'boolean',
    ];

    // Relaciones
    public function categoria()
    {
        return $this->belongsTo(Categoria::class);
    }

    public function pedidoItems()
    {
        return $this->hasMany(PedidoItem::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeDestacados($query)
    {
        return $query->where('is_destacado', true);
    }

    public function scopeConStock($query)
    {
        return $query->where(function($q) {
            $q->where('stock_ilimitado', true)
              ->orWhere('stock', '>', 0);
        });
    }

    // Métodos
    public function hasStock($cantidad = 1)
    {
        return $this->stock_ilimitado || $this->stock >= $cantidad;
    }

    public function decrementStock($cantidad)
    {
        if (!$this->stock_ilimitado) {
            $this->decrement('stock', $cantidad);
        }
    }

    public function getPrecioFinal($moneda = 'usd')
    {
        $campo = $moneda === 'usd' ? 'precio_usd' : 'precio_bs';
        $campoOferta = $moneda === 'usd' ? 'precio_oferta_usd' : 'precio_oferta_bs';
        
        return $this->$campoOferta ?? $this->$campo;
    }
}
```

### 6. Modelo Categoria

```bash
php artisan make:model Categoria
```

```php
<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Model;

class Categoria extends Model
{
    use BelongsToTenant;

    protected $fillable = [
        'comercio_id', 'nombre', 'descripcion', 'icono', 'orden', 'is_active'
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function productos()
    {
        return $this->hasMany(Producto::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeOrdenado($query)
    {
        return $query->orderBy('orden');
    }
}
```

### 7. Modelo Repartidor

```bash
php artisan make:model Repartidor
```

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Repartidor extends Model
{
    protected $table = 'repartidores';

    protected $fillable = [
        'user_id', 'is_freelance',
        'current_lat', 'current_lng', 'last_location_update',
        'status', 'vehiculo_tipo', 'placa_vehiculo', 'color_vehiculo',
        'cedula', 'licencia_conducir',
        'radio_trabajo_km', 'acepta_pedidos', 'is_active'
    ];

    protected $casts = [
        'is_freelance' => 'boolean',
        'is_active' => 'boolean',
        'acepta_pedidos' => 'boolean',
        'last_location_update' => 'datetime',
    ];

    // Relaciones
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function comercios()
    {
        return $this->belongsToMany(Comercio::class, 'comercio_repartidor')
                    ->withPivot('comision_porcentaje', 'prioridad', 'is_active')
                    ->withTimestamps();
    }

    public function pedidos()
    {
        return $this->hasMany(Pedido::class);
    }

    public function ubicaciones()
    {
        return $this->hasMany(RepartidorUbicacion::class);
    }

    // Scopes
    public function scopeDisponibles($query)
    {
        return $query->where('status', 'disponible')
                     ->where('acepta_pedidos', true)
                     ->where('is_active', true);
    }

    public function scopeFreelance($query)
    {
        return $query->where('is_freelance', true);
    }

    public function scopeCercanos($query, $lat, $lng, $radio = 3)
    {
        // Fórmula Haversine en SQL
        return $query->whereRaw("
            (6371 * acos(
                cos(radians(?)) * cos(radians(current_lat)) *
                cos(radians(current_lng) - radians(?)) +
                sin(radians(?)) * sin(radians(current_lat))
            )) <= ?
        ", [$lat, $lng, $lat, $radio]);
    }

    // Métodos
    public function updateLocation($lat, $lng, $pedidoId = null)
    {
        $this->update([
            'current_lat' => $lat,
            'current_lng' => $lng,
            'last_location_update' => now()
        ]);

        RepartidorUbicacion::create([
            'repartidor_id' => $this->id,
            'pedido_id' => $pedidoId,
            'lat' => $lat,
            'lng' => $lng
        ]);
    }

    public function isAvailable()
    {
        return $this->status === 'disponible' && 
               $this->acepta_pedidos && 
               $this->is_active;
    }
}
```

### 8. Modelo Pedido

```bash
php artisan make:model Pedido
```

```php
<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Pedido extends Model
{
    use BelongsToTenant;

    protected $fillable = [
        'comercio_id', 'cliente_id', 'repartidor_id',
        'numero_pedido', 'token_seguimiento', 'estado',
        'subtotal_usd', 'subtotal_bs',
        'delivery_fee_usd', 'delivery_fee_bs',
        'descuento_usd', 'descuento_bs',
        'total_usd', 'total_bs',
        'tipo_pago', 'vuelto_de', 'pago_movil_json', 'comprobante_url', 'pago_verificado',
        'direccion_json', 'tiempo_estimado_minutos',
        'notas_cliente', 'notas_comercio', 'razon_cancelacion',
        'rating_comercio', 'rating_repartidor', 'comentario_rating'
    ];

    protected $casts = [
        'pago_movil_json' => 'array',
        'direccion_json' => 'array',
        'pago_verificado' => 'boolean',
        'fecha_confirmacion' => 'datetime',
        'fecha_listo' => 'datetime',
        'fecha_en_camino' => 'datetime',
        'fecha_entregado' => 'datetime',
        'fecha_cancelado' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($pedido) {
            $pedido->numero_pedido = self::generarNumeroPedido();
            $pedido->token_seguimiento = Str::random(64);
        });
    }

    // Relaciones
    public function cliente()
    {
        return $this->belongsTo(User::class, 'cliente_id');
    }

    public function repartidor()
    {
        return $this->belongsTo(Repartidor::class);
    }

    public function items()
    {
        return $this->hasMany(PedidoItem::class);
    }

    public function estados()
    {
        return $this->hasMany(PedidoEstado::class);
    }

    // Métodos
    public static function generarNumeroPedido()
    {
        $fecha = now()->format('Ymd');
        $ultimo = self::whereDate('created_at', today())->count() + 1;
        return sprintf('IZY-%s-%04d', $fecha, $ultimo);
    }

    public function calcularTotal()
    {
        $this->total_usd = $this->subtotal_usd + $this->delivery_fee_usd - $this->descuento_usd;
        $this->total_bs = $this->subtotal_bs + $this->delivery_fee_bs - $this->descuento_bs;
    }

    public function cambiarEstado($nuevoEstado, $userId = null, $notas = null)
    {
        $estadoAnterior = $this->estado;
        $this->estado = $nuevoEstado;
        $this->save();

        PedidoEstado::create([
            'pedido_id' => $this->id,
            'estado_anterior' => $estadoAnterior,
            'estado_nuevo' => $nuevoEstado,
            'user_id' => $userId,
            'notas' => $notas
        ]);
    }
}
```

### 9. Modelos Restantes (Simplificados)

```bash
php artisan make:model PedidoItem
php artisan make:model PedidoEstado
php artisan make:model Direccion
php artisan make:model RepartidorUbicacion
php artisan make:model Notificacion
php artisan make:model Configuracion
```

### 10. Crear Factories

```bash
php artisan make:factory ComercioFactory
php artisan make:factory ProductoFactory
php artisan make:factory UserFactory
php artisan make:factory RepartidorFactory
```

## Definición de Hecho (DoD)

- [ ] Todos los modelos creados con fillable y casts
- [ ] Trait `BelongsToTenant` implementado
- [ ] Global Scope `TenantScope` funcionando
- [ ] Todas las relaciones definidas
- [ ] Métodos auxiliares implementados
- [ ] Factories creados para testing
- [ ] Tests unitarios básicos pasando

## Comandos de Verificación

```bash
# Tinker para probar modelos
php artisan tinker

# Probar creación
>>> $comercio = Comercio::create(['nombre' => 'Test', 'slug' => 'test', ...]);
>>> $producto = Producto::create(['nombre' => 'Pizza', ...]);

# Probar relaciones
>>> $comercio->productos;
>>> $producto->comercio;

# Probar scopes
>>> Producto::active()->get();
>>> Repartidor::disponibles()->get();
```

## Dependencias

- Issue #2: Crear Esquema de Base de Datos

## Siguiente Issue

Issue #4: Sistema de Autenticación con Sanctum
