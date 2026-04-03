<?php

namespace App\Models\Scopes;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Scope;

class TenantScope implements Scope
{
    public function apply(Builder $builder, Model $model)
    {
        if ($tenantId = config('app.tenant_id')) {
            $builder->where($model->getTable() . '.comercio_id', $tenantId);
        }
    }
}
