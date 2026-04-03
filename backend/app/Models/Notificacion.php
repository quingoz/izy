<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notificacion extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $table = 'notificaciones';

    protected $fillable = [
        'user_id', 'tipo', 'titulo', 'mensaje', 'data_json',
        'leida', 'fecha_lectura', 'enviada_push', 'fecha_envio_push'
    ];

    protected function casts(): array
    {
        return [
            'data_json' => 'array',
            'leida' => 'boolean',
            'enviada_push' => 'boolean',
            'fecha_lectura' => 'datetime',
            'fecha_envio_push' => 'datetime',
            'created_at' => 'datetime',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeNoLeidas($query)
    {
        return $query->where('leida', false);
    }

    public function marcarComoLeida()
    {
        $this->update([
            'leida' => true,
            'fecha_lectura' => now()
        ]);
    }
}
