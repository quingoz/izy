<?php

namespace Database\Factories;

use App\Models\Comercio;
use Illuminate\Database\Eloquent\Factories\Factory;

class CategoriaFactory extends Factory
{
    public function definition(): array
    {
        return [
            'comercio_id' => Comercio::factory(),
            'nombre' => fake()->word(),
            'descripcion' => fake()->sentence(),
            'icono' => fake()->randomElement(['pizza', 'burger', 'coffee', 'cake', 'beer']),
            'orden' => fake()->numberBetween(1, 10),
            'is_active' => true,
        ];
    }
}
