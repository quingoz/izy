<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Auth\PasswordResetController;
use App\Http\Controllers\CategoriaController;
use App\Http\Controllers\Comercio;
use App\Http\Controllers\ComercioController;
use App\Http\Controllers\PedidoController;
use App\Http\Controllers\ProductoController;
use App\Http\Controllers\Repartidor;
use App\Http\Controllers\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'service' => 'IZY API',
        'timestamp' => now()->toIso8601String(),
    ]);
});

Route::get('/comercios/cercanos', [ComercioController::class, 'cercanos']);
Route::get('/comercios/{slug}', [ComercioController::class, 'show']);
Route::get('/comercios/{slug}/branding', [ComercioController::class, 'branding']);
Route::get('/comercios/{slug}/productos', [ProductoController::class, 'index']);
Route::get('/comercios/{slug}/categorias', [CategoriaController::class, 'index']);

Route::get('/productos/search', [ProductoController::class, 'search']);
Route::get('/productos/{id}', [ProductoController::class, 'show']);

Route::middleware(['throttle:5,1'])->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/password/email', [PasswordResetController::class, 'sendResetLink']);
    Route::post('/auth/password/reset', [PasswordResetController::class, 'reset']);
});

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::post('/auth/refresh', [AuthController::class, 'refresh']);
    Route::get('/auth/me', [AuthController::class, 'me']);
    
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::post('/pedidos', [PedidoController::class, 'store']);
    Route::get('/mis-pedidos', [PedidoController::class, 'index']);
    Route::get('/pedidos/{id}', [PedidoController::class, 'show']);
    Route::put('/pedidos/{id}/cancel', [PedidoController::class, 'cancel']);

    Route::post('/repartidor/ubicacion', [UbicacionController::class, 'update']);
    
    Route::post('/user/fcm-token', [UserController::class, 'updateFcmToken']);
});

Route::middleware(['auth:sanctum', 'role:comercio'])->prefix('comercio')->group(function () {
    Route::get('/pedidos', [Comercio\PedidoController::class, 'index']);
    Route::get('/pedidos/{id}', [Comercio\PedidoController::class, 'show']);
    Route::put('/pedidos/{id}/estado', [Comercio\PedidoController::class, 'updateEstado']);
    Route::post('/pedidos/{id}/asignar-repartidor', [Comercio\PedidoController::class, 'asignarRepartidor']);
    Route::get('/estadisticas', [Comercio\PedidoController::class, 'estadisticas']);
});

Route::middleware(['auth:sanctum', 'role:repartidor'])->prefix('repartidor')->group(function () {
    Route::get('/pedidos/disponibles', [Repartidor\PedidoController::class, 'disponibles']);
    Route::get('/pedidos/mis-pedidos', [Repartidor\PedidoController::class, 'misPedidos']);
    Route::post('/pedidos/{id}/aceptar', [Repartidor\PedidoController::class, 'aceptar']);
    Route::post('/pedidos/{id}/rechazar', [Repartidor\PedidoController::class, 'rechazar']);
    Route::post('/pedidos/{id}/confirmar-recogida', [Repartidor\PedidoController::class, 'confirmarRecogida']);
    Route::post('/pedidos/{id}/confirmar-entrega', [Repartidor\PedidoController::class, 'confirmarEntrega']);
    
    Route::post('/ubicacion', [Repartidor\UbicacionController::class, 'update']);
    Route::put('/estado', [Repartidor\PerfilController::class, 'updateEstado']);
    Route::get('/estadisticas', [Repartidor\PerfilController::class, 'estadisticas']);
});

Route::get('/pedidos/{token}/tracking', [PedidoController::class, 'tracking']);
