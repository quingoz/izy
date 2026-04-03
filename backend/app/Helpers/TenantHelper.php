<?php

namespace App\Helpers;

use App\Models\Comercio;

class TenantHelper
{
    public static function get(): ?Comercio
    {
        return app('tenant');
    }

    public static function getId(): ?int
    {
        return config('app.tenant_id');
    }

    public static function check(): bool
    {
        return self::getId() !== null;
    }

    public static function set(Comercio $comercio): void
    {
        app()->instance('tenant', $comercio);
        config(['app.tenant_id' => $comercio->id]);
    }
}
