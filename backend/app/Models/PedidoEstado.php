<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PedidoEstado extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'pedido_id', 'estado_anterior', 'estado_nuevo',
        'user_id', 'user_role', 'notas', 'metadata_json'
    ];

    protected function casts(): array
    {
        return [
            'metadata_json' => 'array',
            'created_at' => 'datetime',
        ];
    }

    public function pedido()
    {
        return $this->belongsTo(Pedido::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
