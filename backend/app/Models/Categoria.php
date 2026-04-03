<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Categoria extends Model
{
    use BelongsToTenant, HasFactory;

    protected $fillable = [
        'comercio_id', 'nombre', 'descripcion', 'icono', 'orden', 'is_active'
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }

    public function productos()
    {
        return $this->hasMany(Producto::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeOrdenado($query)
    {
        return $query->orderBy('orden');
    }
}
