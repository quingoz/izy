<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Repartidor extends Model
{
    use HasFactory;

    protected $table = 'repartidores';

    protected $fillable = [
        'user_id', 'is_freelance',
        'current_lat', 'current_lng', 'last_location_update',
        'status', 'vehiculo_tipo', 'placa_vehiculo', 'color_vehiculo',
        'cedula', 'licencia_conducir',
        'radio_trabajo_km', 'acepta_pedidos', 'is_active'
    ];

    protected function casts(): array
    {
        return [
            'is_freelance' => 'boolean',
            'is_active' => 'boolean',
            'acepta_pedidos' => 'boolean',
            'last_location_update' => 'datetime',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function comercios()
    {
        return $this->belongsToMany(Comercio::class, 'comercio_repartidor')
                    ->withPivot('comision_porcentaje', 'prioridad', 'is_active')
                    ->withTimestamps();
    }

    public function pedidos()
    {
        return $this->hasMany(Pedido::class);
    }

    public function ubicaciones()
    {
        return $this->hasMany(RepartidorUbicacion::class);
    }

    public function scopeDisponibles($query)
    {
        return $query->where('status', 'disponible')
                     ->where('acepta_pedidos', true)
                     ->where('is_active', true);
    }

    public function scopeFreelance($query)
    {
        return $query->where('is_freelance', true);
    }

    public function scopeCercanos($query, $lat, $lng, $radio = 3)
    {
        return $query->whereRaw("
            (6371 * acos(
                cos(radians(?)) * cos(radians(current_lat)) *
                cos(radians(current_lng) - radians(?)) +
                sin(radians(?)) * sin(radians(current_lat))
            )) <= ?
        ", [$lat, $lng, $lat, $radio]);
    }

    public function updateLocation($lat, $lng, $pedidoId = null)
    {
        $this->update([
            'current_lat' => $lat,
            'current_lng' => $lng,
            'last_location_update' => now()
        ]);

        RepartidorUbicacion::create([
            'repartidor_id' => $this->id,
            'pedido_id' => $pedidoId,
            'lat' => $lat,
            'lng' => $lng
        ]);
    }

    public function isAvailable()
    {
        return $this->status === 'disponible' && 
               $this->acepta_pedidos && 
               $this->is_active;
    }
}
