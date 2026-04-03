<?php

namespace Tests\Feature;

use App\Models\Categoria;
use App\Models\Comercio;
use App\Models\Producto;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProductoApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_productos_by_comercio()
    {
        $comercio = Comercio::factory()->create(['slug' => 'test-shop']);
        $categoria = Categoria::factory()->create(['comercio_id' => $comercio->id]);
        
        Producto::factory()->count(3)->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria->id,
            'is_active' => true
        ]);

        $response = $this->getJson("/api/comercios/test-shop/productos");

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data',
                     'meta' => ['current_page', 'total', 'per_page', 'last_page']
                 ]);
    }

    public function test_can_filter_productos_by_categoria()
    {
        $comercio = Comercio::factory()->create(['slug' => 'filter-shop']);
        $categoria1 = Categoria::factory()->create(['comercio_id' => $comercio->id]);
        $categoria2 = Categoria::factory()->create(['comercio_id' => $comercio->id]);
        
        Producto::factory()->count(2)->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria1->id,
            'is_active' => true
        ]);

        Producto::factory()->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria2->id,
            'is_active' => true
        ]);

        $response = $this->getJson("/api/comercios/filter-shop/productos?categoria_id={$categoria1->id}");

        $response->assertStatus(200);
        $this->assertEquals(2, count($response->json('data')));
    }

    public function test_can_search_productos()
    {
        $comercio = Comercio::factory()->create(['slug' => 'search-shop']);
        $categoria = Categoria::factory()->create(['comercio_id' => $comercio->id]);
        
        Producto::factory()->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria->id,
            'nombre' => 'Pizza Margarita',
            'is_active' => true
        ]);

        Producto::factory()->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria->id,
            'nombre' => 'Hamburguesa',
            'is_active' => true
        ]);

        $response = $this->getJson("/api/comercios/search-shop/productos?search=pizza");

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertStringContainsString('Pizza', $data[0]['nombre']);
    }

    public function test_can_get_producto_by_id()
    {
        $comercio = Comercio::factory()->create();
        $categoria = Categoria::factory()->create(['comercio_id' => $comercio->id]);
        $producto = Producto::factory()->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria->id
        ]);

        $response = $this->getJson("/api/productos/{$producto->id}");

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'data' => [
                         'id' => $producto->id,
                         'nombre' => $producto->nombre
                     ]
                 ]);
    }

    public function test_producto_resource_includes_categoria()
    {
        $comercio = Comercio::factory()->create();
        $categoria = Categoria::factory()->create([
            'comercio_id' => $comercio->id,
            'nombre' => 'Test Categoria'
        ]);
        $producto = Producto::factory()->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria->id
        ]);

        $response = $this->getJson("/api/productos/{$producto->id}");

        $response->assertStatus(200)
                 ->assertJsonPath('data.categoria.nombre', 'Test Categoria');
    }

    public function test_can_search_productos_globally()
    {
        $comercio = Comercio::factory()->create();
        $categoria = Categoria::factory()->create(['comercio_id' => $comercio->id]);
        
        Producto::factory()->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria->id,
            'nombre' => 'Producto Especial',
            'is_active' => true
        ]);

        $response = $this->getJson("/api/productos/search?q=especial");

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data' => [
                         '*' => ['id', 'nombre', 'comercio']
                     ]
                 ]);
    }

    public function test_search_requires_minimum_query_length()
    {
        $response = $this->getJson("/api/productos/search?q=a");

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['q']);
    }

    public function test_productos_pagination_works()
    {
        $comercio = Comercio::factory()->create(['slug' => 'paginated-shop']);
        $categoria = Categoria::factory()->create(['comercio_id' => $comercio->id]);
        
        Producto::factory()->count(25)->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria->id,
            'is_active' => true
        ]);

        $response = $this->getJson("/api/comercios/paginated-shop/productos?per_page=10");

        $response->assertStatus(200);
        $this->assertEquals(10, count($response->json('data')));
        $this->assertEquals(25, $response->json('meta.total'));
    }

    public function test_only_active_productos_are_shown()
    {
        $comercio = Comercio::factory()->create(['slug' => 'active-shop']);
        $categoria = Categoria::factory()->create(['comercio_id' => $comercio->id]);
        
        Producto::factory()->count(2)->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria->id,
            'is_active' => true
        ]);

        Producto::factory()->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria->id,
            'is_active' => false
        ]);

        $response = $this->getJson("/api/comercios/active-shop/productos");

        $response->assertStatus(200);
        $this->assertEquals(2, count($response->json('data')));
    }
}
