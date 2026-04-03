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
        Schema::create('comercios', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 100)->unique();
            $table->string('nombre');
            $table->text('descripcion')->nullable();
            $table->enum('categoria', ['restaurante', 'farmacia', 'supermercado', 'licoreria', 'otro'])->default('restaurante');
            
            $table->json('branding_json')->nullable();
            $table->string('logo_url', 500)->nullable();
            $table->string('banner_url', 500)->nullable();
            
            $table->decimal('lat', 10, 8);
            $table->decimal('lng', 11, 8);
            $table->text('direccion');
            $table->string('ciudad', 100)->nullable();
            $table->string('estado', 100)->nullable();
            
            $table->string('telefono', 20)->nullable();
            $table->string('email')->nullable();
            $table->string('whatsapp', 20)->nullable();
            
            $table->json('horarios_json')->nullable();
            $table->decimal('radio_entrega_km', 5, 2)->default(5.00);
            $table->integer('tiempo_preparacion_min')->default(30);
            
            $table->decimal('delivery_fee_usd', 8, 2)->default(2.00);
            $table->decimal('delivery_fee_bs', 10, 2)->default(0.00);
            $table->decimal('pedido_minimo_usd', 8, 2)->default(5.00);
            $table->decimal('pedido_minimo_bs', 10, 2)->default(0.00);
            
            $table->boolean('acepta_efectivo')->default(true);
            $table->boolean('acepta_pago_movil')->default(true);
            $table->boolean('acepta_transferencia')->default(false);
            $table->boolean('acepta_tarjeta')->default(false);
            
            $table->boolean('is_active')->default(true);
            $table->boolean('is_open')->default(false);
            
            $table->integer('total_pedidos')->default(0);
            $table->decimal('rating', 3, 2)->default(5.00);
            $table->integer('total_reviews')->default(0);
            
            $table->timestamps();
            
            $table->index('slug');
            $table->index('is_active');
            $table->index(['lat', 'lng']);
            $table->index('categoria');
            $table->fullText(['nombre', 'descripcion']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('comercios');
    }
};
