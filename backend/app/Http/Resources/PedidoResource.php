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
