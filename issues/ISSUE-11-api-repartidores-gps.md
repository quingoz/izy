# Issue #11: API de Repartidores y GPS Tracking

**Epic:** Backend Core & Database  
**Prioridad:** Alta  
**Estimación:** 3 días  
**Sprint:** Sprint 4

---

## Descripción

API completa para repartidores: gestión de pedidos, actualización GPS, sistema de asignación inteligente.

## Objetivos

- API de pedidos disponibles (freelance)
- Aceptar/rechazar pedidos
- Actualizar ubicación GPS con broadcast
- Confirmar recogida y entrega
- Sistema de asignación automática
- Estadísticas de repartidor

## Tareas Técnicas

### 1. RepartidorController

**Archivo:** `app/Http/Controllers/Repartidor/PedidoController.php`

```php
<?php

namespace App\Http\Controllers\Repartidor;

use App\Http\Controllers\Controller;
use App\Http\Resources\PedidoResource;
use App\Models\Pedido;
use Illuminate\Http\Request;

class PedidoController extends Controller
{
    public function disponibles(Request $request)
    {
        $repartidor = $request->user()->repartidor;

        if (!$repartidor->isAvailable()) {
            return response()->json([
                'success' => true,
                'data' => [],
                'message' => 'No estás disponible para recibir pedidos'
            ]);
        }

        // Pedidos cercanos sin asignar
        $pedidos = Pedido::where('estado', 'listo')
            ->whereNull('repartidor_id')
            ->whereRaw("
                (6371 * acos(
                    cos(radians(?)) * cos(radians(JSON_EXTRACT(direccion_json, '$.lat'))) *
                    cos(radians(JSON_EXTRACT(direccion_json, '$.lng')) - radians(?)) +
                    sin(radians(?)) * sin(radians(JSON_EXTRACT(direccion_json, '$.lat')))
                )) <= ?
            ", [
                $repartidor->current_lat,
                $repartidor->current_lng,
                $repartidor->current_lat,
                $repartidor->radio_trabajo_km
            ])
            ->with('comercio')
            ->get()
            ->map(function($pedido) use ($repartidor) {
                $comercio = $pedido->comercio;
                $cliente = $pedido->direccion_json;
                
                $distanciaComercio = $comercio->getDistanceTo($repartidor->current_lat, $repartidor->current_lng);
                $distanciaCliente = $comercio->getDistanceTo($cliente['lat'], $cliente['lng']);
                
                $pedido->distancia_total_km = round($distanciaComercio + $distanciaCliente, 2);
                $pedido->ganancia_estimada_usd = $pedido->delivery_fee_usd * 0.7; // 70% para repartidor
                
                return $pedido;
            });

        return response()->json([
            'success' => true,
            'data' => PedidoResource::collection($pedidos)
        ]);
    }

    public function aceptar($id, Request $request)
    {
        $pedido = Pedido::findOrFail($id);
        $repartidor = $request->user()->repartidor;

        if ($pedido->repartidor_id) {
            return response()->json([
                'success' => false,
                'message' => 'Pedido ya asignado a otro repartidor'
            ], 422);
        }

        if (!$repartidor->isAvailable()) {
            return response()->json([
                'success' => false,
                'message' => 'No estás disponible'
            ], 422);
        }

        $pedido->update(['repartidor_id' => $repartidor->id]);
        $repartidor->update(['status' => 'ocupado']);

        return response()->json([
            'success' => true,
            'data' => new PedidoResource($pedido->load('comercio')),
            'message' => 'Pedido aceptado exitosamente'
        ]);
    }

    public function rechazar($id, Request $request)
    {
        $request->validate(['razon' => 'nullable|string|max:500']);

        $pedido = Pedido::findOrFail($id);
        $repartidor = $request->user()->repartidor;

        $repartidor->increment('total_rechazos');

        logger()->info('Pedido rechazado', [
            'pedido_id' => $pedido->id,
            'repartidor_id' => $repartidor->id,
            'razon' => $request->razon
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pedido rechazado'
        ]);
    }

    public function confirmarRecogida($id, Request $request)
    {
        $pedido = Pedido::findOrFail($id);
        $this->authorize('update', $pedido);

        if ($pedido->estado !== 'listo') {
            return response()->json([
                'success' => false,
                'message' => 'El pedido no está listo para recoger'
            ], 422);
        }

        $pedido->cambiarEstado('en_camino', $request->user()->id);
        $pedido->update(['fecha_en_camino' => now()]);

        return response()->json([
            'success' => true,
            'data' => new PedidoResource($pedido->load('cliente')),
            'message' => 'Recogida confirmada'
        ]);
    }

    public function confirmarEntrega($id, Request $request)
    {
        $request->validate([
            'cobro_confirmado' => 'required|boolean',
            'monto_cobrado_bs' => 'nullable|numeric',
            'firma_url' => 'nullable|url',
            'foto_comprobante_url' => 'nullable|url'
        ]);

        $pedido = Pedido::findOrFail($id);
        $this->authorize('update', $pedido);

        if ($pedido->estado !== 'en_camino') {
            return response()->json([
                'success' => false,
                'message' => 'El pedido no está en camino'
            ], 422);
        }

        $pedido->cambiarEstado('entregado', $request->user()->id);
        $pedido->update(['fecha_entregado' => now()]);

        $repartidor = $request->user()->repartidor;
        $ganancia = $pedido->delivery_fee_usd * 0.7;
        
        $repartidor->increment('total_entregas');
        $repartidor->increment('entregas_completadas_hoy');
        $repartidor->increment('ganancias_hoy_usd', $ganancia);
        $repartidor->increment('ganancias_semana_usd', $ganancia);
        $repartidor->increment('ganancias_mes_usd', $ganancia);
        $repartidor->update(['status' => 'disponible']);

        return response()->json([
            'success' => true,
            'data' => [
                'pedido_id' => $pedido->id,
                'estado' => 'entregado',
                'ganancia_usd' => $ganancia,
            ],
            'message' => 'Entrega confirmada exitosamente'
        ]);
    }
}
```

### 2. UbicacionController (ya creado en Issue #8)

Verificar que esté implementado correctamente.

### 3. Sistema de Asignación Automática

**Archivo:** `app/Jobs/AsignarRepartidorAutomatico.php`

```php
<?php

namespace App\Jobs;

use App\Models\Pedido;
use App\Models\Repartidor;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class AsignarRepartidorAutomatico implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $pedido;
    public $timeout = 300; // 5 minutos

    public function __construct(Pedido $pedido)
    {
        $this->pedido = $pedido;
    }

    public function handle()
    {
        // Primero intentar con repartidores exclusivos
        $repartidoresExclusivos = $this->pedido->comercio->repartidores()
            ->wherePivot('is_active', true)
            ->where('status', 'disponible')
            ->orderBy('comercio_repartidor.prioridad')
            ->get();

        if ($repartidoresExclusivos->isNotEmpty()) {
            $repartidor = $repartidoresExclusivos->first();
            $this->asignar($repartidor);
            return;
        }

        // Si no hay exclusivos, buscar freelancers
        $direccion = $this->pedido->direccion_json;
        $repartidoresFreelance = Repartidor::disponibles()
            ->freelance()
            ->cercanos($direccion['lat'], $direccion['lng'], 3)
            ->get();

        if ($repartidoresFreelance->isEmpty()) {
            logger()->warning('No hay repartidores disponibles', [
                'pedido_id' => $this->pedido->id
            ]);
            return;
        }

        // Notificar a todos los freelancers
        foreach ($repartidoresFreelance as $repartidor) {
            NotificarPedidoDisponible::dispatch($this->pedido, $repartidor);
        }

        // Programar timeout para reasignar si nadie acepta
        ReasignarPedidoTimeout::dispatch($this->pedido)
            ->delay(now()->addSeconds($this->timeout));
    }

    private function asignar(Repartidor $repartidor)
    {
        $this->pedido->update(['repartidor_id' => $repartidor->id]);
        $repartidor->update(['status' => 'ocupado']);
        
        SendPushNotification::dispatch(
            $repartidor->user_id,
            'Nuevo Pedido Asignado',
            "Pedido #{$this->pedido->numero_pedido}"
        );
    }
}
```

### 4. Rutas

**Archivo:** `routes/api.php`

```php
Route::middleware(['auth:sanctum', 'role:repartidor'])->prefix('repartidor')->group(function () {
    Route::get('/pedidos/disponibles', [Repartidor\PedidoController::class, 'disponibles']);
    Route::get('/pedidos/mis-pedidos', [Repartidor\PedidoController::class, 'misPedidos']);
    Route::post('/pedidos/{id}/aceptar', [Repartidor\PedidoController::class, 'aceptar']);
    Route::post('/pedidos/{id}/rechazar', [Repartidor\PedidoController::class, 'rechazar']);
    Route::post('/pedidos/{id}/confirmar-recogida', [Repartidor\PedidoController::class, 'confirmarRecogida']);
    Route::post('/pedidos/{id}/confirmar-entrega', [Repartidor\PedidoController::class, 'confirmarEntrega']);
    
    Route::post('/ubicacion', [Repartidor\UbicacionController::class, 'update']);
    Route::put('/estado', [Repartidor\PerfilController::class, 'updateEstado']);
    Route::get('/estadisticas', [Repartidor\PerfilController::class, 'estadisticas']);
});
```

## Definición de Hecho (DoD)

- [ ] Repartidor puede ver pedidos disponibles
- [ ] Aceptar/rechazar funciona correctamente
- [ ] Ubicación GPS se actualiza y broadcaste
- [ ] Confirmar recogida y entrega operativo
- [ ] Sistema de asignación automática funcionando
- [ ] Cálculo de ganancias correcto
- [ ] Tests pasando

## Comandos de Verificación

```bash
php artisan test --filter=RepartidorTest
```

## Dependencias

- Issue #10: API de Gestión de Pedidos (Comercio)

## Siguiente Issue

Issue #12: Setup Proyecto Flutter Web
