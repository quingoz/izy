# Issue #4: Sistema de Autenticación con Sanctum

**Epic:** Backend Core & Database  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 1

---

## Descripción

Implementar sistema completo de autenticación usando Laravel Sanctum con soporte para múltiples roles (cliente, comercio, repartidor, admin).

## Objetivos

- Configurar Laravel Sanctum
- Crear AuthController con endpoints de auth
- Implementar middleware de roles
- Rate limiting para seguridad
- Tests de autenticación

## Tareas Técnicas

### 1. Publicar Configuración de Sanctum

```bash
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

### 2. Configurar Sanctum

**Archivo:** `config/sanctum.php`

```php
'expiration' => 1440, // 24 horas
'token_prefix' => env('SANCTUM_TOKEN_PREFIX', ''),
```

**Archivo:** `.env`

```env
SANCTUM_STATEFUL_DOMAINS=localhost,localhost:3000,127.0.0.1
```

### 3. Crear AuthController

**Archivo:** `app/Http/Controllers/Auth/AuthController.php`

```php
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

        // Actualizar último login
        $user->update(['last_login_at' => now()]);

        // Crear token con habilidades según rol
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
```

### 4. Crear Form Requests

**Archivo:** `app/Http/Requests/Auth/RegisterRequest.php`

```php
<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users'],
            'password' => ['required', 'confirmed', Password::min(8)],
            'role' => ['nullable', 'in:cliente,comercio,repartidor'],
            'device_name' => ['nullable', 'string']
        ];
    }

    public function messages()
    {
        return [
            'email.unique' => 'Este email ya está registrado',
            'phone.unique' => 'Este teléfono ya está registrado',
            'password.confirmed' => 'Las contraseñas no coinciden',
        ];
    }
}
```

**Archivo:** `app/Http/Requests/Auth/LoginRequest.php`

```php
<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string']
        ];
    }
}
```

### 5. Crear Middleware de Roles

**Archivo:** `app/Http/Middleware/CheckRole.php`

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckRole
{
    public function handle(Request $request, Closure $next, ...$roles)
    {
        if (!$request->user()) {
            return response()->json([
                'success' => false,
                'message' => 'No autenticado'
            ], 401);
        }

        if (!in_array($request->user()->role, $roles)) {
            return response()->json([
                'success' => false,
                'message' => 'No tienes permisos para esta acción'
            ], 403);
        }

        return $next($request);
    }
}
```

**Registrar en:** `app/Http/Kernel.php`

```php
protected $middlewareAliases = [
    // ...
    'role' => \App\Http\Middleware\CheckRole::class,
];
```

### 6. Configurar Rutas

**Archivo:** `routes/api.php`

```php
<?php

use App\Http\Controllers\Auth\AuthController;
use Illuminate\Support\Facades\Route;

// Rutas públicas con rate limiting
Route::middleware(['throttle:5,1'])->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);
});

// Rutas protegidas
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::post('/auth/refresh', [AuthController::class, 'refresh']);
    Route::get('/auth/me', [AuthController::class, 'me']);
});
```

### 7. Configurar Rate Limiting

**Archivo:** `app/Providers/RouteServiceProvider.php`

```php
protected function configureRateLimiting()
{
    RateLimiter::for('api', function (Request $request) {
        return Limit::perMinute(120)->by($request->user()?->id ?: $request->ip());
    });

    RateLimiter::for('auth', function (Request $request) {
        return Limit::perMinute(5)->by($request->ip());
    });
}
```

### 8. Password Reset (Opcional)

**Archivo:** `app/Http/Controllers/Auth/PasswordResetController.php`

```php
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\ValidationException;

class PasswordResetController extends Controller
{
    public function sendResetLink(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $status = Password::sendResetLink(
            $request->only('email')
        );

        if ($status === Password::RESET_LINK_SENT) {
            return response()->json([
                'success' => true,
                'message' => 'Link de recuperación enviado'
            ]);
        }

        throw ValidationException::withMessages([
            'email' => [__($status)],
        ]);
    }

    public function reset(Request $request)
    {
        $request->validate([
            'token' => 'required',
            'email' => 'required|email',
            'password' => 'required|min:8|confirmed',
        ]);

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function ($user, $password) {
                $user->forceFill([
                    'password' => $password
                ])->save();
            }
        );

        if ($status === Password::PASSWORD_RESET) {
            return response()->json([
                'success' => true,
                'message' => 'Contraseña actualizada'
            ]);
        }

        throw ValidationException::withMessages([
            'email' => [__($status)],
        ]);
    }
}
```

### 9. Crear Tests

**Archivo:** `tests/Feature/Auth/AuthenticationTest.php`

```php
<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthenticationTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register()
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'cliente'
        ]);

        $response->assertStatus(201)
                 ->assertJsonStructure([
                     'success',
                     'data' => ['user', 'token', 'expires_in']
                 ]);

        $this->assertDatabaseHas('users', [
            'email' => 'test@example.com'
        ]);
    }

    public function test_user_can_login()
    {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => 'password123'
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'password123',
            'device_name' => 'test-device'
        ]);

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data' => ['user', 'token']
                 ]);
    }

    public function test_user_cannot_login_with_invalid_credentials()
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'wrong@example.com',
            'password' => 'wrongpassword'
        ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['email']);
    }

    public function test_user_can_logout()
    {
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                         ->postJson('/api/auth/logout');

        $response->assertStatus(200);
    }

    public function test_authenticated_user_can_get_profile()
    {
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                         ->getJson('/api/auth/me');

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'data' => [
                         'id' => $user->id,
                         'email' => $user->email
                     ]
                 ]);
    }

    public function test_rate_limiting_on_login()
    {
        for ($i = 0; $i < 6; $i++) {
            $response = $this->postJson('/api/auth/login', [
                'email' => 'test@example.com',
                'password' => 'password'
            ]);
        }

        $response->assertStatus(429); // Too Many Requests
    }
}
```

## Definición de Hecho (DoD)

- [ ] Sanctum configurado correctamente
- [ ] AuthController con todos los métodos
- [ ] Form Requests con validaciones
- [ ] Middleware de roles funcionando
- [ ] Rate limiting implementado
- [ ] Tests de autenticación pasando (>90% coverage)
- [ ] Documentación de endpoints actualizada

## Comandos de Verificación

```bash
# Ejecutar tests
php artisan test --filter=AuthenticationTest

# Probar endpoints con Postman/Insomnia
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
GET /api/auth/me

# Verificar tokens en DB
php artisan tinker
>>> \Laravel\Sanctum\PersonalAccessToken::all();
```

## Endpoints Creados

```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout (protected)
POST   /api/auth/refresh (protected)
GET    /api/auth/me (protected)
POST   /api/auth/password/email
POST   /api/auth/password/reset
```

## Dependencias

- Issue #3: Implementar Modelos Eloquent

## Siguiente Issue

Issue #5: Implementar Multi-tenancy
