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

        $repartidor->updateLocation(
            $request->lat,
            $request->lng,
            $request->pedido_id
        );

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
