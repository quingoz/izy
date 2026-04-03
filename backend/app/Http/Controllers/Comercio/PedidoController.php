<?php

namespace App\Http\Controllers\Comercio;

use App\Http\Controllers\Controller;
use App\Http\Resources\PedidoResource;
use App\Models\Pedido;
use Illuminate\Http\Request;

class PedidoController extends Controller
{
    public function index(Request $request)
    {
        $comercioId = $request->user()->comercio_id;
        
        $query = Pedido::where('comercio_id', $comercioId)
            ->with(['cliente', 'items', 'repartidor.user']);

        if ($request->has('estado')) {
            $query->where('estado', $request->estado);
        }

        if ($request->has('fecha_desde')) {
            $query->whereDate('created_at', '>=', $request->fecha_desde);
        }

        if ($request->has('fecha_hasta')) {
            $query->whereDate('created_at', '<=', $request->fecha_hasta);
        }

        $pedidos = $query->orderBy('created_at', 'desc')->paginate(20);

        return response()->json([
            'success' => true,
            'data' => PedidoResource::collection($pedidos),
            'meta' => [
                'current_page' => $pedidos->currentPage(),
                'total' => $pedidos->total(),
            ]
        ]);
    }

    public function show($id, Request $request)
    {
        $pedido = Pedido::with(['items', 'cliente', 'repartidor.user', 'estados'])
            ->findOrFail($id);

        $this->authorize('view', $pedido);

        return response()->json([
            'success' => true,
            'data' => new PedidoResource($pedido)
        ]);
    }

    public function updateEstado($id, Request $request)
    {
        $request->validate([
            'estado' => 'required|in:confirmado,preparando,listo,cancelado',
            'notas' => 'nullable|string|max:500'
        ]);

        $pedido = Pedido::findOrFail($id);
        $this->authorize('update', $pedido);

        $transicionesValidas = [
            'pendiente' => ['confirmado', 'cancelado'],
            'confirmado' => ['preparando', 'cancelado'],
            'preparando' => ['listo', 'cancelado'],
            'listo' => ['en_camino'],
        ];

        if (!isset($transicionesValidas[$pedido->estado]) ||
            !in_array($request->estado, $transicionesValidas[$pedido->estado])) {
            return response()->json([
                'success' => false,
                'message' => 'Transición de estado no válida'
            ], 422);
        }

        $pedido->cambiarEstado($request->estado, $request->user()->id, $request->notas);

        match($request->estado) {
            'confirmado' => $pedido->update(['fecha_confirmacion' => now()]),
            'listo' => $pedido->update(['fecha_listo' => now()]),
            'cancelado' => $pedido->update(['fecha_cancelado' => now()]),
            default => null,
        };

        return response()->json([
            'success' => true,
            'data' => new PedidoResource($pedido),
            'message' => 'Estado actualizado exitosamente'
        ]);
    }

    public function asignarRepartidor($id, Request $request)
    {
        $request->validate([
            'tipo' => 'required|in:manual,freelance',
            'repartidor_id' => 'required_if:tipo,manual|exists:repartidores,id',
            'radio_km' => 'nullable|numeric|min:1|max:10'
        ]);

        $pedido = Pedido::findOrFail($id);
        $this->authorize('update', $pedido);

        if ($request->tipo === 'manual') {
            $repartidor = \App\Models\Repartidor::findOrFail($request->repartidor_id);
            
            if (!$repartidor->comercios->contains($pedido->comercio_id)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Repartidor no pertenece a este comercio'
                ], 422);
            }

            $pedido->update(['repartidor_id' => $repartidor->id]);
            
            return response()->json([
                'success' => true,
                'data' => [
                    'pedido_id' => $pedido->id,
                    'repartidor' => [
                        'id' => $repartidor->id,
                        'nombre' => $repartidor->user->name,
                    ],
                    'tipo_asignacion' => 'manual'
                ],
                'message' => 'Repartidor asignado exitosamente'
            ]);
        } else {
            $radio = $request->radio_km ?? 3;
            $direccion = $pedido->direccion_json;
            
            $repartidores = \App\Models\Repartidor::disponibles()
                ->freelance()
                ->cercanos($direccion['lat'], $direccion['lng'], $radio)
                ->get();

            if ($repartidores->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'No hay repartidores disponibles en el área'
                ], 404);
            }

            foreach ($repartidores as $repartidor) {
                \App\Jobs\NotificarPedidoDisponible::dispatch($pedido, $repartidor);
            }

            return response()->json([
                'success' => true,
                'message' => "Pedido enviado a {$repartidores->count()} repartidores",
                'data' => [
                    'repartidores_notificados' => $repartidores->count()
                ]
            ]);
        }
    }

    public function estadisticas(Request $request)
    {
        $comercioId = $request->user()->comercio_id;
        $periodo = $request->get('periodo', 'hoy');

        $query = Pedido::where('comercio_id', $comercioId);

        match($periodo) {
            'hoy' => $query->whereDate('created_at', today()),
            'semana' => $query->whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()]),
            'mes' => $query->whereMonth('created_at', now()->month),
            default => $query->whereDate('created_at', today()),
        };

        $pedidos = $query->get();

        $stats = [
            'ventas' => [
                'total_usd' => $pedidos->sum('total_usd'),
                'total_bs' => $pedidos->sum('total_bs'),
                'total_pedidos' => $pedidos->count(),
                'pedidos_completados' => $pedidos->where('estado', 'entregado')->count(),
                'pedidos_cancelados' => $pedidos->where('estado', 'cancelado')->count(),
                'ticket_promedio_usd' => $pedidos->avg('total_usd'),
            ],
            'productos_mas_vendidos' => $this->getProductosMasVendidos($comercioId, $periodo),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }

    private function getProductosMasVendidos($comercioId, $periodo)
    {
        $query = \App\Models\PedidoItem::whereHas('pedido', function($q) use ($comercioId, $periodo) {
            $q->where('comercio_id', $comercioId);
            
            match($periodo) {
                'hoy' => $q->whereDate('created_at', today()),
                'semana' => $q->whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()]),
                'mes' => $q->whereMonth('created_at', now()->month),
                default => $q->whereDate('created_at', today()),
            };
        });

        return $query->selectRaw('nombre_producto, SUM(cantidad) as cantidad, SUM(subtotal_usd) as total_usd')
            ->groupBy('nombre_producto')
            ->orderByDesc('cantidad')
            ->limit(10)
            ->get();
    }
}
