<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ProductoResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'nombre' => $this->nombre,
            'descripcion' => $this->descripcion,
            'imagen_url' => $this->imagen_url,
            'precio_usd' => (float) $this->precio_usd,
            'precio_bs' => (float) $this->precio_bs,
            'precio_oferta_usd' => $this->when($this->precio_oferta_usd, (float) $this->precio_oferta_usd),
            'precio_oferta_bs' => $this->when($this->precio_oferta_bs, (float) $this->precio_oferta_bs),
            'stock' => $this->stock,
            'stock_ilimitado' => $this->stock_ilimitado,
            'tiene_variantes' => $this->tiene_variantes,
            'variantes' => $this->when($this->tiene_variantes, $this->variantes_json),
            'is_active' => $this->is_active,
            'is_destacado' => $this->is_destacado,
            'categoria' => $this->when($this->relationLoaded('categoria'), function() {
                return [
                    'id' => $this->categoria->id,
                    'nombre' => $this->categoria->nombre,
                ];
            }),
            'comercio' => $this->when($this->relationLoaded('comercio'), function() {
                return [
                    'id' => $this->comercio->id,
                    'nombre' => $this->comercio->nombre,
                    'slug' => $this->comercio->slug,
                ];
            }),
            'rating' => (float) $this->rating,
            'total_ventas' => $this->total_ventas,
        ];
    }
}
