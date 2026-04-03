<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ComercioResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'slug' => $this->slug,
            'nombre' => $this->nombre,
            'descripcion' => $this->descripcion,
            'categoria' => $this->categoria,
            'logo_url' => $this->logo_url,
            'banner_url' => $this->banner_url,
            'branding' => $this->branding_json,
            'ubicacion' => [
                'lat' => (float) $this->lat,
                'lng' => (float) $this->lng,
                'direccion' => $this->direccion,
                'ciudad' => $this->ciudad,
                'estado' => $this->estado,
            ],
            'contacto' => [
                'telefono' => $this->telefono,
                'email' => $this->email,
                'whatsapp' => $this->whatsapp,
            ],
            'configuracion' => [
                'radio_entrega_km' => (float) $this->radio_entrega_km,
                'tiempo_preparacion_min' => $this->tiempo_preparacion_min,
                'delivery_fee_usd' => (float) $this->delivery_fee_usd,
                'delivery_fee_bs' => (float) $this->delivery_fee_bs,
                'pedido_minimo_usd' => (float) $this->pedido_minimo_usd,
                'pedido_minimo_bs' => (float) $this->pedido_minimo_bs,
            ],
            'metodos_pago' => [
                'efectivo' => $this->acepta_efectivo,
                'pago_movil' => $this->acepta_pago_movil,
                'transferencia' => $this->acepta_transferencia,
                'tarjeta' => $this->acepta_tarjeta,
            ],
            'horarios' => $this->horarios_json,
            'is_active' => $this->is_active,
            'is_open' => $this->is_open,
            'rating' => (float) $this->rating,
            'total_reviews' => $this->total_reviews,
            'distancia_km' => $this->when(isset($this->distancia_km), $this->distancia_km),
            'tiempo_estimado_min' => $this->when(isset($this->tiempo_estimado_min), $this->tiempo_estimado_min),
        ];
    }
}
