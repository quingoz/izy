<?php

namespace Database\Factories;

use App\Models\Comercio;
use App\Models\Repartidor;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class PedidoFactory extends Factory
{
    public function definition(): array
    {
        $subtotalUsd = fake()->randomFloat(2, 10, 100);
        $subtotalBs = $subtotalUsd * fake()->randomFloat(2, 30, 40);
        $deliveryUsd = fake()->randomFloat(2, 2, 5);
        $deliveryBs = $deliveryUsd * fake()->randomFloat(2, 30, 40);

        return [
            'comercio_id' => Comercio::factory(),
            'cliente_id' => User::factory(),
            'repartidor_id' => null,
            'estado' => fake()->randomElement(['pendiente', 'confirmado', 'preparando', 'en_camino', 'entregado']),
            'subtotal_usd' => $subtotalUsd,
            'subtotal_bs' => $subtotalBs,
            'delivery_fee_usd' => $deliveryUsd,
            'delivery_fee_bs' => $deliveryBs,
            'total_usd' => $subtotalUsd + $deliveryUsd,
            'total_bs' => $subtotalBs + $deliveryBs,
            'tipo_pago' => fake()->randomElement(['efectivo', 'pago_movil', 'transferencia']),
            'direccion_json' => [
                'calle' => fake()->streetAddress(),
                'ciudad' => fake()->city(),
                'referencia' => fake()->sentence()
            ],
            'tiempo_estimado_minutos' => fake()->numberBetween(30, 60),
        ];
    }
}
