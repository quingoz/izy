<?php

namespace App\Policies;

use App\Models\Pedido;
use App\Models\User;

class PedidoPolicy
{
    public function view(User $user, Pedido $pedido)
    {
        return match($user->role) {
            'cliente' => $user->id === $pedido->cliente_id,
            'comercio' => $user->comercio_id === $pedido->comercio_id,
            'repartidor' => $user->repartidor?->id === $pedido->repartidor_id,
            'admin' => true,
            default => false,
        };
    }

    public function update(User $user, Pedido $pedido)
    {
        return match($user->role) {
            'comercio' => $user->comercio_id === $pedido->comercio_id,
            'repartidor' => $user->repartidor?->id === $pedido->repartidor_id,
            'admin' => true,
            default => false,
        };
    }

    public function cancel(User $user, Pedido $pedido)
    {
        if ($user->role === 'cliente' && $user->id === $pedido->cliente_id) {
            return in_array($pedido->estado, ['pendiente', 'confirmado']);
        }
        
        if ($user->role === 'comercio' && $user->comercio_id === $pedido->comercio_id) {
            return in_array($pedido->estado, ['pendiente', 'confirmado', 'preparando']);
        }
        
        return false;
    }
}
