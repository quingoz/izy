<?php

namespace App\Http\Middleware;

use App\Models\Comercio;
use Closure;
use Illuminate\Http\Request;

class IdentifyTenant
{
    public function handle(Request $request, Closure $next)
    {
        $slug = $request->route('slug') 
             ?? $request->header('X-Tenant-Slug')
             ?? $request->input('comercio_slug');
        
        if ($slug) {
            $comercio = Comercio::where('slug', $slug)
                ->where('is_active', true)
                ->first();
            
            if (!$comercio) {
                return response()->json([
                    'success' => false,
                    'message' => 'Comercio no encontrado'
                ], 404);
            }
            
            app()->instance('tenant', $comercio);
            config(['app.tenant_id' => $comercio->id]);
            
            logger()->info('Tenant identified', [
                'slug' => $slug,
                'comercio_id' => $comercio->id,
                'comercio_nombre' => $comercio->nombre
            ]);
        }
        
        return $next($request);
    }
}
