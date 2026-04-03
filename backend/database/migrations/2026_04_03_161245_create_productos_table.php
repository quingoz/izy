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
        Schema::create('productos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('comercio_id')->constrained()->onDelete('cascade');
            $table->foreignId('categoria_id')->nullable()->constrained()->onDelete('set null');
            
            $table->string('nombre');
            $table->text('descripcion')->nullable();
            $table->string('imagen_url', 500)->nullable();
            
            $table->decimal('precio_usd', 10, 2);
            $table->decimal('precio_bs', 12, 2);
            $table->decimal('precio_oferta_usd', 10, 2)->nullable();
            $table->decimal('precio_oferta_bs', 12, 2)->nullable();
            
            $table->integer('stock')->default(0);
            $table->boolean('stock_ilimitado')->default(false);
            $table->integer('stock_minimo')->default(5);
            
            $table->boolean('tiene_variantes')->default(false);
            $table->json('variantes_json')->nullable();
            
            $table->boolean('is_active')->default(true);
            $table->boolean('is_destacado')->default(false);
            $table->time('disponible_desde')->nullable();
            $table->time('disponible_hasta')->nullable();
            
            $table->integer('total_ventas')->default(0);
            $table->decimal('rating', 3, 2)->default(5.00);
            
            $table->timestamps();
            
            $table->index('comercio_id');
            $table->index('categoria_id');
            $table->index('is_active');
            $table->index('is_destacado');
            $table->fullText(['nombre', 'descripcion']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('productos');
    }
};
