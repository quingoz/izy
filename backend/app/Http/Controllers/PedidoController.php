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
        
        $subtotalUsd = 0;
        $subtotalBs = 0;
        
        foreach ($validated['items'] as $item) {
            $producto = Producto::findOrFail($item['producto_id']);
            
            if (!$producto->hasStock($item['cantidad'])) {
                return response()->json([
                    'success' => false,
                    'message' => "Producto {$producto->nombre} sin stock suficiente"
                ], 422);
            }
            
            $precioUsd = $producto->getPrecioFinal('usd');
            $precioBs = $producto->getPrecioFinal('bs');
            
            if (isset($item['variantes'])) {
                foreach ($item['variantes'] as $variante) {
                    $precioUsd += $variante['price_usd'] ?? 0;
                    $precioBs += $variante['price_bs'] ?? 0;
                }
            }
            
            $subtotalUsd += $precioUsd * $item['cantidad'];
            $subtotalBs += $precioBs * $item['cantidad'];
        }
        
        $comercio = auth()->user()->comercio ?? \App\Models\Comercio::find($validated['comercio_id']);
        $deliveryFeeUsd = $comercio->delivery_fee_usd;
        $deliveryFeeBs = $comercio->delivery_fee_bs;
        
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
            
            $producto->decrementStock($item['cantidad']);
        }
        
        $pedido->estados()->create([
            'estado_anterior' => null,
            'estado_nuevo' => 'pendiente',
            'user_id' => auth()->id(),
            'user_role' => 'cliente',
        ]);
        
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
