<?php

namespace App\Jobs;

use App\Models\Pedido;
use App\Notifications\NuevoPedidoComercio;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class ProcessPedido implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $pedido;

    public function __construct(Pedido $pedido)
    {
        $this->pedido = $pedido;
    }

    public function handle()
    {
        $comercio = $this->pedido->comercio;
        $adminComercio = $comercio->users()->where('role', 'comercio')->first();
        
        if ($adminComercio && $adminComercio->fcm_token) {
        }

        logger()->info('Nuevo pedido creado', [
            'pedido_id' => $this->pedido->id,
            'numero_pedido' => $this->pedido->numero_pedido,
            'comercio_id' => $this->pedido->comercio_id,
            'total_usd' => $this->pedido->total_usd,
        ]);
    }
}
