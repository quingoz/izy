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
        Schema::create('pedidos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('comercio_id')->constrained();
            $table->foreignId('cliente_id')->constrained('users');
            $table->foreignId('repartidor_id')->nullable()->constrained('repartidores')->onDelete('set null');
            
            $table->string('numero_pedido', 20)->unique();
            $table->string('token_seguimiento', 64)->unique();
            
            $table->enum('estado', [
                'pendiente', 'confirmado', 'preparando', 
                'listo', 'en_camino', 'entregado', 'cancelado'
            ])->default('pendiente');
            
            $table->decimal('subtotal_usd', 10, 2);
            $table->decimal('subtotal_bs', 12, 2);
            $table->decimal('delivery_fee_usd', 8, 2)->default(0.00);
            $table->decimal('delivery_fee_bs', 10, 2)->default(0.00);
            $table->decimal('descuento_usd', 8, 2)->default(0.00);
            $table->decimal('descuento_bs', 10, 2)->default(0.00);
            $table->decimal('total_usd', 10, 2);
            $table->decimal('total_bs', 12, 2);
            
            $table->enum('tipo_pago', ['efectivo', 'pago_movil', 'transferencia', 'tarjeta']);
            $table->decimal('vuelto_de', 12, 2)->nullable();
            $table->json('pago_movil_json')->nullable();
            $table->string('comprobante_url', 500)->nullable();
            $table->boolean('pago_verificado')->default(false);
            
            $table->json('direccion_json');
            
            $table->integer('tiempo_estimado_minutos')->default(30);
            $table->timestamp('fecha_confirmacion')->nullable();
            $table->timestamp('fecha_listo')->nullable();
            $table->timestamp('fecha_en_camino')->nullable();
            $table->timestamp('fecha_entregado')->nullable();
            $table->timestamp('fecha_cancelado')->nullable();
            
            $table->text('notas_cliente')->nullable();
            $table->text('notas_comercio')->nullable();
            $table->text('razon_cancelacion')->nullable();
            
            $table->decimal('rating_comercio', 3, 2)->nullable();
            $table->decimal('rating_repartidor', 3, 2)->nullable();
            $table->text('comentario_rating')->nullable();
            
            $table->timestamps();
            
            $table->index('comercio_id');
            $table->index('cliente_id');
            $table->index('repartidor_id');
            $table->index('estado');
            $table->index('token_seguimiento');
            $table->index('numero_pedido');
            $table->index('created_at');
            $table->index('tipo_pago');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pedidos');
    }
};
