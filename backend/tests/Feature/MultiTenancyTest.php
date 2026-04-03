<?php

namespace Tests\Feature;

use App\Helpers\TenantHelper;
use App\Models\Categoria;
use App\Models\Comercio;
use App\Models\Producto;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MultiTenancyTest extends TestCase
{
    use RefreshDatabase;

    public function test_tenant_scope_filters_productos()
    {
        $comercio1 = Comercio::factory()->create(['slug' => 'comercio-1']);
        $comercio2 = Comercio::factory()->create(['slug' => 'comercio-2']);

        $producto1 = Producto::factory()->create(['comercio_id' => $comercio1->id]);
        $producto2 = Producto::factory()->create(['comercio_id' => $comercio2->id]);

        $this->assertCount(2, Producto::withoutGlobalScopes()->get());

        config(['app.tenant_id' => $comercio1->id]);
        $this->assertCount(1, Producto::all());
        $this->assertEquals($producto1->id, Producto::first()->id);
    }

    public function test_tenant_auto_assigns_on_create()
    {
        $comercio = Comercio::factory()->create();
        $categoria = Categoria::factory()->create(['comercio_id' => $comercio->id]);
        config(['app.tenant_id' => $comercio->id]);

        $producto = Producto::create([
            'categoria_id' => $categoria->id,
            'nombre' => 'Test Producto',
            'precio_usd' => 10,
            'precio_bs' => 350
        ]);

        $this->assertEquals($comercio->id, $producto->comercio_id);
    }

    public function test_cannot_access_other_tenant_data()
    {
        $comercio1 = Comercio::factory()->create();
        $comercio2 = Comercio::factory()->create();

        $producto1 = Producto::factory()->create(['comercio_id' => $comercio1->id]);
        $producto2 = Producto::factory()->create(['comercio_id' => $comercio2->id]);

        config(['app.tenant_id' => $comercio1->id]);

        $this->assertNull(Producto::find($producto2->id));
        $this->assertNotNull(Producto::find($producto1->id));
    }

    public function test_tenant_helper_works()
    {
        $comercio = Comercio::factory()->create();
        
        $this->assertFalse(TenantHelper::check());
        $this->assertNull(TenantHelper::getId());

        TenantHelper::set($comercio);

        $this->assertTrue(TenantHelper::check());
        $this->assertEquals($comercio->id, TenantHelper::getId());
        $this->assertEquals($comercio->id, TenantHelper::get()->id);
    }

    public function test_policy_prevents_cross_tenant_access()
    {
        $comercio1 = Comercio::factory()->create();
        $comercio2 = Comercio::factory()->create();

        $user1 = User::factory()->create([
            'role' => 'comercio',
            'comercio_id' => $comercio1->id
        ]);

        $producto2 = Producto::factory()->create(['comercio_id' => $comercio2->id]);

        $this->actingAs($user1);

        $this->assertFalse($user1->can('update', $producto2));
        $this->assertFalse($user1->can('delete', $producto2));
    }

    public function test_comercio_can_manage_own_products()
    {
        $comercio = Comercio::factory()->create();
        $user = User::factory()->create([
            'role' => 'comercio',
            'comercio_id' => $comercio->id
        ]);

        $producto = Producto::factory()->create(['comercio_id' => $comercio->id]);

        $this->actingAs($user);

        $this->assertTrue($user->can('view', $producto));
        $this->assertTrue($user->can('update', $producto));
        $this->assertTrue($user->can('delete', $producto));
    }

    public function test_tenant_isolation_in_relationships()
    {
        $comercio1 = Comercio::factory()->create();
        $comercio2 = Comercio::factory()->create();

        Producto::factory()->count(3)->create(['comercio_id' => $comercio1->id]);
        Producto::factory()->count(2)->create(['comercio_id' => $comercio2->id]);

        config(['app.tenant_id' => $comercio1->id]);

        $this->assertCount(3, $comercio1->productos);
        $this->assertCount(3, Producto::all());
    }

    public function test_categorias_respect_tenant_scope()
    {
        $comercio1 = Comercio::factory()->create();
        $comercio2 = Comercio::factory()->create();

        Categoria::factory()->count(2)->create(['comercio_id' => $comercio1->id]);
        Categoria::factory()->count(3)->create(['comercio_id' => $comercio2->id]);

        config(['app.tenant_id' => $comercio1->id]);

        $this->assertCount(2, Categoria::all());
    }

    public function test_cliente_can_view_any_product()
    {
        $comercio = Comercio::factory()->create();
        $cliente = User::factory()->create(['role' => 'cliente']);
        $producto = Producto::factory()->create(['comercio_id' => $comercio->id]);

        $this->actingAs($cliente);

        $this->assertTrue($cliente->can('view', $producto));
    }

    public function test_cliente_cannot_create_products()
    {
        $cliente = User::factory()->create(['role' => 'cliente']);

        $this->actingAs($cliente);

        $this->assertFalse($cliente->can('create', Producto::class));
    }

    public function test_without_tenant_sees_all_data()
    {
        $comercio1 = Comercio::factory()->create();
        $comercio2 = Comercio::factory()->create();

        Producto::factory()->count(3)->create(['comercio_id' => $comercio1->id]);
        Producto::factory()->count(2)->create(['comercio_id' => $comercio2->id]);

        $this->assertCount(5, Producto::withoutGlobalScopes()->get());
    }

    public function test_switching_tenants_changes_visible_data()
    {
        $comercio1 = Comercio::factory()->create();
        $comercio2 = Comercio::factory()->create();

        $producto1 = Producto::factory()->create(['comercio_id' => $comercio1->id]);
        $producto2 = Producto::factory()->create(['comercio_id' => $comercio2->id]);

        config(['app.tenant_id' => $comercio1->id]);
        $this->assertEquals($producto1->id, Producto::first()->id);

        config(['app.tenant_id' => $comercio2->id]);
        $this->assertEquals($producto2->id, Producto::first()->id);
    }
}
