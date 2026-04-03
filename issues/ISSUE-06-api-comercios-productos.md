# Issue #6: API de Comercios y Productos

**Epic:** Backend Core & Database  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 2

---

## Descripción

Desarrollar endpoints de API para consulta de comercios y productos con cache, filtros y búsqueda.

## Objetivos

- API de comercios (info, cercanos, branding)
- API de productos (listado, detalle, búsqueda)
- API de categorías
- Implementar cache con Redis
- Resources para transformación de datos

## Tareas Técnicas

### 1. ComercioController

**Archivo:** `app/Http/Controllers/ComercioController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Http\Resources\ComercioResource;
use App\Models\Comercio;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class ComercioController extends Controller
{
    public function show($slug)
    {
        $comercio = Cache::remember("comercio.{$slug}", 3600, function() use ($slug) {
            return Comercio::where('slug', $slug)
                ->where('is_active', true)
                ->firstOrFail();
        });

        return response()->json([
            'success' => true,
            'data' => new ComercioResource($comercio)
        ]);
    }

    public function branding($slug)
    {
        $comercio = Comercio::where('slug', $slug)
            ->where('is_active', true)
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => [
                'colors' => $comercio->branding_json['colors'] ?? [],
                'logo_url' => $comercio->logo_url,
                'theme' => $comercio->branding_json['theme'] ?? 'light',
            ]
        ]);
    }

    public function cercanos(Request $request)
    {
        $request->validate([
            'lat' => 'required|numeric|between:-90,90',
            'lng' => 'required|numeric|between:-180,180',
            'radio' => 'nullable|numeric|min:1|max:50'
        ]);

        $lat = $request->lat;
        $lng = $request->lng;
        $radio = $request->radio ?? 5;

        $comercios = Comercio::where('is_active', true)
            ->whereRaw("
                (6371 * acos(
                    cos(radians(?)) * cos(radians(lat)) *
                    cos(radians(lng) - radians(?)) +
                    sin(radians(?)) * sin(radians(lat))
                )) <= ?
            ", [$lat, $lng, $lat, $radio])
            ->get()
            ->map(function($comercio) use ($lat, $lng) {
                $comercio->distancia_km = round($comercio->getDistanceTo($lat, $lng), 2);
                $comercio->tiempo_estimado_min = $comercio->tiempo_preparacion_min + 
                    round($comercio->distancia_km * 5); // 5 min por km
                return $comercio;
            })
            ->sortBy('distancia_km')
            ->values();

        return response()->json([
            'success' => true,
            'data' => ComercioResource::collection($comercios)
        ]);
    }
}
```

### 2. ProductoController

**Archivo:** `app/Http/Controllers/ProductoController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Http\Resources\ProductoResource;
use App\Models\Comercio;
use App\Models\Producto;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class ProductoController extends Controller
{
    public function index($slug, Request $request)
    {
        $comercio = Comercio::where('slug', $slug)->firstOrFail();
        config(['app.tenant_id' => $comercio->id]);

        $cacheKey = "comercio.{$comercio->id}.productos." . md5(json_encode($request->all()));

        $productos = Cache::remember($cacheKey, 3600, function() use ($request) {
            $query = Producto::with('categoria')
                ->where('is_active', true);

            // Filtro por categoría
            if ($request->has('categoria_id')) {
                $query->where('categoria_id', $request->categoria_id);
            }

            // Búsqueda
            if ($request->has('search')) {
                $search = $request->search;
                $query->where(function($q) use ($search) {
                    $q->where('nombre', 'like', "%{$search}%")
                      ->orWhere('descripcion', 'like', "%{$search}%");
                });
            }

            // Filtro por disponibilidad
            if ($request->boolean('solo_disponibles')) {
                $query->conStock();
            }

            // Ordenamiento
            $orderBy = $request->get('order_by', 'orden');
            $orderDir = $request->get('order_dir', 'asc');
            
            if ($orderBy === 'precio') {
                $query->orderBy('precio_usd', $orderDir);
            } else {
                $query->orderBy('is_destacado', 'desc')
                      ->orderBy('nombre', 'asc');
            }

            return $query->paginate($request->get('per_page', 20));
        });

        return response()->json([
            'success' => true,
            'data' => ProductoResource::collection($productos),
            'meta' => [
                'current_page' => $productos->currentPage(),
                'total' => $productos->total(),
                'per_page' => $productos->perPage(),
                'last_page' => $productos->lastPage()
            ]
        ]);
    }

    public function show($id)
    {
        $producto = Producto::with(['categoria', 'comercio'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => new ProductoResource($producto)
        ]);
    }

    public function search(Request $request)
    {
        $request->validate([
            'q' => 'required|string|min:2',
            'comercio_id' => 'nullable|exists:comercios,id'
        ]);

        $query = Producto::with(['categoria', 'comercio'])
            ->where('is_active', true)
            ->where(function($q) use ($request) {
                $search = $request->q;
                $q->where('nombre', 'like', "%{$search}%")
                  ->orWhere('descripcion', 'like', "%{$search}%");
            });

        if ($request->has('comercio_id')) {
            config(['app.tenant_id' => $request->comercio_id]);
        }

        $productos = $query->limit(20)->get();

        return response()->json([
            'success' => true,
            'data' => ProductoResource::collection($productos)
        ]);
    }
}
```

### 3. CategoriaController

**Archivo:** `app/Http/Controllers/CategoriaController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Http\Resources\CategoriaResource;
use App\Models\Categoria;
use App\Models\Comercio;
use Illuminate\Support\Facades\Cache;

class CategoriaController extends Controller
{
    public function index($slug)
    {
        $comercio = Comercio::where('slug', $slug)->firstOrFail();
        config(['app.tenant_id' => $comercio->id]);

        $categorias = Cache::remember("comercio.{$comercio->id}.categorias", 3600, function() {
            return Categoria::with('productos')
                ->where('is_active', true)
                ->ordenado()
                ->get();
        });

        return response()->json([
            'success' => true,
            'data' => CategoriaResource::collection($categorias)
        ]);
    }
}
```

### 4. Resources

**Archivo:** `app/Http/Resources/ComercioResource.php`

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ComercioResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'slug' => $this->slug,
            'nombre' => $this->nombre,
            'descripcion' => $this->descripcion,
            'categoria' => $this->categoria,
            'logo_url' => $this->logo_url,
            'banner_url' => $this->banner_url,
            'branding' => $this->branding_json,
            'ubicacion' => [
                'lat' => (float) $this->lat,
                'lng' => (float) $this->lng,
                'direccion' => $this->direccion,
                'ciudad' => $this->ciudad,
                'estado' => $this->estado,
            ],
            'contacto' => [
                'telefono' => $this->telefono,
                'email' => $this->email,
                'whatsapp' => $this->whatsapp,
            ],
            'configuracion' => [
                'radio_entrega_km' => (float) $this->radio_entrega_km,
                'tiempo_preparacion_min' => $this->tiempo_preparacion_min,
                'delivery_fee_usd' => (float) $this->delivery_fee_usd,
                'delivery_fee_bs' => (float) $this->delivery_fee_bs,
                'pedido_minimo_usd' => (float) $this->pedido_minimo_usd,
                'pedido_minimo_bs' => (float) $this->pedido_minimo_bs,
            ],
            'metodos_pago' => [
                'efectivo' => $this->acepta_efectivo,
                'pago_movil' => $this->acepta_pago_movil,
                'transferencia' => $this->acepta_transferencia,
                'tarjeta' => $this->acepta_tarjeta,
            ],
            'horarios' => $this->horarios_json,
            'is_active' => $this->is_active,
            'is_open' => $this->is_open,
            'rating' => (float) $this->rating,
            'total_reviews' => $this->total_reviews,
            'distancia_km' => $this->when(isset($this->distancia_km), $this->distancia_km),
            'tiempo_estimado_min' => $this->when(isset($this->tiempo_estimado_min), $this->tiempo_estimado_min),
        ];
    }
}
```

**Archivo:** `app/Http/Resources/ProductoResource.php`

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ProductoResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'nombre' => $this->nombre,
            'descripcion' => $this->descripcion,
            'imagen_url' => $this->imagen_url,
            'precio_usd' => (float) $this->precio_usd,
            'precio_bs' => (float) $this->precio_bs,
            'precio_oferta_usd' => $this->when($this->precio_oferta_usd, (float) $this->precio_oferta_usd),
            'precio_oferta_bs' => $this->when($this->precio_oferta_bs, (float) $this->precio_oferta_bs),
            'stock' => $this->stock,
            'stock_ilimitado' => $this->stock_ilimitado,
            'tiene_variantes' => $this->tiene_variantes,
            'variantes' => $this->when($this->tiene_variantes, $this->variantes_json),
            'is_active' => $this->is_active,
            'is_destacado' => $this->is_destacado,
            'categoria' => $this->when($this->relationLoaded('categoria'), function() {
                return [
                    'id' => $this->categoria->id,
                    'nombre' => $this->categoria->nombre,
                ];
            }),
            'comercio' => $this->when($this->relationLoaded('comercio'), function() {
                return [
                    'id' => $this->comercio->id,
                    'nombre' => $this->comercio->nombre,
                    'slug' => $this->comercio->slug,
                ];
            }),
            'rating' => (float) $this->rating,
            'total_ventas' => $this->total_ventas,
        ];
    }
}
```

**Archivo:** `app/Http/Resources/CategoriaResource.php`

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class CategoriaResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'nombre' => $this->nombre,
            'descripcion' => $this->descripcion,
            'icono' => $this->icono,
            'orden' => $this->orden,
            'productos_count' => $this->when($this->relationLoaded('productos'), $this->productos->count()),
        ];
    }
}
```

### 5. Rutas API

**Archivo:** `routes/api.php`

```php
use App\Http\Controllers\CategoriaController;
use App\Http\Controllers\ComercioController;
use App\Http\Controllers\ProductoController;

// Comercios
Route::get('/comercios/{slug}', [ComercioController::class, 'show']);
Route::get('/comercios/{slug}/branding', [ComercioController::class, 'branding']);
Route::get('/comercios/cercanos', [ComercioController::class, 'cercanos']);

// Productos
Route::get('/comercios/{slug}/productos', [ProductoController::class, 'index']);
Route::get('/comercios/{slug}/categorias', [CategoriaController::class, 'index']);
Route::get('/productos/{id}', [ProductoController::class, 'show']);
Route::get('/productos/search', [ProductoController::class, 'search']);
```

### 6. Seeders

**Archivo:** `database/seeders/ComercioSeeder.php`

```php
<?php

namespace Database\Seeders;

use App\Models\Comercio;
use Illuminate\Database\Seeder;

class ComercioSeeder extends Seeder
{
    public function run()
    {
        Comercio::create([
            'slug' => 'pizzeria-express',
            'nombre' => 'Pizzería Express',
            'descripcion' => 'Las mejores pizzas de la ciudad',
            'categoria' => 'restaurante',
            'branding_json' => [
                'colors' => [
                    'primary' => '#1B3A57',
                    'secondary' => '#5FD4A0',
                    'accent' => '#4CAF50',
                ],
                'theme' => 'light'
            ],
            'logo_url' => 'https://via.placeholder.com/150',
            'lat' => 10.4806,
            'lng' => -66.8037,
            'direccion' => 'Av. Principal de Los Ruices',
            'ciudad' => 'Caracas',
            'estado' => 'Miranda',
            'telefono' => '+58212123456',
            'email' => 'info@pizzeriaexpress.com',
            'is_active' => true,
            'is_open' => true,
        ]);
    }
}
```

## Definición de Hecho (DoD)

- [ ] Todos los endpoints funcionando
- [ ] Cache implementado con Redis
- [ ] Resources transformando datos correctamente
- [ ] Filtros y búsqueda operativos
- [ ] Cálculo de distancia funcionando
- [ ] Tests de API pasando
- [ ] Documentación actualizada

## Comandos de Verificación

```bash
# Ejecutar seeders
php artisan db:seed --class=ComercioSeeder

# Probar endpoints
curl http://localhost:8000/api/comercios/pizzeria-express
curl http://localhost:8000/api/comercios/pizzeria-express/productos
curl "http://localhost:8000/api/comercios/cercanos?lat=10.4806&lng=-66.8037"

# Verificar cache
php artisan tinker
>>> Cache::get('comercio.pizzeria-express');
```

## Dependencias

- Issue #5: Implementar Multi-tenancy

## Siguiente Issue

Issue #7: API de Pedidos (Cliente)
