<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class DireccionFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'alias' => fake()->randomElement(['Casa', 'Trabajo', 'Oficina']),
            'calle' => fake()->streetAddress(),
            'ciudad' => fake()->city(),
            'estado' => fake()->state(),
            'codigo_postal' => fake()->postcode(),
            'referencia' => fake()->sentence(),
            'lat' => fake()->latitude(8, 11),
            'lng' => fake()->longitude(-72, -60),
            'is_default' => fake()->boolean(30),
        ];
    }
}
