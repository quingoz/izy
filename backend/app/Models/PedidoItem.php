<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PedidoItem extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'pedido_id', 'producto_id', 'nombre_producto',
        'cantidad', 'precio_unitario_usd', 'precio_unitario_bs',
        'subtotal_usd', 'subtotal_bs', 'variantes_json', 'notas'
    ];

    protected function casts(): array
    {
        return [
            'variantes_json' => 'array',
            'created_at' => 'datetime',
        ];
    }

    public function pedido()
    {
        return $this->belongsTo(Pedido::class);
    }

    public function producto()
    {
        return $this->belongsTo(Producto::class);
    }
}
