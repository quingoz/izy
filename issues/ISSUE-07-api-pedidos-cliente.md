# Issue #7: API de Pedidos (Cliente)

**Epic:** Backend Core & Database  
**Prioridad:** Alta  
**Estimación:** 3 días  
**Sprint:** Sprint 2

---

## Descripción

Implementar API completa para gestión de pedidos desde el lado del cliente: crear, consultar, tracking y cancelar.

## Objetivos

- Endpoint para crear pedidos con validaciones completas
- Historial de pedidos del cliente
- Tracking público por token
- Cancelación de pedidos
- Generación automática de número de pedido

## Tareas Técnicas

### 1. PedidoController

**Archivo:** `app/Http/Controllers/PedidoController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Http\Requests\StorePedidoRequest;
use App\Http\Resources\PedidoResource;
use App\Jobs\ProcessPedido;
use App\Models\Pedido;
use App\Models\Producto;
use Illuminate\Http\Request;

class PedidoController extends Controller
{
    public function store(StorePedidoRequest $request)
    {
        $validated = $request->validated();
        
        // Calcular totales
        $subtotalUsd = 0;
        $subtotalBs = 0;
        
        foreach ($validated['items'] as $item) {
            $producto = Producto::findOrFail($item['producto_id']);
            
            // Validar stock
            if (!$producto->hasStock($item['cantidad'])) {
                return response()->json([
                    'success' => false,
                    'message' => "Producto {$producto->nombre} sin stock suficiente"
                ], 422);
            }
            
            $precioUsd = $producto->getPrecioFinal('usd');
            $precioBs = $producto->getPrecioFinal('bs');
            
            // Sumar precio de variantes
            if (isset($item['variantes'])) {
                foreach ($item['variantes'] as $variante) {
                    $precioUsd += $variante['price_usd'] ?? 0;
                    $precioBs += $variante['price_bs'] ?? 0;
                }
            }
            
            $subtotalUsd += $precioUsd * $item['cantidad'];
            $subtotalBs += $precioBs * $item['cantidad'];
        }
        
        // Obtener delivery fee del comercio
        $comercio = auth()->user()->comercio ?? \App\Models\Comercio::find($validated['comercio_id']);
        $deliveryFeeUsd = $comercio->delivery_fee_usd;
        $deliveryFeeBs = $comercio->delivery_fee_bs;
        
        // Crear pedido
        $pedido = Pedido::create([
            'comercio_id' => $validated['comercio_id'],
            'cliente_id' => auth()->id(),
            'subtotal_usd' => $subtotalUsd,
            'subtotal_bs' => $subtotalBs,
            'delivery_fee_usd' => $deliveryFeeUsd,
            'delivery_fee_bs' => $deliveryFeeBs,
            'total_usd' => $subtotalUsd + $deliveryFeeUsd,
            'total_bs' => $subtotalBs + $deliveryFeeBs,
            'tipo_pago' => $validated['tipo_pago'],
            'vuelto_de' => $validated['vuelto_de'] ?? null,
            'pago_movil_json' => $validated['pago_movil'] ?? null,
            'direccion_json' => $validated['direccion'],
            'notas_cliente' => $validated['notas_cliente'] ?? null,
            'estado' => 'pendiente',
        ]);
        
        // Crear items del pedido
        foreach ($validated['items'] as $item) {
            $producto = Producto::find($item['producto_id']);
            
            $precioUnitarioUsd = $producto->getPrecioFinal('usd');
            $precioUnitarioBs = $producto->getPrecioFinal('bs');
            
            if (isset($item['variantes'])) {
                foreach ($item['variantes'] as $variante) {
                    $precioUnitarioUsd += $variante['price_usd'] ?? 0;
                    $precioUnitarioBs += $variante['price_bs'] ?? 0;
                }
            }
            
            $pedido->items()->create([
                'producto_id' => $producto->id,
                'nombre_producto' => $producto->nombre,
                'cantidad' => $item['cantidad'],
                'precio_unitario_usd' => $precioUnitarioUsd,
                'precio_unitario_bs' => $precioUnitarioBs,
                'subtotal_usd' => $precioUnitarioUsd * $item['cantidad'],
                'subtotal_bs' => $precioUnitarioBs * $item['cantidad'],
                'variantes_json' => $item['variantes'] ?? null,
                'notas' => $item['notas'] ?? null,
            ]);
            
            // Decrementar stock
            $producto->decrementStock($item['cantidad']);
        }
        
        // Registrar estado inicial
        $pedido->estados()->create([
            'estado_anterior' => null,
            'estado_nuevo' => 'pendiente',
            'user_id' => auth()->id(),
            'user_role' => 'cliente',
        ]);
        
        // Dispatch job para procesar pedido (notificaciones, etc)
        ProcessPedido::dispatch($pedido);
        
        return response()->json([
            'success' => true,
            'data' => new PedidoResource($pedido->load('items')),
            'message' => 'Pedido creado exitosamente'
        ], 201);
    }

    public function index()
    {
        $pedidos = Pedido::where('cliente_id', auth()->id())
            ->with(['comercio', 'items'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => PedidoResource::collection($pedidos),
            'meta' => [
                'current_page' => $pedidos->currentPage(),
                'total' => $pedidos->total(),
            ]
        ]);
    }

    public function show($id)
    {
        $pedido = Pedido::with(['items', 'comercio', 'repartidor.user', 'estados'])
            ->findOrFail($id);

        $this->authorize('view', $pedido);

        return response()->json([
            'success' => true,
            'data' => new PedidoResource($pedido)
        ]);
    }

    public function tracking($token)
    {
        $pedido = Pedido::where('token_seguimiento', $token)
            ->with(['comercio', 'repartidor.user'])
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => [
                'numero_pedido' => $pedido->numero_pedido,
                'estado' => $pedido->estado,
                'tiempo_estimado_minutos' => $pedido->tiempo_estimado_minutos,
                'comercio' => [
                    'nombre' => $pedido->comercio->nombre,
                    'lat' => (float) $pedido->comercio->lat,
                    'lng' => (float) $pedido->comercio->lng,
                ],
                'cliente' => [
                    'lat' => (float) $pedido->direccion_json['lat'],
                    'lng' => (float) $pedido->direccion_json['lng'],
                ],
                'repartidor' => $pedido->repartidor ? [
                    'nombre' => $pedido->repartidor->user->name,
                    'lat' => (float) $pedido->repartidor->current_lat,
                    'lng' => (float) $pedido->repartidor->current_lng,
                    'last_update' => $pedido->repartidor->last_location_update,
                ] : null,
            ]
        ]);
    }

    public function cancel($id, Request $request)
    {
        $pedido = Pedido::findOrFail($id);
        
        $this->authorize('cancel', $pedido);

        if (!in_array($pedido->estado, ['pendiente', 'confirmado'])) {
            return response()->json([
                'success' => false,
                'message' => 'No se puede cancelar el pedido en este estado'
            ], 422);
        }

        $pedido->cambiarEstado('cancelado', auth()->id(), $request->razon);
        $pedido->razon_cancelacion = $request->razon;
        $pedido->fecha_cancelado = now();
        $pedido->save();

        // Devolver stock
        foreach ($pedido->items as $item) {
            $producto = Producto::find($item->producto_id);
            if ($producto && !$producto->stock_ilimitado) {
                $producto->increment('stock', $item->cantidad);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Pedido cancelado exitosamente'
        ]);
    }
}
```

### 2. StorePedidoRequest

**Archivo:** `app/Http/Requests/StorePedidoRequest.php`

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePedidoRequest extends FormRequest
{
    public function authorize()
    {
        return auth()->check();
    }

    public function rules()
    {
        return [
            'comercio_id' => 'required|exists:comercios,id',
            'items' => 'required|array|min:1',
            'items.*.producto_id' => 'required|exists:productos,id',
            'items.*.cantidad' => 'required|integer|min:1|max:99',
            'items.*.variantes' => 'nullable|array',
            'items.*.variantes.*.name' => 'required|string',
            'items.*.variantes.*.value' => 'required',
            'items.*.variantes.*.price_usd' => 'required|numeric|min:0',
            'items.*.variantes.*.price_bs' => 'required|numeric|min:0',
            'items.*.notas' => 'nullable|string|max:500',
            
            'tipo_pago' => 'required|in:efectivo,pago_movil,transferencia,tarjeta',
            'vuelto_de' => 'nullable|required_if:tipo_pago,efectivo|numeric|min:0',
            
            'pago_movil' => 'nullable|required_if:tipo_pago,pago_movil|array',
            'pago_movil.banco' => 'required_with:pago_movil|string',
            'pago_movil.telefono' => 'required_with:pago_movil|string',
            'pago_movil.referencia' => 'required_with:pago_movil|string',
            
            'direccion' => 'required|array',
            'direccion.calle' => 'required|string',
            'direccion.ciudad' => 'nullable|string',
            'direccion.estado' => 'nullable|string',
            'direccion.referencia' => 'nullable|string',
            'direccion.lat' => 'required|numeric|between:-90,90',
            'direccion.lng' => 'required|numeric|between:-180,180',
            
            'notas_cliente' => 'nullable|string|max:1000',
        ];
    }

    public function messages()
    {
        return [
            'items.required' => 'Debes agregar al menos un producto',
            'items.min' => 'Debes agregar al menos un producto',
            'vuelto_de.required_if' => 'Indica con cuánto vas a pagar',
            'direccion.lat.required' => 'Selecciona una dirección válida',
        ];
    }

    protected function prepareForValidation()
    {
        // Sanitizar notas
        if ($this->has('notas_cliente')) {
            $this->merge([
                'notas_cliente' => strip_tags($this->notas_cliente)
            ]);
        }
    }
}
```

### 3. PedidoResource

**Archivo:** `app/Http/Resources/PedidoResource.php`

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class PedidoResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'numero_pedido' => $this->numero_pedido,
            'token_seguimiento' => $this->when($request->user()?->id === $this->cliente_id, $this->token_seguimiento),
            'estado' => $this->estado,
            
            'items' => PedidoItemResource::collection($this->whenLoaded('items')),
            
            'subtotal_usd' => (float) $this->subtotal_usd,
            'subtotal_bs' => (float) $this->subtotal_bs,
            'delivery_fee_usd' => (float) $this->delivery_fee_usd,
            'delivery_fee_bs' => (float) $this->delivery_fee_bs,
            'total_usd' => (float) $this->total_usd,
            'total_bs' => (float) $this->total_bs,
            
            'tipo_pago' => $this->tipo_pago,
            'vuelto' => $this->when($this->tipo_pago === 'efectivo' && $this->vuelto_de, 
                (float) $this->vuelto_de - $this->total_bs),
            
            'direccion' => $this->direccion_json,
            'notas_cliente' => $this->notas_cliente,
            
            'comercio' => $this->when($this->relationLoaded('comercio'), function() {
                return [
                    'id' => $this->comercio->id,
                    'nombre' => $this->comercio->nombre,
                    'logo_url' => $this->comercio->logo_url,
                    'telefono' => $this->comercio->telefono,
                ];
            }),
            
            'repartidor' => $this->when($this->repartidor, function() {
                return [
                    'nombre' => $this->repartidor->user->name,
                    'telefono' => $this->repartidor->user->phone,
                    'vehiculo' => $this->repartidor->vehiculo_tipo,
                    'placa' => $this->repartidor->placa_vehiculo,
                ];
            }),
            
            'historial_estados' => $this->when($this->relationLoaded('estados'), function() {
                return $this->estados->map(function($estado) {
                    return [
                        'estado' => $estado->estado_nuevo,
                        'fecha' => $estado->created_at,
                    ];
                });
            }),
            
            'tiempo_estimado_minutos' => $this->tiempo_estimado_minutos,
            'created_at' => $this->created_at,
        ];
    }
}
```

### 4. Job ProcessPedido

**Archivo:** `app/Jobs/ProcessPedido.php`

```php
<?php

namespace App\Jobs;

use App\Models\Pedido;
use App\Notifications\NuevoPedidoComercio;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class ProcessPedido implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $pedido;

    public function __construct(Pedido $pedido)
    {
        $this->pedido = $pedido;
    }

    public function handle()
    {
        // Enviar notificación al comercio
        $comercio = $this->pedido->comercio;
        $adminComercio = $comercio->users()->where('role', 'comercio')->first();
        
        if ($adminComercio && $adminComercio->fcm_token) {
            // Enviar push notification
            // FCM implementation here
        }

        // Log del pedido
        logger()->info('Nuevo pedido creado', [
            'pedido_id' => $this->pedido->id,
            'numero_pedido' => $this->pedido->numero_pedido,
            'comercio_id' => $this->pedido->comercio_id,
            'total_usd' => $this->pedido->total_usd,
        ]);
    }
}
```

### 5. Rutas

**Archivo:** `routes/api.php`

```php
// Pedidos (Cliente)
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/pedidos', [PedidoController::class, 'store']);
    Route::get('/mis-pedidos', [PedidoController::class, 'index']);
    Route::get('/pedidos/{id}', [PedidoController::class, 'show']);
    Route::put('/pedidos/{id}/cancel', [PedidoController::class, 'cancel']);
});

// Tracking público (sin auth)
Route::get('/pedidos/{token}/tracking', [PedidoController::class, 'tracking']);
```

## Definición de Hecho (DoD)

- [ ] Endpoint de creación de pedidos funcionando
- [ ] Validaciones completas implementadas
- [ ] Cálculo de totales correcto
- [ ] Generación de número de pedido y token
- [ ] Stock se decrementa correctamente
- [ ] Historial de pedidos funcional
- [ ] Tracking público operativo
- [ ] Cancelación con devolución de stock
- [ ] Tests pasando

## Comandos de Verificación

```bash
# Probar creación de pedido
curl -X POST http://localhost:8000/api/pedidos \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d @pedido.json

# Ver mis pedidos
curl http://localhost:8000/api/mis-pedidos \
  -H "Authorization: Bearer {token}"

# Tracking
curl http://localhost:8000/api/pedidos/{token}/tracking
```

## Dependencias

- Issue #6: API de Comercios y Productos

## Siguiente Issue

Issue #8: Sistema de WebSockets con Laravel Reverb
