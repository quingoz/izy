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
        Schema::create('direcciones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            
            $table->string('alias', 100)->nullable();
            $table->text('calle');
            $table->string('ciudad', 100)->nullable();
            $table->string('estado', 100)->nullable();
            $table->string('codigo_postal', 20)->nullable();
            $table->text('referencia')->nullable();
            
            $table->decimal('lat', 10, 8);
            $table->decimal('lng', 11, 8);
            
            $table->boolean('is_default')->default(false);
            $table->timestamps();
            
            $table->index('user_id');
            $table->index(['lat', 'lng']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('direcciones');
    }
};
