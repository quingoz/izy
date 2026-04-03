# Issue #32: Optimización de Performance

**Epic:** Testing & Deployment  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 5

---

## Descripción

Optimizar performance del backend y frontend para tiempos de respuesta <200ms.

## Objetivos

- Cache de queries frecuentes
- Eager loading de relaciones
- Índices de base de datos
- Optimización de imágenes
- Lazy loading en Flutter
- Reducción de bundle size

## Tareas Técnicas

### 1. Cache Redis

```php
// Cachear comercios
Route::get('/comercios/{slug}', function($slug) {
    return Cache::remember("comercio.{$slug}", 3600, function() use ($slug) {
        return Comercio::where('slug', $slug)->firstOrFail();
    });
});

// Cachear productos
Route::get('/comercios/{slug}/productos', function($slug) {
    $comercio = Comercio::where('slug', $slug)->firstOrFail();
    
    return Cache::remember("comercio.{$comercio->id}.productos", 1800, function() use ($comercio) {
        return Producto::where('comercio_id', $comercio->id)
            ->with('categoria')
            ->active()
            ->get();
    });
});
```

### 2. Eager Loading

```php
// Antes (N+1 queries)
$pedidos = Pedido::all();
foreach ($pedidos as $pedido) {
    echo $pedido->cliente->name;
    echo $pedido->comercio->nombre;
}

// Después (3 queries)
$pedidos = Pedido::with(['cliente', 'comercio', 'items'])->get();
```

### 3. Índices de Base de Datos

```sql
-- Índices para búsquedas frecuentes
CREATE INDEX idx_pedidos_estado ON pedidos(estado);
CREATE INDEX idx_pedidos_comercio_fecha ON pedidos(comercio_id, created_at);
CREATE INDEX idx_productos_comercio_active ON productos(comercio_id, is_active);
CREATE INDEX idx_repartidores_status ON repartidores(status, is_active);

-- Índice geoespacial
CREATE SPATIAL INDEX idx_comercios_location ON comercios(lat, lng);
```

### 4. Optimización Flutter

```dart
// Lazy loading de imágenes
CachedNetworkImage(
  imageUrl: producto.imagenUrl,
  placeholder: (context, url) => const ShimmerPlaceholder(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  memCacheWidth: 400,
  memCacheHeight: 400,
);

// Pagination
ListView.builder(
  itemCount: productos.length + 1,
  itemBuilder: (context, index) {
    if (index == productos.length) {
      return const CircularProgressIndicator();
    }
    return ProductoCard(producto: productos[index]);
  },
);
```

## Definición de Hecho (DoD)

- [ ] Queries optimizadas con cache
- [ ] Eager loading implementado
- [ ] Índices creados
- [ ] Imágenes optimizadas
- [ ] Lazy loading en Flutter
- [ ] Tiempos de respuesta <200ms
- [ ] Tests de performance pasando

## Comandos de Verificación

```bash
# Laravel Debugbar
composer require barryvdh/laravel-debugbar --dev

# Análisis de queries
php artisan telescope:install

# Flutter performance
flutter run --profile
flutter build web --release
```

## Dependencias

- Issue #31: Tests End-to-End

## Siguiente Issue

Issue #33: Deployment Backend
