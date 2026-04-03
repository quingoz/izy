<?php

namespace Database\Factories;

use App\Models\Categoria;
use App\Models\Comercio;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProductoFactory extends Factory
{
    public function definition(): array
    {
        $precioUsd = fake()->randomFloat(2, 2, 50);
        $precioBs = $precioUsd * fake()->randomFloat(2, 30, 40);

        return [
            'comercio_id' => Comercio::factory(),
            'categoria_id' => Categoria::factory(),
            'nombre' => fake()->words(3, true),
            'descripcion' => fake()->sentence(),
            'precio_usd' => $precioUsd,
            'precio_bs' => $precioBs,
            'stock' => fake()->numberBetween(0, 100),
            'stock_ilimitado' => fake()->boolean(30),
            'stock_minimo' => 5,
            'tiene_variantes' => fake()->boolean(20),
            'is_active' => true,
            'is_destacado' => fake()->boolean(30),
            'rating' => fake()->randomFloat(2, 3.5, 5.0),
        ];
    }
}
