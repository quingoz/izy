<?php

namespace App\Jobs;

use App\Models\Pedido;
use App\Models\Repartidor;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class AsignarRepartidorAutomatico implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $pedido;
    public $timeout = 300;

    public function __construct(Pedido $pedido)
    {
        $this->pedido = $pedido;
    }

    public function handle()
    {
        $repartidoresExclusivos = $this->pedido->comercio->repartidores()
            ->wherePivot('is_active', true)
            ->where('status', 'disponible')
            ->orderBy('comercio_repartidor.prioridad')
            ->get();

        if ($repartidoresExclusivos->isNotEmpty()) {
            $repartidor = $repartidoresExclusivos->first();
            $this->asignar($repartidor);
            return;
        }

        $direccion = $this->pedido->direccion_json;
        $repartidoresFreelance = Repartidor::disponibles()
            ->freelance()
            ->cercanos($direccion['lat'], $direccion['lng'], 3)
            ->get();

        if ($repartidoresFreelance->isEmpty()) {
            logger()->warning('No hay repartidores disponibles', [
                'pedido_id' => $this->pedido->id
            ]);
            return;
        }

        foreach ($repartidoresFreelance as $repartidor) {
            NotificarPedidoDisponible::dispatch($this->pedido, $repartidor);
        }

        ReasignarPedidoTimeout::dispatch($this->pedido)
            ->delay(now()->addSeconds($this->timeout));
    }

    private function asignar(Repartidor $repartidor)
    {
        $this->pedido->update(['repartidor_id' => $repartidor->id]);
        $repartidor->update(['status' => 'ocupado']);
        
        SendPushNotification::dispatch(
            $repartidor->user_id,
            'Nuevo Pedido Asignado',
            "Pedido #{$this->pedido->numero_pedido}"
        );
    }
}
