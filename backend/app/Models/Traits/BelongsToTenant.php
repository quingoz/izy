<?php

namespace App\Models\Traits;

use App\Models\Scopes\TenantScope;

trait BelongsToTenant
{
    protected static function bootBelongsToTenant()
    {
        static::addGlobalScope(new TenantScope);
        
        static::creating(function ($model) {
            if (!$model->comercio_id && $tenantId = config('app.tenant_id')) {
                $model->comercio_id = $tenantId;
            }
        });
    }
    
    public function comercio()
    {
        return $this->belongsTo(\App\Models\Comercio::class);
    }
}
