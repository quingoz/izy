<?php

namespace App\Http\Controllers\Repartidor;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class PerfilController extends Controller
{
    public function updateEstado(Request $request)
    {
        $request->validate([
            'status' => 'required|in:disponible,ocupado,desconectado'
        ]);

        $repartidor = $request->user()->repartidor;

        $repartidor->update([
            'status' => $request->status,
            'last_status_change' => now()
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'status' => $repartidor->status,
                'updated_at' => $repartidor->last_status_change
            ],
            'message' => 'Estado actualizado'
        ]);
    }

    public function estadisticas(Request $request)
    {
        $repartidor = $request->user()->repartidor;
        $periodo = $request->get('periodo', 'hoy');

        $stats = [
            'hoy' => [
                'entregas' => $repartidor->entregas_completadas_hoy,
                'ganancias_usd' => $repartidor->ganancias_hoy_usd,
            ],
            'semana' => [
                'ganancias_usd' => $repartidor->ganancias_semana_usd,
            ],
            'mes' => [
                'ganancias_usd' => $repartidor->ganancias_mes_usd,
            ],
            'totales' => [
                'entregas' => $repartidor->total_entregas,
                'rechazos' => $repartidor->total_rechazos,
                'calificacion_promedio' => $repartidor->calificacion_promedio,
            ],
            'estado_actual' => [
                'status' => $repartidor->status,
                'ubicacion' => [
                    'lat' => $repartidor->current_lat,
                    'lng' => $repartidor->current_lng,
                ],
                'ultima_actualizacion' => $repartidor->last_location_update,
            ]
        ];

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }
}
