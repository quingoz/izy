<?php

namespace Database\Seeders;

use App\Models\Categoria;
use App\Models\Comercio;
use App\Models\Producto;
use Illuminate\Database\Seeder;

class ComercioSeeder extends Seeder
{
    public function run()
    {
        $pizzeria = Comercio::create([
            'slug' => 'pizzeria-express',
            'nombre' => 'Pizzería Express',
            'descripcion' => 'Las mejores pizzas de la ciudad',
            'categoria' => 'restaurante',
            'branding_json' => [
                'colors' => [
                    'primary' => '#1B3A57',
                    'secondary' => '#5FD4A0',
                    'accent' => '#4CAF50',
                ],
                'theme' => 'light'
            ],
            'logo_url' => 'https://via.placeholder.com/150',
            'lat' => 10.4806,
            'lng' => -66.8037,
            'direccion' => 'Av. Principal de Los Ruices',
            'ciudad' => 'Caracas',
            'estado' => 'Miranda',
            'telefono' => '+58212123456',
            'email' => 'info@pizzeriaexpress.com',
            'is_active' => true,
            'is_open' => true,
            'radio_entrega_km' => 5,
            'tiempo_preparacion_min' => 30,
            'delivery_fee_usd' => 2,
            'delivery_fee_bs' => 70,
            'pedido_minimo_usd' => 5,
            'pedido_minimo_bs' => 175,
            'acepta_efectivo' => true,
            'acepta_pago_movil' => true,
            'acepta_transferencia' => true,
            'horarios_json' => [
                'lunes' => ['apertura' => '11:00', 'cierre' => '22:00'],
                'martes' => ['apertura' => '11:00', 'cierre' => '22:00'],
                'miercoles' => ['apertura' => '11:00', 'cierre' => '22:00'],
                'jueves' => ['apertura' => '11:00', 'cierre' => '22:00'],
                'viernes' => ['apertura' => '11:00', 'cierre' => '23:00'],
                'sabado' => ['apertura' => '12:00', 'cierre' => '23:00'],
                'domingo' => ['apertura' => '12:00', 'cierre' => '21:00'],
            ]
        ]);

        $categoriaPizzas = Categoria::create([
            'comercio_id' => $pizzeria->id,
            'nombre' => 'Pizzas',
            'descripcion' => 'Pizzas artesanales',
            'icono' => '🍕',
            'orden' => 1,
            'is_active' => true
        ]);

        $categoriaBebidas = Categoria::create([
            'comercio_id' => $pizzeria->id,
            'nombre' => 'Bebidas',
            'descripcion' => 'Refrescos y jugos',
            'icono' => '🥤',
            'orden' => 2,
            'is_active' => true
        ]);

        Producto::create([
            'comercio_id' => $pizzeria->id,
            'categoria_id' => $categoriaPizzas->id,
            'nombre' => 'Pizza Margarita',
            'descripcion' => 'Salsa de tomate, mozzarella y albahaca fresca',
            'imagen_url' => 'https://via.placeholder.com/300',
            'precio_usd' => 8,
            'precio_bs' => 280,
            'stock' => 50,
            'stock_ilimitado' => true,
            'is_active' => true,
            'is_destacado' => true,
        ]);

        Producto::create([
            'comercio_id' => $pizzeria->id,
            'categoria_id' => $categoriaPizzas->id,
            'nombre' => 'Pizza Pepperoni',
            'descripcion' => 'Salsa de tomate, mozzarella y pepperoni',
            'imagen_url' => 'https://via.placeholder.com/300',
            'precio_usd' => 10,
            'precio_bs' => 350,
            'stock' => 50,
            'stock_ilimitado' => true,
            'is_active' => true,
            'is_destacado' => true,
        ]);

        Producto::create([
            'comercio_id' => $pizzeria->id,
            'categoria_id' => $categoriaBebidas->id,
            'nombre' => 'Coca Cola 1L',
            'descripcion' => 'Refresco de cola',
            'imagen_url' => 'https://via.placeholder.com/300',
            'precio_usd' => 2,
            'precio_bs' => 70,
            'stock' => 100,
            'is_active' => true,
        ]);

        $burguer = Comercio::create([
            'slug' => 'burger-king-local',
            'nombre' => 'Burger King Local',
            'descripcion' => 'Hamburguesas a la parrilla',
            'categoria' => 'restaurante',
            'branding_json' => [
                'colors' => [
                    'primary' => '#D62300',
                    'secondary' => '#FFC72C',
                    'accent' => '#ED7902',
                ],
                'theme' => 'light'
            ],
            'logo_url' => 'https://via.placeholder.com/150',
            'lat' => 10.4900,
            'lng' => -66.8100,
            'direccion' => 'Centro Comercial Sambil',
            'ciudad' => 'Caracas',
            'estado' => 'Miranda',
            'telefono' => '+58212654321',
            'email' => 'info@burgerking.com',
            'is_active' => true,
            'is_open' => true,
            'radio_entrega_km' => 7,
            'tiempo_preparacion_min' => 20,
            'delivery_fee_usd' => 3,
            'delivery_fee_bs' => 105,
            'pedido_minimo_usd' => 8,
            'pedido_minimo_bs' => 280,
            'acepta_efectivo' => true,
            'acepta_pago_movil' => true,
            'acepta_transferencia' => true,
            'acepta_tarjeta' => true,
        ]);

        $categoriaHamburguesas = Categoria::create([
            'comercio_id' => $burguer->id,
            'nombre' => 'Hamburguesas',
            'descripcion' => 'Hamburguesas a la parrilla',
            'icono' => '🍔',
            'orden' => 1,
            'is_active' => true
        ]);

        Producto::create([
            'comercio_id' => $burguer->id,
            'categoria_id' => $categoriaHamburguesas->id,
            'nombre' => 'Whopper',
            'descripcion' => 'La clásica hamburguesa a la parrilla',
            'imagen_url' => 'https://via.placeholder.com/300',
            'precio_usd' => 6,
            'precio_bs' => 210,
            'stock_ilimitado' => true,
            'is_active' => true,
            'is_destacado' => true,
        ]);
    }
}
