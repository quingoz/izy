# Issue #5: Implementar Multi-tenancy

**Epic:** Backend Core & Database  
**Prioridad:** Crítica  
**Estimación:** 2 días  
**Sprint:** Sprint 1

---

## Descripción

Implementar arquitectura multi-tenant con aislamiento completo de datos por comercio_id usando middleware y global scopes.

## Objetivos

- Crear middleware `IdentifyTenant`
- Implementar aislamiento automático de datos
- Crear políticas de autorización
- Tests exhaustivos de aislamiento

## Tareas Técnicas

### 1. Middleware IdentifyTenant

**Archivo:** `app/Http/Middleware/IdentifyTenant.php`

```php
<?php

namespace App\Http\Middleware;

use App\Models\Comercio;
use Closure;
use Illuminate\Http\Request;

class IdentifyTenant
{
    public function handle(Request $request, Closure $next)
    {
        // Detectar slug desde URL, header o parámetro
        $slug = $request->route('slug') 
             ?? $request->header('X-Tenant-Slug')
             ?? $request->input('comercio_slug');
        
        if ($slug) {
            $comercio = Comercio::where('slug', $slug)
                ->where('is_active', true)
                ->first();
            
            if (!$comercio) {
                return response()->json([
                    'success' => false,
                    'message' => 'Comercio no encontrado'
                ], 404);
            }
            
            // Almacenar en contexto de aplicación
            app()->instance('tenant', $comercio);
            config(['app.tenant_id' => $comercio->id]);
            
            // Logging para debugging
            logger()->info('Tenant identified', [
                'slug' => $slug,
                'comercio_id' => $comercio->id,
                'comercio_nombre' => $comercio->nombre
            ]);
        }
        
        return $next($request);
    }
}
```

**Registrar en:** `app/Http/Kernel.php`

```php
protected $middlewareAliases = [
    // ...
    'tenant' => \App\Http\Middleware\IdentifyTenant::class,
];

protected $middlewareGroups = [
    'api' => [
        // ...
        \App\Http\Middleware\IdentifyTenant::class,
    ],
];
```

### 2. Helper para Obtener Tenant

**Archivo:** `app/Helpers/TenantHelper.php`

```php
<?php

namespace App\Helpers;

use App\Models\Comercio;

class TenantHelper
{
    public static function get(): ?Comercio
    {
        return app('tenant');
    }

    public static function getId(): ?int
    {
        return config('app.tenant_id');
    }

    public static function check(): bool
    {
        return self::getId() !== null;
    }

    public static function set(Comercio $comercio): void
    {
        app()->instance('tenant', $comercio);
        config(['app.tenant_id' => $comercio->id]);
    }
}
```

### 3. Políticas de Autorización

**Archivo:** `app/Policies/ProductoPolicy.php`

```php
<?php

namespace App\Policies;

use App\Models\Producto;
use App\Models\User;

class ProductoPolicy
{
    public function viewAny(User $user)
    {
        return true;
    }

    public function view(User $user, Producto $producto)
    {
        // Verificar que el producto pertenece al comercio del usuario
        if ($user->role === 'comercio') {
            return $user->comercio_id === $producto->comercio_id;
        }
        return true; // Clientes pueden ver cualquier producto
    }

    public function create(User $user)
    {
        return $user->role === 'comercio';
    }

    public function update(User $user, Producto $producto)
    {
        return $user->role === 'comercio' 
            && $user->comercio_id === $producto->comercio_id;
    }

    public function delete(User $user, Producto $producto)
    {
        return $user->role === 'comercio' 
            && $user->comercio_id === $producto->comercio_id;
    }
}
```

**Archivo:** `app/Policies/PedidoPolicy.php`

```php
<?php

namespace App\Policies;

use App\Models\Pedido;
use App\Models\User;

class PedidoPolicy
{
    public function view(User $user, Pedido $pedido)
    {
        return match($user->role) {
            'cliente' => $user->id === $pedido->cliente_id,
            'comercio' => $user->comercio_id === $pedido->comercio_id,
            'repartidor' => $user->repartidor?->id === $pedido->repartidor_id,
            'admin' => true,
            default => false,
        };
    }

    public function update(User $user, Pedido $pedido)
    {
        return match($user->role) {
            'comercio' => $user->comercio_id === $pedido->comercio_id,
            'repartidor' => $user->repartidor?->id === $pedido->repartidor_id,
            'admin' => true,
            default => false,
        };
    }

    public function cancel(User $user, Pedido $pedido)
    {
        if ($user->role === 'cliente' && $user->id === $pedido->cliente_id) {
            return in_array($pedido->estado, ['pendiente', 'confirmado']);
        }
        
        if ($user->role === 'comercio' && $user->comercio_id === $pedido->comercio_id) {
            return in_array($pedido->estado, ['pendiente', 'confirmado', 'preparando']);
        }
        
        return false;
    }
}
```

**Registrar en:** `app/Providers/AuthServiceProvider.php`

```php
<?php

namespace App\Providers;

use App\Models\Pedido;
use App\Models\Producto;
use App\Policies\PedidoPolicy;
use App\Policies\ProductoPolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        Producto::class => ProductoPolicy::class,
        Pedido::class => PedidoPolicy::class,
    ];

    public function boot()
    {
        $this->registerPolicies();
    }
}
```

### 4. Tests de Multi-tenancy

**Archivo:** `tests/Feature/MultiTenancyTest.php`

```php
<?php

namespace Tests\Feature;

use App\Models\Comercio;
use App\Models\Producto;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MultiTenancyTest extends TestCase
{
    use RefreshDatabase;

    public function test_tenant_scope_filters_productos()
    {
        $comercio1 = Comercio::factory()->create(['slug' => 'comercio-1']);
        $comercio2 = Comercio::factory()->create(['slug' => 'comercio-2']);

        $producto1 = Producto::factory()->create(['comercio_id' => $comercio1->id]);
        $producto2 = Producto::factory()->create(['comercio_id' => $comercio2->id]);

        // Sin tenant, ve todos
        $this->assertCount(2, Producto::withoutGlobalScopes()->get());

        // Con tenant, solo ve los suyos
        config(['app.tenant_id' => $comercio1->id]);
        $this->assertCount(1, Producto::all());
        $this->assertEquals($producto1->id, Producto::first()->id);
    }

    public function test_tenant_auto_assigns_on_create()
    {
        $comercio = Comercio::factory()->create();
        config(['app.tenant_id' => $comercio->id]);

        $producto = Producto::create([
            'nombre' => 'Test Producto',
            'precio_usd' => 10,
            'precio_bs' => 350
        ]);

        $this->assertEquals($comercio->id, $producto->comercio_id);
    }

    public function test_cannot_access_other_tenant_data()
    {
        $comercio1 = Comercio::factory()->create();
        $comercio2 = Comercio::factory()->create();

        $producto1 = Producto::factory()->create(['comercio_id' => $comercio1->id]);
        $producto2 = Producto::factory()->create(['comercio_id' => $comercio2->id]);

        config(['app.tenant_id' => $comercio1->id]);

        // No puede encontrar producto de otro tenant
        $this->assertNull(Producto::find($producto2->id));
        
        // Solo encuentra el suyo
        $this->assertNotNull(Producto::find($producto1->id));
    }

    public function test_middleware_identifies_tenant_from_slug()
    {
        $comercio = Comercio::factory()->create(['slug' => 'test-comercio']);

        $response = $this->getJson('/api/comercios/test-comercio');

        $this->assertEquals($comercio->id, config('app.tenant_id'));
    }

    public function test_policy_prevents_cross_tenant_access()
    {
        $comercio1 = Comercio::factory()->create();
        $comercio2 = Comercio::factory()->create();

        $user1 = User::factory()->create([
            'role' => 'comercio',
            'comercio_id' => $comercio1->id
        ]);

        $producto2 = Producto::factory()->create(['comercio_id' => $comercio2->id]);

        $this->actingAs($user1);

        // No puede actualizar producto de otro comercio
        $this->assertFalse($user1->can('update', $producto2));
    }

    public function test_tenant_isolation_in_relationships()
    {
        $comercio1 = Comercio::factory()->create();
        $comercio2 = Comercio::factory()->create();

        Producto::factory()->count(3)->create(['comercio_id' => $comercio1->id]);
        Producto::factory()->count(2)->create(['comercio_id' => $comercio2->id]);

        config(['app.tenant_id' => $comercio1->id]);

        $this->assertCount(3, $comercio1->productos);
        
        // Relación también respeta el scope
        $this->assertCount(3, Producto::all());
    }
}
```

### 5. Comando Artisan para Testing

**Archivo:** `app/Console/Commands/TestTenantIsolation.php`

```php
<?php

namespace App\Console\Commands;

use App\Models\Comercio;
use App\Models\Producto;
use Illuminate\Console\Command;

class TestTenantIsolation extends Command
{
    protected $signature = 'tenant:test-isolation';
    protected $description = 'Prueba el aislamiento de datos multi-tenant';

    public function handle()
    {
        $this->info('Probando aislamiento multi-tenant...');

        $comercio1 = Comercio::first();
        $comercio2 = Comercio::skip(1)->first();

        if (!$comercio1 || !$comercio2) {
            $this->error('Se necesitan al menos 2 comercios en la DB');
            return 1;
        }

        // Sin tenant
        $totalSinTenant = Producto::withoutGlobalScopes()->count();
        $this->info("Productos sin tenant: {$totalSinTenant}");

        // Con tenant 1
        config(['app.tenant_id' => $comercio1->id]);
        $totalTenant1 = Producto::count();
        $this->info("Productos de {$comercio1->nombre}: {$totalTenant1}");

        // Con tenant 2
        config(['app.tenant_id' => $comercio2->id]);
        $totalTenant2 = Producto::count();
        $this->info("Productos de {$comercio2->nombre}: {$totalTenant2}");

        if ($totalTenant1 + $totalTenant2 === $totalSinTenant) {
            $this->info('✓ Aislamiento funcionando correctamente');
            return 0;
        } else {
            $this->error('✗ Hay un problema con el aislamiento');
            return 1;
        }
    }
}
```

### 6. Middleware para Validar Tenant en Rutas Protegidas

**Archivo:** `app/Http/Middleware/RequireTenant.php`

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class RequireTenant
{
    public function handle(Request $request, Closure $next)
    {
        if (!config('app.tenant_id')) {
            return response()->json([
                'success' => false,
                'message' => 'Tenant no identificado'
            ], 400);
        }

        return $next($request);
    }
}
```

## Definición de Hecho (DoD)

- [ ] Middleware `IdentifyTenant` funcionando
- [ ] Global Scope aplicado correctamente
- [ ] Trait `BelongsToTenant` auto-asigna comercio_id
- [ ] Políticas de autorización implementadas
- [ ] Tests de aislamiento pasando al 100%
- [ ] No es posible acceso cruzado entre comercios
- [ ] Comando de testing funcional

## Comandos de Verificación

```bash
# Ejecutar tests
php artisan test --filter=MultiTenancyTest

# Probar comando de testing
php artisan tenant:test-isolation

# Tinker para probar manualmente
php artisan tinker
>>> config(['app.tenant_id' => 1]);
>>> Producto::all(); // Solo del comercio 1
>>> config(['app.tenant_id' => 2]);
>>> Producto::all(); // Solo del comercio 2
```

## Notas Importantes

- **CRÍTICO:** El aislamiento debe ser perfecto
- Todos los modelos multi-tenant deben usar el trait
- Las políticas deben validar pertenencia
- Tests exhaustivos son obligatorios

## Dependencias

- Issue #3: Implementar Modelos Eloquent
- Issue #4: Sistema de Autenticación con Sanctum

## Siguiente Issue

Issue #6: API de Comercios y Productos
