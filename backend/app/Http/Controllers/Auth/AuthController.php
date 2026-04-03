<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(RegisterRequest $request)
    {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => $request->password,
            'role' => $request->role ?? 'cliente',
        ]);

        $token = $user->createToken($request->device_name ?? 'app')->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'token' => $token,
                'expires_in' => config('sanctum.expiration') * 60
            ]
        ], 201);
    }

    public function login(LoginRequest $request)
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Las credenciales son incorrectas.'],
            ]);
        }

        if (!$user->is_active) {
            throw ValidationException::withMessages([
                'email' => ['Tu cuenta está desactivada.'],
            ]);
        }

        $user->update(['last_login_at' => now()]);

        $abilities = $this->getAbilitiesForRole($user->role);
        $token = $user->createToken($request->device_name ?? 'app', $abilities)->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'token' => $token,
                'expires_in' => config('sanctum.expiration') * 60
            ]
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Sesión cerrada exitosamente'
        ]);
    }

    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => $request->user()
        ]);
    }

    public function refresh(Request $request)
    {
        $user = $request->user();
        $request->user()->currentAccessToken()->delete();
        
        $abilities = $this->getAbilitiesForRole($user->role);
        $token = $user->createToken($request->device_name ?? 'app', $abilities)->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => [
                'token' => $token,
                'expires_in' => config('sanctum.expiration') * 60
            ]
        ]);
    }

    private function getAbilitiesForRole($role)
    {
        return match($role) {
            'cliente' => ['pedidos:create', 'pedidos:read', 'direcciones:*'],
            'comercio' => ['pedidos:*', 'productos:*', 'repartidores:read'],
            'repartidor' => ['pedidos:read', 'pedidos:update', 'ubicacion:update'],
            'admin' => ['*'],
            default => [],
        };
    }
}
