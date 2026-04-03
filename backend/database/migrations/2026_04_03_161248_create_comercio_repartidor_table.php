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
        Schema::create('comercio_repartidor', function (Blueprint $table) {
            $table->id();
            $table->foreignId('comercio_id')->constrained()->onDelete('cascade');
            $table->foreignId('repartidor_id')->constrained('repartidores')->onDelete('cascade');
            
            $table->decimal('comision_porcentaje', 5, 2)->default(10.00);
            $table->integer('prioridad')->default(1);
            
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->unique(['comercio_id', 'repartidor_id']);
            $table->index('comercio_id');
            $table->index('repartidor_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('comercio_repartidor');
    }
};
