<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name', 'email', 'phone', 'password', 'role', 
        'comercio_id', 'fcm_token', 'avatar_url', 'last_login_at'
    ];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'phone_verified_at' => 'datetime',
            'last_login_at' => 'datetime',
            'is_active' => 'boolean',
            'password' => 'hashed',
        ];
    }

    public function comercio()
    {
        return $this->belongsTo(Comercio::class);
    }

    public function repartidor()
    {
        return $this->hasOne(Repartidor::class);
    }

    public function pedidos()
    {
        return $this->hasMany(Pedido::class, 'cliente_id');
    }

    public function direcciones()
    {
        return $this->hasMany(Direccion::class);
    }

    public function notificaciones()
    {
        return $this->hasMany(Notificacion::class);
    }

    public function scopeByRole($query, $role)
    {
        return $query->where('role', $role);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function isCliente()
    {
        return $this->role === 'cliente';
    }

    public function isComercio()
    {
        return $this->role === 'comercio';
    }

    public function isRepartidor()
    {
        return $this->role === 'repartidor';
    }
}
