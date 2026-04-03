<?php

namespace App\Providers;

use App\Models\Pedido;
use App\Models\Producto;
use App\Policies\PedidoPolicy;
use App\Policies\ProductoPolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        Producto::class => ProductoPolicy::class,
        Pedido::class => PedidoPolicy::class,
    ];

    public function boot(): void
    {
        $this->registerPolicies();
    }
}
