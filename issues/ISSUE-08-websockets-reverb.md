# Issue #8: Sistema de WebSockets con Laravel Reverb

**Epic:** Backend Core & Database  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 3

---

## Descripción

Configurar Laravel Reverb para comunicación en tiempo real (tracking GPS, estados de pedido, notificaciones).

## Objetivos

- Configurar servidor Reverb
- Crear eventos broadcast
- Implementar canales privados
- Observer para auto-broadcast
- Tests de WebSockets

## Tareas Técnicas

### 1. Configurar Reverb

```bash
php artisan install:broadcasting
php artisan reverb:install
```

**Archivo:** `.env`

```env
BROADCAST_CONNECTION=reverb

REVERB_APP_ID=izy-app
REVERB_APP_KEY=local-key
REVERB_APP_SECRET=local-secret
REVERB_HOST=localhost
REVERB_PORT=8080
REVERB_SCHEME=http
```

**Archivo:** `config/broadcasting.php`

```php
'reverb' => [
    'driver' => 'reverb',
    'key' => env('REVERB_APP_KEY'),
    'secret' => env('REVERB_APP_SECRET'),
    'app_id' => env('REVERB_APP_ID'),
    'options' => [
        'host' => env('REVERB_HOST', '0.0.0.0'),
        'port' => env('REVERB_PORT', 8080),
        'scheme' => env('REVERB_SCHEME', 'http'),
    ],
],
```

### 2. Eventos Broadcast

**Archivo:** `app/Events/PedidoEstadoActualizado.php`

```php
<?php

namespace App\Events;

use App\Models\Pedido;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Queue\SerializesModels;

class PedidoEstadoActualizado implements ShouldBroadcast
{
    use InteractsWithSockets, SerializesModels;

    public $pedido;

    public function __construct(Pedido $pedido)
    {
        $this->pedido = $pedido;
    }

    public function broadcastOn()
    {
        return [
            new Channel('pedido.' . $this->pedido->id),
            new Channel('comercio.' . $this->pedido->comercio_id),
            new Channel('cliente.' . $this->pedido->cliente_id),
        ];
    }

    public function broadcastWith()
    {
        return [
            'pedido_id' => $this->pedido->id,
            'numero_pedido' => $this->pedido->numero_pedido,
            'estado' => $this->pedido->estado,
            'timestamp' => now()->toIso8601String(),
        ];
    }

    public function broadcastAs()
    {
        return 'pedido.estado.actualizado';
    }
}
```

**Archivo:** `app/Events/RepartidorUbicacionActualizada.php`

```php
<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Queue\SerializesModels;

class RepartidorUbicacionActualizada implements ShouldBroadcast
{
    use InteractsWithSockets, SerializesModels;

    public $pedidoId;
    public $lat;
    public $lng;

    public function __construct($pedidoId, $lat, $lng)
    {
        $this->pedidoId = $pedidoId;
        $this->lat = $lat;
        $this->lng = $lng;
    }

    public function broadcastOn()
    {
        return new Channel('pedido.' . $this->pedidoId . '.tracking');
    }

    public function broadcastWith()
    {
        return [
            'lat' => $this->lat,
            'lng' => $this->lng,
            'timestamp' => now()->toIso8601String(),
        ];
    }

    public function broadcastAs()
    {
        return 'repartidor.ubicacion.actualizada';
    }
}
```

**Archivo:** `app/Events/PedidoAsignado.php`

```php
<?php

namespace App\Events;

use App\Models\Pedido;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Queue\SerializesModels;

class PedidoAsignado implements ShouldBroadcast
{
    use InteractsWithSockets, SerializesModels;

    public $pedido;

    public function __construct(Pedido $pedido)
    {
        $this->pedido = $pedido->load('repartidor.user');
    }

    public function broadcastOn()
    {
        return [
            new Channel('pedido.' . $this->pedido->id),
            new Channel('repartidor.' . $this->pedido->repartidor_id),
        ];
    }

    public function broadcastWith()
    {
        return [
            'pedido_id' => $this->pedido->id,
            'repartidor' => [
                'id' => $this->pedido->repartidor->id,
                'nombre' => $this->pedido->repartidor->user->name,
            ],
        ];
    }

    public function broadcastAs()
    {
        return 'pedido.asignado';
    }
}
```

### 3. Observer para Auto-Broadcast

**Archivo:** `app/Observers/PedidoObserver.php`

```php
<?php

namespace App\Observers;

use App\Events\PedidoAsignado;
use App\Events\PedidoEstadoActualizado;
use App\Models\Pedido;

class PedidoObserver
{
    public function updated(Pedido $pedido)
    {
        // Broadcast cambio de estado
        if ($pedido->isDirty('estado')) {
            broadcast(new PedidoEstadoActualizado($pedido))->toOthers();
        }

        // Broadcast asignación de repartidor
        if ($pedido->isDirty('repartidor_id') && $pedido->repartidor_id) {
            broadcast(new PedidoAsignado($pedido))->toOthers();
        }
    }
}
```

**Registrar en:** `app/Providers/EventServiceProvider.php`

```php
<?php

namespace App\Providers;

use App\Models\Pedido;
use App\Observers\PedidoObserver;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

class EventServiceProvider extends ServiceProvider
{
    public function boot()
    {
        Pedido::observe(PedidoObserver::class);
    }
}
```

### 4. Autorización de Canales

**Archivo:** `routes/channels.php`

```php
<?php

use Illuminate\Support\Facades\Broadcast;

// Canal de pedido (cliente, comercio, repartidor)
Broadcast::channel('pedido.{pedidoId}', function ($user, $pedidoId) {
    $pedido = \App\Models\Pedido::find($pedidoId);
    
    if (!$pedido) {
        return false;
    }

    return $user->id === $pedido->cliente_id
        || $user->comercio_id === $pedido->comercio_id
        || $user->repartidor?->id === $pedido->repartidor_id;
});

// Canal de comercio
Broadcast::channel('comercio.{comercioId}', function ($user, $comercioId) {
    return $user->comercio_id == $comercioId;
});

// Canal de cliente
Broadcast::channel('cliente.{clienteId}', function ($user, $clienteId) {
    return $user->id == $clienteId;
});

// Canal de repartidor
Broadcast::channel('repartidor.{repartidorId}', function ($user, $repartidorId) {
    return $user->repartidor?->id == $repartidorId;
});

// Canal de tracking (público)
Broadcast::channel('pedido.{pedidoId}.tracking', function () {
    return true; // Público
});
```

### 5. Actualizar Ubicación con Broadcast

**Archivo:** `app/Http/Controllers/Repartidor/UbicacionController.php`

```php
<?php

namespace App\Http\Controllers\Repartidor;

use App\Events\RepartidorUbicacionActualizada;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class UbicacionController extends Controller
{
    public function update(Request $request)
    {
        $request->validate([
            'lat' => 'required|numeric|between:-90,90',
            'lng' => 'required|numeric|between:-180,180',
            'accuracy' => 'nullable|numeric',
            'speed' => 'nullable|numeric',
            'pedido_id' => 'nullable|exists:pedidos,id',
        ]);

        $repartidor = $request->user()->repartidor;

        if (!$repartidor) {
            return response()->json([
                'success' => false,
                'message' => 'Usuario no es repartidor'
            ], 403);
        }

        // Actualizar ubicación
        $repartidor->updateLocation(
            $request->lat,
            $request->lng,
            $request->pedido_id
        );

        // Broadcast si está en entrega activa
        if ($request->pedido_id) {
            broadcast(new RepartidorUbicacionActualizada(
                $request->pedido_id,
                $request->lat,
                $request->lng
            ))->toOthers();
        }

        return response()->json([
            'success' => true,
            'message' => 'Ubicación actualizada'
        ]);
    }
}
```

### 6. Tests

**Archivo:** `tests/Feature/WebSocketTest.php`

```php
<?php

namespace Tests\Feature;

use App\Events\PedidoEstadoActualizado;
use App\Models\Pedido;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Tests\TestCase;

class WebSocketTest extends TestCase
{
    use RefreshDatabase;

    public function test_pedido_estado_actualizado_broadcasts()
    {
        Event::fake();

        $pedido = Pedido::factory()->create();
        $pedido->update(['estado' => 'confirmado']);

        Event::assertDispatched(PedidoEstadoActualizado::class, function ($event) use ($pedido) {
            return $event->pedido->id === $pedido->id;
        });
    }

    public function test_user_can_subscribe_to_pedido_channel()
    {
        $user = User::factory()->create();
        $pedido = Pedido::factory()->create(['cliente_id' => $user->id]);

        $this->actingAs($user);

        $canSubscribe = $this->postJson('/broadcasting/auth', [
            'channel_name' => 'pedido.' . $pedido->id,
        ])->assertStatus(200);
    }

    public function test_user_cannot_subscribe_to_other_pedido_channel()
    {
        $user = User::factory()->create();
        $otroPedido = Pedido::factory()->create(); // De otro cliente

        $this->actingAs($user);

        $this->postJson('/broadcasting/auth', [
            'channel_name' => 'pedido.' . $otroPedido->id,
        ])->assertStatus(403);
    }
}
```

## Definición de Hecho (DoD)

- [ ] Servidor Reverb ejecutando sin errores
- [ ] Eventos se broadcaste correctamente
- [ ] Canales privados con autorización
- [ ] Observer auto-broadcaste cambios
- [ ] Ubicación GPS se broadcaste en tiempo real
- [ ] Tests de broadcasting pasando
- [ ] Cliente puede suscribirse a canales

## Comandos de Verificación

```bash
# Iniciar servidor Reverb
php artisan reverb:start

# En otra terminal, probar broadcast
php artisan tinker
>>> $pedido = \App\Models\Pedido::first();
>>> broadcast(new \App\Events\PedidoEstadoActualizado($pedido));

# Ver logs de Reverb
tail -f storage/logs/laravel.log
```

## Notas Importantes

- Reverb debe estar ejecutándose para WebSockets
- En producción, usar supervisor para mantener Reverb activo
- Configurar CORS correctamente para Flutter

## Dependencias

- Issue #7: API de Pedidos (Cliente)

## Siguiente Issue

Issue #9: Sistema de Notificaciones Push (FCM)
