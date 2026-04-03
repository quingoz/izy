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
        Schema::create('repartidor_ubicaciones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('repartidor_id')->constrained('repartidores')->onDelete('cascade');
            $table->foreignId('pedido_id')->nullable()->constrained()->onDelete('set null');
            
            $table->decimal('lat', 10, 8);
            $table->decimal('lng', 11, 8);
            $table->decimal('accuracy', 6, 2)->nullable();
            $table->decimal('speed', 6, 2)->nullable();
            
            $table->timestamp('created_at')->useCurrent();
            
            $table->index('repartidor_id');
            $table->index('pedido_id');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('repartidor_ubicaciones');
    }
};
