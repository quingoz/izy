<?php

use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('pedido.{pedidoId}', function ($user, $pedidoId) {
    $pedido = \App\Models\Pedido::find($pedidoId);
    
    if (!$pedido) {
        return false;
    }

    return $user->id === $pedido->cliente_id
        || $user->comercio_id === $pedido->comercio_id
        || $user->repartidor?->id === $pedido->repartidor_id;
});

Broadcast::channel('comercio.{comercioId}', function ($user, $comercioId) {
    return $user->comercio_id == $comercioId;
});

Broadcast::channel('cliente.{clienteId}', function ($user, $clienteId) {
    return $user->id == $clienteId;
});

Broadcast::channel('repartidor.{repartidorId}', function ($user, $repartidorId) {
    return $user->repartidor?->id == $repartidorId;
});

Broadcast::channel('pedido.{pedidoId}.tracking', function () {
    return true;
});
