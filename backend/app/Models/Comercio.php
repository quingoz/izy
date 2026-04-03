<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Comercio extends Model
{
    use HasFactory;

    protected $fillable = [
        'slug', 'nombre', 'descripcion', 'categoria',
        'branding_json', 'logo_url', 'banner_url',
        'lat', 'lng', 'direccion', 'ciudad', 'estado',
        'telefono', 'email', 'whatsapp',
        'horarios_json', 'radio_entrega_km', 'tiempo_preparacion_min',
        'delivery_fee_usd', 'delivery_fee_bs',
        'pedido_minimo_usd', 'pedido_minimo_bs',
        'acepta_efectivo', 'acepta_pago_movil', 'acepta_transferencia', 'acepta_tarjeta',
        'is_active', 'is_open'
    ];

    protected function casts(): array
    {
        return [
            'branding_json' => 'array',
            'horarios_json' => 'array',
            'lat' => 'decimal:8',
            'lng' => 'decimal:8',
            'is_active' => 'boolean',
            'is_open' => 'boolean',
            'acepta_efectivo' => 'boolean',
            'acepta_pago_movil' => 'boolean',
            'acepta_transferencia' => 'boolean',
            'acepta_tarjeta' => 'boolean',
        ];
    }

    public function productos()
    {
        return $this->hasMany(Producto::class);
    }

    public function categorias()
    {
        return $this->hasMany(Categoria::class);
    }

    public function pedidos()
    {
        return $this->hasMany(Pedido::class);
    }

    public function repartidores()
    {
        return $this->belongsToMany(Repartidor::class, 'comercio_repartidor')
                    ->withPivot('comision_porcentaje', 'prioridad', 'is_active')
                    ->withTimestamps();
    }

    public function users()
    {
        return $this->hasMany(User::class);
    }

    public function isOpen()
    {
        return $this->is_open && $this->is_active;
    }

    public function getDistanceTo($lat, $lng)
    {
        $earthRadius = 6371;
        $dLat = deg2rad($lat - $this->lat);
        $dLng = deg2rad($lng - $this->lng);
        
        $a = sin($dLat/2) * sin($dLat/2) +
             cos(deg2rad($this->lat)) * cos(deg2rad($lat)) *
             sin($dLng/2) * sin($dLng/2);
        
        $c = 2 * atan2(sqrt($a), sqrt(1-$a));
        
        return $earthRadius * $c;
    }

    public function canDeliver($lat, $lng)
    {
        $distance = $this->getDistanceTo($lat, $lng);
        return $distance <= $this->radio_entrega_km;
    }
}
