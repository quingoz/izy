<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Queue\SerializesModels;

class RepartidorUbicacionActualizada implements ShouldBroadcast
{
    use InteractsWithSockets, SerializesModels;

    public $pedidoId;
    public $lat;
    public $lng;

    public function __construct($pedidoId, $lat, $lng)
    {
        $this->pedidoId = $pedidoId;
        $this->lat = $lat;
        $this->lng = $lng;
    }

    public function broadcastOn()
    {
        return new Channel('pedido.' . $this->pedidoId . '.tracking');
    }

    public function broadcastWith()
    {
        return [
            'lat' => $this->lat,
            'lng' => $this->lng,
            'timestamp' => now()->toIso8601String(),
        ];
    }

    public function broadcastAs()
    {
        return 'repartidor.ubicacion.actualizada';
    }
}
