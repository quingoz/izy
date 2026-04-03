<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Pedido extends Model
{
    use BelongsToTenant, HasFactory;

    protected $fillable = [
        'comercio_id', 'cliente_id', 'repartidor_id',
        'numero_pedido', 'token_seguimiento', 'estado',
        'subtotal_usd', 'subtotal_bs',
        'delivery_fee_usd', 'delivery_fee_bs',
        'descuento_usd', 'descuento_bs',
        'total_usd', 'total_bs',
        'tipo_pago', 'vuelto_de', 'pago_movil_json', 'comprobante_url', 'pago_verificado',
        'direccion_json', 'tiempo_estimado_minutos',
        'notas_cliente', 'notas_comercio', 'razon_cancelacion',
        'rating_comercio', 'rating_repartidor', 'comentario_rating'
    ];

    protected function casts(): array
    {
        return [
            'pago_movil_json' => 'array',
            'direccion_json' => 'array',
            'pago_verificado' => 'boolean',
            'fecha_confirmacion' => 'datetime',
            'fecha_listo' => 'datetime',
            'fecha_en_camino' => 'datetime',
            'fecha_entregado' => 'datetime',
            'fecha_cancelado' => 'datetime',
        ];
    }

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($pedido) {
            $pedido->numero_pedido = self::generarNumeroPedido();
            $pedido->token_seguimiento = Str::random(64);
        });
    }

    public function cliente()
    {
        return $this->belongsTo(User::class, 'cliente_id');
    }

    public function repartidor()
    {
        return $this->belongsTo(Repartidor::class);
    }

    public function items()
    {
        return $this->hasMany(PedidoItem::class);
    }

    public function estados()
    {
        return $this->hasMany(PedidoEstado::class);
    }

    public static function generarNumeroPedido()
    {
        $fecha = now()->format('Ymd');
        $ultimo = self::whereDate('created_at', today())->count() + 1;
        return sprintf('IZY-%s-%04d', $fecha, $ultimo);
    }

    public function calcularTotal()
    {
        $this->total_usd = $this->subtotal_usd + $this->delivery_fee_usd - $this->descuento_usd;
        $this->total_bs = $this->subtotal_bs + $this->delivery_fee_bs - $this->descuento_bs;
    }

    public function cambiarEstado($nuevoEstado, $userId = null, $notas = null)
    {
        $estadoAnterior = $this->estado;
        $this->estado = $nuevoEstado;
        $this->save();

        PedidoEstado::create([
            'pedido_id' => $this->id,
            'estado_anterior' => $estadoAnterior,
            'estado_nuevo' => $nuevoEstado,
            'user_id' => $userId,
            'notas' => $notas
        ]);
    }
}
