<?php

namespace Tests\Unit;

use App\Models\Categoria;
use App\Models\Comercio;
use App\Models\Direccion;
use App\Models\Pedido;
use App\Models\Producto;
use App\Models\Repartidor;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ModelRelationsTest extends TestCase
{
    use RefreshDatabase;

    public function test_comercio_has_productos()
    {
        $comercio = Comercio::factory()->create();
        $producto = Producto::factory()->create(['comercio_id' => $comercio->id]);

        $this->assertTrue($comercio->productos->contains($producto));
    }

    public function test_comercio_has_categorias()
    {
        $comercio = Comercio::factory()->create();
        $categoria = Categoria::factory()->create(['comercio_id' => $comercio->id]);

        $this->assertTrue($comercio->categorias->contains($categoria));
    }

    public function test_producto_belongs_to_comercio()
    {
        $comercio = Comercio::factory()->create();
        $producto = Producto::factory()->create(['comercio_id' => $comercio->id]);

        $this->assertEquals($comercio->id, $producto->comercio->id);
    }

    public function test_user_has_direcciones()
    {
        $user = User::factory()->create();
        $direccion = Direccion::factory()->create(['user_id' => $user->id]);

        $this->assertTrue($user->direcciones->contains($direccion));
    }

    public function test_user_has_repartidor()
    {
        $user = User::factory()->create(['role' => 'repartidor']);
        $repartidor = Repartidor::factory()->create(['user_id' => $user->id]);

        $this->assertEquals($repartidor->id, $user->repartidor->id);
    }

    public function test_producto_scopes()
    {
        $comercio = Comercio::factory()->create();
        
        Producto::factory()->create([
            'comercio_id' => $comercio->id,
            'is_active' => true,
            'is_destacado' => true
        ]);
        
        Producto::factory()->create([
            'comercio_id' => $comercio->id,
            'is_active' => false,
            'is_destacado' => false
        ]);

        $this->assertEquals(1, Producto::withoutGlobalScopes()->active()->count());
        $this->assertEquals(1, Producto::withoutGlobalScopes()->destacados()->count());
    }

    public function test_user_role_methods()
    {
        $cliente = User::factory()->create(['role' => 'cliente']);
        $comercio = User::factory()->create(['role' => 'comercio']);
        $repartidor = User::factory()->create(['role' => 'repartidor']);

        $this->assertTrue($cliente->isCliente());
        $this->assertTrue($comercio->isComercio());
        $this->assertTrue($repartidor->isRepartidor());
    }

    public function test_comercio_distance_calculation()
    {
        $comercio = Comercio::factory()->create([
            'lat' => 10.0,
            'lng' => -66.0
        ]);

        $distance = $comercio->getDistanceTo(10.1, -66.1);
        
        $this->assertGreaterThan(0, $distance);
        $this->assertLessThan(20, $distance);
    }
}
