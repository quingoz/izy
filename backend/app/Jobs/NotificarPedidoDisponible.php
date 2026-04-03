<?php

namespace App\Jobs;

use App\Models\Pedido;
use App\Models\Repartidor;
use App\Services\FCMService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class NotificarPedidoDisponible implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $pedido;
    public $repartidor;

    public function __construct(Pedido $pedido, Repartidor $repartidor)
    {
        $this->pedido = $pedido;
        $this->repartidor = $repartidor;
        $this->onQueue('notifications');
    }

    public function handle(FCMService $fcm)
    {
        $fcm->sendToUser(
            $this->repartidor->user_id,
            '🚀 Nuevo Pedido Disponible',
            "Pedido #{$this->pedido->numero_pedido} - \${$this->pedido->total_usd}",
            [
                'type' => 'pedido_disponible',
                'pedido_id' => $this->pedido->id,
                'comercio' => $this->pedido->comercio->nombre,
                'action' => 'open_pedido_disponible'
            ]
        );
    }
}
