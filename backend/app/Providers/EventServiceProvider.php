<?php

namespace App\Providers;

use App\Events\PedidoEstadoActualizado;
use App\Listeners\EnviarNotificacionNuevoPedido;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

class EventServiceProvider extends ServiceProvider
{
    protected $listen = [
        PedidoEstadoActualizado::class => [
            EnviarNotificacionNuevoPedido::class,
        ],
    ];

    public function boot(): void
    {
        //
    }

    public function shouldDiscoverEvents(): bool
    {
        return false;
    }
}
