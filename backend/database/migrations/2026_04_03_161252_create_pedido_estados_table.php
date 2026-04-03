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
        Schema::create('pedido_estados', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pedido_id')->constrained()->onDelete('cascade');
            
            $table->string('estado_anterior', 50)->nullable();
            $table->string('estado_nuevo', 50);
            
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null');
            $table->string('user_role', 50)->nullable();
            
            $table->text('notas')->nullable();
            $table->json('metadata_json')->nullable();
            
            $table->timestamp('created_at')->useCurrent();
            
            $table->index('pedido_id');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pedido_estados');
    }
};
