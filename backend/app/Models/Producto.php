<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Producto extends Model
{
    use BelongsToTenant, HasFactory;

    protected $fillable = [
        'comercio_id', 'categoria_id', 'nombre', 'descripcion', 'imagen_url',
        'precio_usd', 'precio_bs', 'precio_oferta_usd', 'precio_oferta_bs',
        'stock', 'stock_ilimitado', 'stock_minimo',
        'tiene_variantes', 'variantes_json',
        'is_active', 'is_destacado',
        'disponible_desde', 'disponible_hasta'
    ];

    protected function casts(): array
    {
        return [
            'variantes_json' => 'array',
            'is_active' => 'boolean',
            'is_destacado' => 'boolean',
            'stock_ilimitado' => 'boolean',
            'tiene_variantes' => 'boolean',
        ];
    }

    public function categoria()
    {
        return $this->belongsTo(Categoria::class);
    }

    public function pedidoItems()
    {
        return $this->hasMany(PedidoItem::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeDestacados($query)
    {
        return $query->where('is_destacado', true);
    }

    public function scopeConStock($query)
    {
        return $query->where(function($q) {
            $q->where('stock_ilimitado', true)
              ->orWhere('stock', '>', 0);
        });
    }

    public function hasStock($cantidad = 1)
    {
        return $this->stock_ilimitado || $this->stock >= $cantidad;
    }

    public function decrementStock($cantidad)
    {
        if (!$this->stock_ilimitado) {
            $this->decrement('stock', $cantidad);
        }
    }

    public function getPrecioFinal($moneda = 'usd')
    {
        $campo = $moneda === 'usd' ? 'precio_usd' : 'precio_bs';
        $campoOferta = $moneda === 'usd' ? 'precio_oferta_usd' : 'precio_oferta_bs';
        
        return $this->$campoOferta ?? $this->$campo;
    }
}
