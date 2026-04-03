<?php

namespace Tests\Feature;

use App\Models\Comercio;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class ComercioApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Cache::flush();
    }

    public function test_can_get_comercio_by_slug()
    {
        $comercio = Comercio::factory()->create([
            'slug' => 'test-comercio',
            'is_active' => true
        ]);

        $response = $this->getJson("/api/comercios/test-comercio");

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'data' => [
                         'id' => $comercio->id,
                         'slug' => 'test-comercio'
                     ]
                 ]);
    }

    public function test_cannot_get_inactive_comercio()
    {
        Comercio::factory()->create([
            'slug' => 'inactive-comercio',
            'is_active' => false
        ]);

        $response = $this->getJson("/api/comercios/inactive-comercio");

        $response->assertStatus(404);
    }

    public function test_can_get_comercio_branding()
    {
        $comercio = Comercio::factory()->create([
            'slug' => 'branded-comercio',
            'is_active' => true,
            'branding_json' => [
                'colors' => [
                    'primary' => '#FF0000',
                    'secondary' => '#00FF00'
                ],
                'theme' => 'dark'
            ]
        ]);

        $response = $this->getJson("/api/comercios/branded-comercio/branding");

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'data' => [
                         'colors' => [
                             'primary' => '#FF0000',
                             'secondary' => '#00FF00'
                         ],
                         'theme' => 'dark'
                     ]
                 ]);
    }

    public function test_can_get_comercios_cercanos()
    {
        Comercio::factory()->create([
            'is_active' => true,
            'lat' => 10.4806,
            'lng' => -66.8037
        ]);

        Comercio::factory()->create([
            'is_active' => true,
            'lat' => 10.5000,
            'lng' => -66.8200
        ]);

        $response = $this->getJson("/api/comercios/cercanos?lat=10.4806&lng=-66.8037&radio=10");

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data' => [
                         '*' => [
                             'id',
                             'nombre',
                             'distancia_km',
                             'tiempo_estimado_min'
                         ]
                     ]
                 ]);
    }

    public function test_cercanos_requires_coordinates()
    {
        $response = $this->getJson("/api/comercios/cercanos");

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['lat', 'lng']);
    }

    public function test_cercanos_validates_coordinates_range()
    {
        $response = $this->getJson("/api/comercios/cercanos?lat=100&lng=-200");

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['lat', 'lng']);
    }

    public function test_comercios_are_sorted_by_distance()
    {
        $comercio1 = Comercio::factory()->create([
            'is_active' => true,
            'lat' => 10.4806,
            'lng' => -66.8037,
            'nombre' => 'Cercano'
        ]);

        $comercio2 = Comercio::factory()->create([
            'is_active' => true,
            'lat' => 10.5500,
            'lng' => -66.9000,
            'nombre' => 'Lejano'
        ]);

        $response = $this->getJson("/api/comercios/cercanos?lat=10.4806&lng=-66.8037&radio=50");

        $response->assertStatus(200);
        
        $data = $response->json('data');
        $this->assertEquals('Cercano', $data[0]['nombre']);
    }

    public function test_comercio_resource_structure()
    {
        $comercio = Comercio::factory()->create([
            'slug' => 'full-comercio',
            'is_active' => true
        ]);

        $response = $this->getJson("/api/comercios/full-comercio");

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data' => [
                         'id',
                         'slug',
                         'nombre',
                         'descripcion',
                         'categoria',
                         'logo_url',
                         'ubicacion' => ['lat', 'lng', 'direccion', 'ciudad', 'estado'],
                         'contacto' => ['telefono', 'email'],
                         'configuracion' => [
                             'radio_entrega_km',
                             'tiempo_preparacion_min',
                             'delivery_fee_usd',
                             'delivery_fee_bs'
                         ],
                         'metodos_pago',
                         'is_active',
                         'rating'
                     ]
                 ]);
    }
}
