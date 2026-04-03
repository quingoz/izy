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
        Schema::create('notificaciones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            
            $table->enum('tipo', ['pedido', 'promocion', 'sistema', 'chat']);
            $table->string('titulo');
            $table->text('mensaje');
            
            $table->json('data_json')->nullable();
            
            $table->boolean('leida')->default(false);
            $table->timestamp('fecha_lectura')->nullable();
            
            $table->boolean('enviada_push')->default(false);
            $table->timestamp('fecha_envio_push')->nullable();
            
            $table->timestamp('created_at')->useCurrent();
            
            $table->index('user_id');
            $table->index('leida');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notificaciones');
    }
};
