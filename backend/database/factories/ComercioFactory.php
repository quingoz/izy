<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class ComercioFactory extends Factory
{
    public function definition(): array
    {
        return [
            'slug' => fake()->unique()->slug(),
            'nombre' => fake()->company(),
            'descripcion' => fake()->paragraph(),
            'categoria' => fake()->randomElement(['restaurante', 'farmacia', 'supermercado', 'licoreria', 'otro']),
            'lat' => fake()->latitude(8, 11),
            'lng' => fake()->longitude(-72, -60),
            'direccion' => fake()->address(),
            'ciudad' => fake()->city(),
            'estado' => fake()->state(),
            'telefono' => fake()->phoneNumber(),
            'email' => fake()->companyEmail(),
            'whatsapp' => fake()->phoneNumber(),
            'radio_entrega_km' => fake()->randomFloat(2, 3, 10),
            'tiempo_preparacion_min' => fake()->numberBetween(20, 60),
            'delivery_fee_usd' => fake()->randomFloat(2, 1, 5),
            'delivery_fee_bs' => fake()->randomFloat(2, 0, 100),
            'pedido_minimo_usd' => fake()->randomFloat(2, 3, 15),
            'pedido_minimo_bs' => fake()->randomFloat(2, 0, 300),
            'acepta_efectivo' => true,
            'acepta_pago_movil' => true,
            'acepta_transferencia' => fake()->boolean(),
            'acepta_tarjeta' => fake()->boolean(),
            'is_active' => true,
            'is_open' => fake()->boolean(70),
            'rating' => fake()->randomFloat(2, 3.5, 5.0),
        ];
    }
}
