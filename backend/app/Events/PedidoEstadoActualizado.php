<?php

namespace App\Events;

use App\Models\Pedido;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Queue\SerializesModels;

class PedidoEstadoActualizado implements ShouldBroadcast
{
    use InteractsWithSockets, SerializesModels;

    public $pedido;

    public function __construct(Pedido $pedido)
    {
        $this->pedido = $pedido;
    }

    public function broadcastOn()
    {
        return [
            new Channel('pedido.' . $this->pedido->id),
            new Channel('comercio.' . $this->pedido->comercio_id),
            new Channel('cliente.' . $this->pedido->cliente_id),
        ];
    }

    public function broadcastWith()
    {
        return [
            'pedido_id' => $this->pedido->id,
            'numero_pedido' => $this->pedido->numero_pedido,
            'estado' => $this->pedido->estado,
            'timestamp' => now()->toIso8601String(),
        ];
    }

    public function broadcastAs()
    {
        return 'pedido.estado.actualizado';
    }
}
