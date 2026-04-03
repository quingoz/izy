<?php

namespace App\Http\Controllers;

use App\Http\Resources\ProductoResource;
use App\Models\Comercio;
use App\Models\Producto;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class ProductoController extends Controller
{
    public function index($slug, Request $request)
    {
        $comercio = Comercio::where('slug', $slug)->firstOrFail();
        config(['app.tenant_id' => $comercio->id]);

        $cacheKey = "comercio.{$comercio->id}.productos." . md5(json_encode($request->all()));

        $productos = Cache::remember($cacheKey, 3600, function() use ($request) {
            $query = Producto::with('categoria')
                ->where('is_active', true);

            if ($request->has('categoria_id')) {
                $query->where('categoria_id', $request->categoria_id);
            }

            if ($request->has('search')) {
                $search = $request->search;
                $query->where(function($q) use ($search) {
                    $q->where('nombre', 'like', "%{$search}%")
                      ->orWhere('descripcion', 'like', "%{$search}%");
                });
            }

            if ($request->boolean('solo_disponibles')) {
                $query->conStock();
            }

            $orderBy = $request->get('order_by', 'orden');
            $orderDir = $request->get('order_dir', 'asc');
            
            if ($orderBy === 'precio') {
                $query->orderBy('precio_usd', $orderDir);
            } else {
                $query->orderBy('is_destacado', 'desc')
                      ->orderBy('nombre', 'asc');
            }

            return $query->paginate($request->get('per_page', 20));
        });

        return response()->json([
            'success' => true,
            'data' => ProductoResource::collection($productos),
            'meta' => [
                'current_page' => $productos->currentPage(),
                'total' => $productos->total(),
                'per_page' => $productos->perPage(),
                'last_page' => $productos->lastPage()
            ]
        ]);
    }

    public function show($id)
    {
        $producto = Producto::with(['categoria', 'comercio'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => new ProductoResource($producto)
        ]);
    }

    public function search(Request $request)
    {
        $request->validate([
            'q' => 'required|string|min:2',
            'comercio_id' => 'nullable|exists:comercios,id'
        ]);

        $query = Producto::with(['categoria', 'comercio'])
            ->where('is_active', true)
            ->where(function($q) use ($request) {
                $search = $request->q;
                $q->where('nombre', 'like', "%{$search}%")
                  ->orWhere('descripcion', 'like', "%{$search}%");
            });

        if ($request->has('comercio_id')) {
            config(['app.tenant_id' => $request->comercio_id]);
        }

        $productos = $query->limit(20)->get();

        return response()->json([
            'success' => true,
            'data' => ProductoResource::collection($productos)
        ]);
    }
}
