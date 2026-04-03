<?php

namespace App\Http\Controllers;

use App\Http\Resources\CategoriaResource;
use App\Models\Categoria;
use App\Models\Comercio;
use Illuminate\Support\Facades\Cache;

class CategoriaController extends Controller
{
    public function index($slug)
    {
        $comercio = Comercio::where('slug', $slug)->firstOrFail();
        config(['app.tenant_id' => $comercio->id]);

        $categorias = Cache::remember("comercio.{$comercio->id}.categorias", 3600, function() {
            return Categoria::with('productos')
                ->where('is_active', true)
                ->ordenado()
                ->get();
        });

        return response()->json([
            'success' => true,
            'data' => CategoriaResource::collection($categorias)
        ]);
    }
}
