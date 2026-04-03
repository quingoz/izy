<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RepartidorUbicacion extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $table = 'repartidor_ubicaciones';

    protected $fillable = [
        'repartidor_id', 'pedido_id', 'lat', 'lng', 'accuracy', 'speed'
    ];

    protected function casts(): array
    {
        return [
            'lat' => 'decimal:8',
            'lng' => 'decimal:8',
            'created_at' => 'datetime',
        ];
    }

    public function repartidor()
    {
        return $this->belongsTo(Repartidor::class);
    }

    public function pedido()
    {
        return $this->belongsTo(Pedido::class);
    }
}
