<?php

namespace App\Http\Controllers;

use App\Http\Resources\ComercioResource;
use App\Models\Comercio;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class ComercioController extends Controller
{
    public function show($slug)
    {
        $comercio = Cache::remember("comercio.{$slug}", 3600, function() use ($slug) {
            return Comercio::where('slug', $slug)
                ->where('is_active', true)
                ->firstOrFail();
        });

        return response()->json([
            'success' => true,
            'data' => new ComercioResource($comercio)
        ]);
    }

    public function branding($slug)
    {
        $comercio = Comercio::where('slug', $slug)
            ->where('is_active', true)
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => [
                'colors' => $comercio->branding_json['colors'] ?? [],
                'logo_url' => $comercio->logo_url,
                'theme' => $comercio->branding_json['theme'] ?? 'light',
            ]
        ]);
    }

    public function cercanos(Request $request)
    {
        $request->validate([
            'lat' => 'required|numeric|between:-90,90',
            'lng' => 'required|numeric|between:-180,180',
            'radio' => 'nullable|numeric|min:1|max:50'
        ]);

        $lat = $request->lat;
        $lng = $request->lng;
        $radio = $request->radio ?? 5;

        $comercios = Comercio::where('is_active', true)
            ->whereRaw("
                (6371 * acos(
                    cos(radians(?)) * cos(radians(lat)) *
                    cos(radians(lng) - radians(?)) +
                    sin(radians(?)) * sin(radians(lat))
                )) <= ?
            ", [$lat, $lng, $lat, $radio])
            ->get()
            ->map(function($comercio) use ($lat, $lng) {
                $comercio->distancia_km = round($comercio->getDistanceTo($lat, $lng), 2);
                $comercio->tiempo_estimado_min = $comercio->tiempo_preparacion_min + 
                    round($comercio->distancia_km * 5);
                return $comercio;
            })
            ->sortBy('distancia_km')
            ->values();

        return response()->json([
            'success' => true,
            'data' => ComercioResource::collection($comercios)
        ]);
    }
}
