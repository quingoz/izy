<?php

namespace App\Listeners;

use App\Events\PedidoEstadoActualizado;
use App\Jobs\SendPushNotification;

class EnviarNotificacionNuevoPedido
{
    public function handle(PedidoEstadoActualizado $event)
    {
        $pedido = $event->pedido;

        match($pedido->estado) {
            'pendiente' => $this->notificarComercio($pedido),
            'confirmado' => $this->notificarCliente($pedido, 'Pedido confirmado', 'Tu pedido está siendo preparado'),
            'listo' => $this->notificarRepartidor($pedido),
            'en_camino' => $this->notificarCliente($pedido, 'Pedido en camino', 'Tu pedido está en camino'),
            'entregado' => $this->notificarClienteYComercio($pedido),
            default => null,
        };
    }

    private function notificarComercio($pedido)
    {
        $comercio = $pedido->comercio;
        $admin = $comercio->users()->where('role', 'comercio')->first();

        if ($admin) {
            SendPushNotification::dispatch(
                $admin->id,
                '🔔 Nuevo Pedido',
                "Pedido #{$pedido->numero_pedido} - Total: \${$pedido->total_usd}",
                [
                    'type' => 'nuevo_pedido',
                    'pedido_id' => $pedido->id,
                    'action' => 'open_pedido'
                ]
            );
        }
    }

    private function notificarCliente($pedido, $title, $body)
    {
        SendPushNotification::dispatch(
            $pedido->cliente_id,
            $title,
            $body,
            [
                'type' => 'pedido_actualizado',
                'pedido_id' => $pedido->id,
                'estado' => $pedido->estado,
                'action' => 'open_tracking'
            ]
        );
    }

    private function notificarRepartidor($pedido)
    {
        if ($pedido->repartidor_id) {
            SendPushNotification::dispatch(
                $pedido->repartidor->user_id,
                '📦 Pedido Listo',
                "Pedido #{$pedido->numero_pedido} listo para recoger",
                [
                    'type' => 'pedido_listo',
                    'pedido_id' => $pedido->id,
                    'action' => 'open_pedido'
                ]
            );
        }
    }

    private function notificarClienteYComercio($pedido)
    {
        $this->notificarCliente($pedido, '✅ Pedido Entregado', 'Tu pedido ha sido entregado');
        
        $comercio = $pedido->comercio;
        $admin = $comercio->users()->where('role', 'comercio')->first();
        
        if ($admin) {
            SendPushNotification::dispatch(
                $admin->id,
                'Pedido Completado',
                "Pedido #{$pedido->numero_pedido} entregado exitosamente",
                ['type' => 'pedido_completado', 'pedido_id' => $pedido->id]
            );
        }
    }
}
