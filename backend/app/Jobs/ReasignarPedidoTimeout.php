<?php

namespace App\Jobs;

use App\Models\Pedido;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class ReasignarPedidoTimeout implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $pedido;

    public function __construct(Pedido $pedido)
    {
        $this->pedido = $pedido;
    }

    public function handle()
    {
        $pedido = $this->pedido->fresh();

        if ($pedido->repartidor_id) {
            return;
        }

        logger()->warning('Pedido sin asignar después de timeout', [
            'pedido_id' => $pedido->id,
            'tiempo_espera' => '5 minutos'
        ]);

        AsignarRepartidorAutomatico::dispatch($pedido);
    }
}
