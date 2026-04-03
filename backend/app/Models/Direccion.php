<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Direccion extends Model
{
    use HasFactory;

    protected $table = 'direcciones';

    protected $fillable = [
        'user_id', 'alias', 'calle', 'ciudad', 'estado',
        'codigo_postal', 'referencia', 'lat', 'lng', 'is_default'
    ];

    protected function casts(): array
    {
        return [
            'is_default' => 'boolean',
            'lat' => 'decimal:8',
            'lng' => 'decimal:8',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeDefault($query)
    {
        return $query->where('is_default', true);
    }
}
