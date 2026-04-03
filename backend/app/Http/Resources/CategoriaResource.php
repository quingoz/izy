<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class CategoriaResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'nombre' => $this->nombre,
            'descripcion' => $this->descripcion,
            'icono' => $this->icono,
            'orden' => $this->orden,
            'productos_count' => $this->when($this->relationLoaded('productos'), $this->productos->count()),
        ];
    }
}
