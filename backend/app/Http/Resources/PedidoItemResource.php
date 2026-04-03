<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class PedidoItemResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'producto_id' => $this->producto_id,
            'nombre_producto' => $this->nombre_producto,
            'cantidad' => $this->cantidad,
            'precio_unitario_usd' => (float) $this->precio_unitario_usd,
            'precio_unitario_bs' => (float) $this->precio_unitario_bs,
            'subtotal_usd' => (float) $this->subtotal_usd,
            'subtotal_bs' => (float) $this->subtotal_bs,
            'variantes' => $this->variantes_json,
            'notas' => $this->notas,
        ];
    }
}
