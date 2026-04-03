<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('repartidores', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
            
            $table->boolean('is_freelance')->default(false);
            
            $table->decimal('current_lat', 10, 8)->nullable();
            $table->decimal('current_lng', 11, 8)->nullable();
            $table->timestamp('last_location_update')->nullable();
            
            $table->enum('status', ['disponible', 'ocupado', 'offline'])->default('offline');
            
            $table->enum('vehiculo_tipo', ['moto', 'bicicleta', 'auto', 'pie'])->default('moto');
            $table->string('placa_vehiculo', 20)->nullable();
            $table->string('color_vehiculo', 50)->nullable();
            
            $table->string('cedula', 20)->nullable();
            $table->string('licencia_conducir', 50)->nullable();
            $table->string('foto_cedula_url', 500)->nullable();
            $table->string('foto_licencia_url', 500)->nullable();
            
            $table->decimal('rating', 3, 2)->default(5.00);
            $table->integer('total_entregas')->default(0);
            $table->integer('total_rechazos')->default(0);
            $table->integer('entregas_completadas_hoy')->default(0);
            
            $table->decimal('ganancias_hoy_usd', 10, 2)->default(0.00);
            $table->decimal('ganancias_semana_usd', 10, 2)->default(0.00);
            $table->decimal('ganancias_mes_usd', 10, 2)->default(0.00);
            
            $table->decimal('radio_trabajo_km', 5, 2)->default(3.00);
            $table->boolean('acepta_pedidos')->default(true);
            
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('status');
            $table->index('is_freelance');
            $table->index(['current_lat', 'current_lng']);
            $table->index('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('repartidores');
    }
};
