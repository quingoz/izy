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
                $pedido->ganancia_estimada_usd = $pedido->delivery_fee_usd * 0.7;
                
                return $pedido;
            });

        return response()->json([
            'success' => true,
            'data' => PedidoResource::collection($pedidos)
        ]);
    }

    public function misPedidos(Request $request)
    {
        $repartidor = $request->user()->repartidor;

        $pedidos = Pedido::where('repartidor_id', $repartidor->id)
            ->whereIn('estado', ['en_camino', 'listo'])
            ->with(['comercio', 'cliente'])
            ->orderBy('created_at', 'desc')
            ->get();

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
