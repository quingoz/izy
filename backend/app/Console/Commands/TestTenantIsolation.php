<?php

namespace App\Console\Commands;

use App\Models\Comercio;
use App\Models\Producto;
use Illuminate\Console\Command;

class TestTenantIsolation extends Command
{
    protected $signature = 'tenant:test-isolation';
    protected $description = 'Prueba el aislamiento de datos multi-tenant';

    public function handle()
    {
        $this->info('Probando aislamiento multi-tenant...');

        $comercio1 = Comercio::first();
        $comercio2 = Comercio::skip(1)->first();

        if (!$comercio1 || !$comercio2) {
            $this->error('Se necesitan al menos 2 comercios en la DB');
            return 1;
        }

        $totalSinTenant = Producto::withoutGlobalScopes()->count();
        $this->info("Productos sin tenant: {$totalSinTenant}");

        config(['app.tenant_id' => $comercio1->id]);
        $totalTenant1 = Producto::count();
        $this->info("Productos de {$comercio1->nombre}: {$totalTenant1}");

        config(['app.tenant_id' => $comercio2->id]);
        $totalTenant2 = Producto::count();
        $this->info("Productos de {$comercio2->nombre}: {$totalTenant2}");

        if ($totalTenant1 + $totalTenant2 === $totalSinTenant) {
            $this->info('✓ Aislamiento funcionando correctamente');
            return 0;
        } else {
            $this->error('✗ Hay un problema con el aislamiento');
            return 1;
        }
    }
}
