<?php

namespace Tests\Feature;

use App\Models\Comercio;
use App\Models\Pedido;
use App\Models\Repartidor;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PedidoPolicyTest extends TestCase
{
    use RefreshDatabase;

    public function test_cliente_can_view_own_pedido()
    {
        $comercio = Comercio::factory()->create();
        $cliente = User::factory()->create(['role' => 'cliente']);
        
        $pedido = Pedido::factory()->create([
            'comercio_id' => $comercio->id,
            'cliente_id' => $cliente->id
        ]);

        $this->actingAs($cliente);
        $this->assertTrue($cliente->can('view', $pedido));
    }

    public function test_cliente_cannot_view_other_pedido()
    {
        $comercio = Comercio::factory()->create();
        $cliente1 = User::factory()->create(['role' => 'cliente']);
        $cliente2 = User::factory()->create(['role' => 'cliente']);
        
        $pedido = Pedido::factory()->create([
            'comercio_id' => $comercio->id,
            'cliente_id' => $cliente2->id
        ]);

        $this->actingAs($cliente1);
        $this->assertFalse($cliente1->can('view', $pedido));
    }

    public function test_comercio_can_view_own_pedidos()
    {
        $comercio = Comercio::factory()->create();
        $userComercio = User::factory()->create([
            'role' => 'comercio',
            'comercio_id' => $comercio->id
        ]);
        
        $pedido = Pedido::factory()->create([
            'comercio_id' => $comercio->id
        ]);

        $this->actingAs($userComercio);
        $this->assertTrue($userComercio->can('view', $pedido));
        $this->assertTrue($userComercio->can('update', $pedido));
    }

    public function test_comercio_cannot_view_other_comercio_pedidos()
    {
        $comercio1 = Comercio::factory()->create();
        $comercio2 = Comercio::factory()->create();
        
        $userComercio1 = User::factory()->create([
            'role' => 'comercio',
            'comercio_id' => $comercio1->id
        ]);
        
        $pedido2 = Pedido::factory()->create([
            'comercio_id' => $comercio2->id
        ]);

        $this->actingAs($userComercio1);
        $this->assertFalse($userComercio1->can('view', $pedido2));
        $this->assertFalse($userComercio1->can('update', $pedido2));
    }

    public function test_repartidor_can_view_assigned_pedido()
    {
        $comercio = Comercio::factory()->create();
        $userRepartidor = User::factory()->create(['role' => 'repartidor']);
        $repartidor = Repartidor::factory()->create(['user_id' => $userRepartidor->id]);
        
        $pedido = Pedido::factory()->create([
            'comercio_id' => $comercio->id,
            'repartidor_id' => $repartidor->id
        ]);

        $this->actingAs($userRepartidor);
        $this->assertTrue($userRepartidor->can('view', $pedido));
        $this->assertTrue($userRepartidor->can('update', $pedido));
    }

    public function test_repartidor_cannot_view_unassigned_pedido()
    {
        $comercio = Comercio::factory()->create();
        $userRepartidor = User::factory()->create(['role' => 'repartidor']);
        $repartidor = Repartidor::factory()->create(['user_id' => $userRepartidor->id]);
        
        $pedido = Pedido::factory()->create([
            'comercio_id' => $comercio->id,
            'repartidor_id' => null
        ]);

        $this->actingAs($userRepartidor);
        $this->assertFalse($userRepartidor->can('view', $pedido));
    }

    public function test_cliente_can_cancel_pending_pedido()
    {
        $comercio = Comercio::factory()->create();
        $cliente = User::factory()->create(['role' => 'cliente']);
        
        $pedido = Pedido::factory()->create([
            'comercio_id' => $comercio->id,
            'cliente_id' => $cliente->id,
            'estado' => 'pendiente'
        ]);

        $this->actingAs($cliente);
        $this->assertTrue($cliente->can('cancel', $pedido));
    }

    public function test_cliente_cannot_cancel_delivered_pedido()
    {
        $comercio = Comercio::factory()->create();
        $cliente = User::factory()->create(['role' => 'cliente']);
        
        $pedido = Pedido::factory()->create([
            'comercio_id' => $comercio->id,
            'cliente_id' => $cliente->id,
            'estado' => 'entregado'
        ]);

        $this->actingAs($cliente);
        $this->assertFalse($cliente->can('cancel', $pedido));
    }

    public function test_comercio_can_cancel_preparing_pedido()
    {
        $comercio = Comercio::factory()->create();
        $userComercio = User::factory()->create([
            'role' => 'comercio',
            'comercio_id' => $comercio->id
        ]);
        
        $pedido = Pedido::factory()->create([
            'comercio_id' => $comercio->id,
            'estado' => 'preparando'
        ]);

        $this->actingAs($userComercio);
        $this->assertTrue($userComercio->can('cancel', $pedido));
    }

    public function test_admin_can_view_any_pedido()
    {
        $comercio = Comercio::factory()->create();
        $admin = User::factory()->create(['role' => 'admin']);
        
        $pedido = Pedido::factory()->create([
            'comercio_id' => $comercio->id
        ]);

        $this->actingAs($admin);
        $this->assertTrue($admin->can('view', $pedido));
        $this->assertTrue($admin->can('update', $pedido));
    }
}
