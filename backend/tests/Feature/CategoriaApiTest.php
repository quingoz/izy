<?php

namespace Tests\Feature;

use App\Models\Categoria;
use App\Models\Comercio;
use App\Models\Producto;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CategoriaApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_categorias_by_comercio()
    {
        $comercio = Comercio::factory()->create(['slug' => 'cat-shop']);
        
        Categoria::factory()->count(3)->create([
            'comercio_id' => $comercio->id,
            'is_active' => true
        ]);

        $response = $this->getJson("/api/comercios/cat-shop/categorias");

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data' => [
                         '*' => ['id', 'nombre', 'descripcion', 'icono', 'orden']
                     ]
                 ]);
    }

    public function test_categorias_include_productos_count()
    {
        $comercio = Comercio::factory()->create(['slug' => 'count-shop']);
        $categoria = Categoria::factory()->create([
            'comercio_id' => $comercio->id,
            'is_active' => true
        ]);

        Producto::factory()->count(5)->create([
            'comercio_id' => $comercio->id,
            'categoria_id' => $categoria->id
        ]);

        $response = $this->getJson("/api/comercios/count-shop/categorias");

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertEquals(5, $data[0]['productos_count']);
    }

    public function test_only_active_categorias_are_shown()
    {
        $comercio = Comercio::factory()->create(['slug' => 'active-cat-shop']);
        
        Categoria::factory()->count(2)->create([
            'comercio_id' => $comercio->id,
            'is_active' => true
        ]);

        Categoria::factory()->create([
            'comercio_id' => $comercio->id,
            'is_active' => false
        ]);

        $response = $this->getJson("/api/comercios/active-cat-shop/categorias");

        $response->assertStatus(200);
        $this->assertCount(2, $response->json('data'));
    }

    public function test_categorias_are_ordered()
    {
        $comercio = Comercio::factory()->create(['slug' => 'ordered-shop']);
        
        Categoria::factory()->create([
            'comercio_id' => $comercio->id,
            'nombre' => 'Segunda',
            'orden' => 2,
            'is_active' => true
        ]);

        Categoria::factory()->create([
            'comercio_id' => $comercio->id,
            'nombre' => 'Primera',
            'orden' => 1,
            'is_active' => true
        ]);

        $response = $this->getJson("/api/comercios/ordered-shop/categorias");

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertEquals('Primera', $data[0]['nombre']);
        $this->assertEquals('Segunda', $data[1]['nombre']);
    }

    public function test_categorias_respect_tenant_scope()
    {
        $comercio1 = Comercio::factory()->create(['slug' => 'shop-1']);
        $comercio2 = Comercio::factory()->create(['slug' => 'shop-2']);
        
        Categoria::factory()->count(2)->create([
            'comercio_id' => $comercio1->id,
            'is_active' => true
        ]);

        Categoria::factory()->count(3)->create([
            'comercio_id' => $comercio2->id,
            'is_active' => true
        ]);

        $response = $this->getJson("/api/comercios/shop-1/categorias");

        $response->assertStatus(200);
        $this->assertCount(2, $response->json('data'));
    }
}
