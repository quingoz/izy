<?php

namespace App\Events;

use App\Models\Pedido;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Queue\SerializesModels;

class PedidoAsignado implements ShouldBroadcast
{
    use InteractsWithSockets, SerializesModels;

    public $pedido;

    public function __construct(Pedido $pedido)
    {
        $this->pedido = $pedido->load('repartidor.user');
    }

    public function broadcastOn()
    {
        return [
            new Channel('pedido.' . $this->pedido->id),
            new Channel('repartidor.' . $this->pedido->repartidor_id),
        ];
    }

    public function broadcastWith()
    {
        return [
            'pedido_id' => $this->pedido->id,
            'repartidor' => [
                'id' => $this->pedido->repartidor->id,
                'nombre' => $this->pedido->repartidor->user->name,
            ],
        ];
    }

    public function broadcastAs()
    {
        return 'pedido.asignado';
    }
}
