<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Configuracion extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $table = 'configuraciones';

    protected $fillable = [
        'clave', 'valor', 'tipo', 'descripcion'
    ];

    protected function casts(): array
    {
        return [
            'updated_at' => 'datetime',
        ];
    }

    public static function get($clave, $default = null)
    {
        $config = self::where('clave', $clave)->first();
        
        if (!$config) {
            return $default;
        }

        return match($config->tipo) {
            'number' => (float) $config->valor,
            'boolean' => filter_var($config->valor, FILTER_VALIDATE_BOOLEAN),
            'json' => json_decode($config->valor, true),
            default => $config->valor,
        };
    }

    public static function set($clave, $valor, $tipo = 'string', $descripcion = null)
    {
        $valorString = is_array($valor) ? json_encode($valor) : (string) $valor;

        return self::updateOrCreate(
            ['clave' => $clave],
            [
                'valor' => $valorString,
                'tipo' => $tipo,
                'descripcion' => $descripcion
            ]
        );
    }
}
