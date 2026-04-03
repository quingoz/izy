<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class RepartidorFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'is_freelance' => fake()->boolean(40),
            'current_lat' => fake()->latitude(8, 11),
            'current_lng' => fake()->longitude(-72, -60),
            'last_location_update' => now(),
            'status' => fake()->randomElement(['disponible', 'ocupado', 'offline']),
            'vehiculo_tipo' => fake()->randomElement(['moto', 'bicicleta', 'auto', 'pie']),
            'placa_vehiculo' => fake()->bothify('???-###'),
            'color_vehiculo' => fake()->safeColorName(),
            'cedula' => fake()->numerify('V-########'),
            'radio_trabajo_km' => fake()->randomFloat(2, 2, 5),
            'acepta_pedidos' => true,
            'is_active' => true,
            'rating' => fake()->randomFloat(2, 4.0, 5.0),
            'total_entregas' => fake()->numberBetween(0, 500),
        ];
    }
}
