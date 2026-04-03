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
        Schema::create('pedido_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pedido_id')->constrained()->onDelete('cascade');
            $table->foreignId('producto_id')->constrained();
            
            $table->string('nombre_producto');
            $table->integer('cantidad');
            $table->decimal('precio_unitario_usd', 10, 2);
            $table->decimal('precio_unitario_bs', 12, 2);
            $table->decimal('subtotal_usd', 10, 2);
            $table->decimal('subtotal_bs', 12, 2);
            
            $table->json('variantes_json')->nullable();
            $table->text('notas')->nullable();
            
            $table->timestamp('created_at')->useCurrent();
            
            $table->index('pedido_id');
            $table->index('producto_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pedido_items');
    }
};
