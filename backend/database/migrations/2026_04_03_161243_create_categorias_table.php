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
        Schema::create('categorias', function (Blueprint $table) {
            $table->id();
            $table->foreignId('comercio_id')->constrained()->onDelete('cascade');
            $table->string('nombre', 100);
            $table->text('descripcion')->nullable();
            $table->string('icono', 50)->nullable();
            $table->integer('orden')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('comercio_id');
            $table->index('orden');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('categorias');
    }
};
