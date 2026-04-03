<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class RequireTenant
{
    public function handle(Request $request, Closure $next)
    {
        if (!config('app.tenant_id')) {
            return response()->json([
                'success' => false,
                'message' => 'Tenant no identificado'
            ], 400);
        }

        return $next($request);
    }
}
