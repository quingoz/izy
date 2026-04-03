<?php

namespace App\Observers;

use App\Events\PedidoAsignado;
use App\Events\PedidoEstadoActualizado;
use App\Models\Pedido;

class PedidoObserver
{
    public function updated(Pedido $pedido)
    {
        if ($pedido->isDirty('estado')) {
            broadcast(new PedidoEstadoActualizado($pedido))->toOthers();
        }

        if ($pedido->isDirty('repartidor_id') && $pedido->repartidor_id) {
            broadcast(new PedidoAsignado($pedido))->toOthers();
        }
    }
}
