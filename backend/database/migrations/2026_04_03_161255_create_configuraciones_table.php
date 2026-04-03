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
        Schema::create('configuraciones', function (Blueprint $table) {
            $table->id();
            $table->string('clave', 100)->unique();
            $table->text('valor');
            $table->enum('tipo', ['string', 'number', 'boolean', 'json'])->default('string');
            $table->text('descripcion')->nullable();
            
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();
            
            $table->index('clave');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('configuraciones');
    }
};
