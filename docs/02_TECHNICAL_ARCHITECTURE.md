# 🏗️ ARQUITECTURA TÉCNICA - IZY

## 1. STACK TECNOLÓGICO COMPLETO

### 1.1 Backend Stack

| Componente | Tecnología | Versión | Propósito |
|------------|------------|---------|-----------|
| **Framework** | Laravel | 11.x | API RESTful + Business Logic |
| **Lenguaje** | PHP | 8.3+ | Server-side processing |
| **Base de Datos** | MySQL/MariaDB | 8.0 / 10.11 | Almacenamiento persistente |
| **Real-time** | Laravel Reverb | Latest | WebSockets para tracking |
| **Cache** | Redis | 7.x | Session, cache, queues |
| **Auth** | Laravel Sanctum | 4.x | API token authentication |
| **Queue** | Laravel Queue | - | Background jobs |
| **Storage** | Local/S3 | - | Imágenes y archivos |

### 1.2 Frontend/Mobile Stack

| Componente | Tecnología | Versión | Propósito |
|------------|------------|---------|-----------|
| **Framework** | Flutter | 3.19+ | Multi-platform (Web + Android) |
| **Lenguaje** | Dart | 3.3+ | Application logic |
| **State Management** | Riverpod | 2.5+ | Reactive state |
| **HTTP Client** | Dio | 5.x | API requests |
| **WebSockets** | socket_io_client | 2.x | Real-time updates |
| **Maps** | google_maps_flutter | Latest | Mapas y GPS |
| **Local DB** | Hive / Drift | Latest | Offline storage |
| **Notifications** | firebase_messaging | Latest | Push notifications |

### 1.3 Infraestructura

| Componente | Tecnología | Propósito |
|------------|------------|-----------|
| **Web Server** | Nginx | 1.24+ | Reverse proxy + static files |
| **Process Manager** | PHP-FPM | 8.3 | PHP process management |
| **SSL/TLS** | Let's Encrypt | - | HTTPS certificates |
| **Monitoring** | Laravel Telescope | - | Debug y monitoring |
| **Logs** | Laravel Log | - | Application logs |
| **Deployment** | Git + CI/CD | - | Automated deployment |

---

## 2. ARQUITECTURA DE SISTEMA

### 2.1 Diagrama de Alto Nivel

```
┌─────────────────────────────────────────────────────────────────┐
│                        CAPA DE CLIENTE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ PWA Cliente  │  │ App Comercio │  │App Repartidor│          │
│  │ Flutter Web  │  │Flutter Android│ │Flutter Android│         │
│  │              │  │              │  │              │          │
│  │ - Catálogo   │  │ - Dashboard  │  │ - GPS Track  │          │
│  │ - Checkout   │  │ - Kitchen    │  │ - Pedidos    │          │
│  │ - Tracking   │  │ - Productos  │  │ - Navegación │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                 │                  │                  │
└─────────┼─────────────────┼──────────────────┼──────────────────┘
          │                 │                  │
          └─────────────────┼──────────────────┘
                            │
                    ┌───────▼────────┐
                    │  Load Balancer │
                    │     (Nginx)    │
                    └───────┬────────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
    ┌─────▼──────┐   ┌─────▼──────┐   ┌─────▼──────┐
    │   Laravel  │   │  Laravel   │   │  Firebase  │
    │  REST API  │◄─►│   Reverb   │   │    FCM     │
    │            │   │ WebSockets │   │            │
    │ - Sanctum  │   │            │   │ - Push     │
    │ - Routes   │   │ - Events   │   │   Notify   │
    │ - Business │   │ - Channels │   │            │
    └─────┬──────┘   └────────────┘   └────────────┘
          │
          │
┌─────────▼──────────────────────────────────────────┐
│              CAPA DE DATOS                         │
├────────────────────────────────────────────────────┤
│                                                    │
│  ┌──────────────┐  ┌──────────────┐              │
│  │ MySQL/MariaDB│  │    Redis     │              │
│  │              │  │              │              │
│  │ - Comercios  │  │ - Cache      │              │
│  │ - Productos  │  │ - Sessions   │              │
│  │ - Pedidos    │  │ - Queues     │              │
│  │ - Users      │  │ - WebSocket  │              │
│  │ - Repartidor │  │   State      │              │
│  └──────────────┘  └──────────────┘              │
│                                                    │
└────────────────────────────────────────────────────┘
```

### 2.2 Flujo de Datos Principal

```
┌──────────┐
│ Cliente  │
│  (PWA)   │
└────┬─────┘
     │ 1. GET /api/comercios/{slug}/productos
     ▼
┌────────────┐
│   Nginx    │
└────┬───────┘
     │ 2. Forward request
     ▼
┌────────────────┐
│ Laravel API    │
│ Middleware:    │
│ - TenantScope  │◄─── 3. Identifica comercio por slug
│ - Sanctum Auth │
└────┬───────────┘
     │ 4. Query con comercio_id
     ▼
┌────────────┐
│   MySQL    │
└────┬───────┘
     │ 5. Return productos
     ▼
┌────────────────┐
│ Laravel API    │
│ - Transform    │
│ - Cache        │
└────┬───────────┘
     │ 6. JSON Response
     ▼
┌──────────┐
│ Cliente  │
│  (PWA)   │
└──────────┘
```

---

## 3. ARQUITECTURA MULTI-TENANT

### 3.1 Estrategia: Shared Database + Tenant Identifier

**Ventajas:**
- Menor costo de infraestructura
- Fácil mantenimiento
- Backup centralizado
- Escalabilidad horizontal

**Implementación:**

#### Middleware de Tenant
```php
// app/Http/Middleware/IdentifyTenant.php
namespace App\Http\Middleware;

use Closure;
use App\Models\Comercio;
use Illuminate\Http\Request;

class IdentifyTenant
{
    public function handle(Request $request, Closure $next)
    {
        // Identificar tenant por slug en URL o header
        $slug = $request->route('slug') 
             ?? $request->header('X-Tenant-Slug')
             ?? $request->input('comercio_slug');
        
        if ($slug) {
            $comercio = Comercio::where('slug', $slug)
                ->where('is_active', true)
                ->firstOrFail();
            
            // Almacenar en contexto de aplicación
            app()->instance('tenant', $comercio);
            config(['app.tenant_id' => $comercio->id]);
            
            // Logging para debugging
            logger()->info('Tenant identified', [
                'slug' => $slug,
                'comercio_id' => $comercio->id
            ]);
        }
        
        return $next($request);
    }
}
```

#### Global Scope para Modelos
```php
// app/Models/Scopes/TenantScope.php
namespace App\Models\Scopes;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Scope;

class TenantScope implements Scope
{
    public function apply(Builder $builder, Model $model)
    {
        if ($tenantId = config('app.tenant_id')) {
            $builder->where($model->getTable() . '.comercio_id', $tenantId);
        }
    }
}
```

#### Trait para Modelos Multi-tenant
```php
// app/Models/Traits/BelongsToTenant.php
namespace App\Models\Traits;

use App\Models\Scopes\TenantScope;

trait BelongsToTenant
{
    protected static function bootBelongsToTenant()
    {
        // Aplicar scope global
        static::addGlobalScope(new TenantScope);
        
        // Auto-asignar comercio_id al crear
        static::creating(function ($model) {
            if (!$model->comercio_id && $tenantId = config('app.tenant_id')) {
                $model->comercio_id = $tenantId;
            }
        });
    }
    
    public function comercio()
    {
        return $this->belongsTo(\App\Models\Comercio::class);
    }
}
```

#### Uso en Modelos
```php
// app/Models/Producto.php
namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Model;

class Producto extends Model
{
    use BelongsToTenant;
    
    protected $fillable = [
        'nombre', 'descripcion', 'precio_usd', 'precio_bs', 'stock'
    ];
    
    // El comercio_id se asigna automáticamente
    // Las queries se filtran automáticamente
}
```

### 3.2 Validación de Pertenencia

```php
// app/Policies/ProductoPolicy.php
namespace App\Policies;

use App\Models\User;
use App\Models\Producto;

class ProductoPolicy
{
    public function view(User $user, Producto $producto)
    {
        // Verificar que el producto pertenece al comercio del usuario
        return $user->comercio_id === $producto->comercio_id;
    }
    
    public function update(User $user, Producto $producto)
    {
        return $user->role === 'comercio' 
            && $user->comercio_id === $producto->comercio_id;
    }
    
    public function delete(User $user, Producto $producto)
    {
        return $user->role === 'comercio' 
            && $user->comercio_id === $producto->comercio_id;
    }
}
```

---

## 4. ARQUITECTURA DE FLUTTER (MULTI-TARGET)

### 4.1 Estructura de Proyecto

```
izy_flutter/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── main_comercio.dart           # Entry para app comercio
│   ├── main_repartidor.dart         # Entry para app repartidor
│   │
│   ├── core/
│   │   ├── config/
│   │   │   ├── app_config.dart      # Configuración global
│   │   │   ├── api_config.dart      # URLs y endpoints
│   │   │   └── theme_config.dart    # Temas base
│   │   │
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── api_constants.dart
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart      # HTTP client
│   │   │   ├── api_interceptor.dart # Auth interceptor
│   │   │   └── websocket_client.dart
│   │   │
│   │   └── utils/
│   │       ├── validators.dart
│   │       ├── formatters.dart
│   │       └── helpers.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── repositories/
│   │   │   │   └── datasources/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── screens/
│   │   │       └── widgets/
│   │   │
│   │   ├── cliente/                 # PWA Cliente
│   │   │   ├── catalogo/
│   │   │   ├── carrito/
│   │   │   ├── checkout/
│   │   │   └── tracking/
│   │   │
│   │   ├── comercio/                # App Comercio
│   │   │   ├── dashboard/
│   │   │   ├── kitchen/
│   │   │   ├── productos/
│   │   │   └── logistica/
│   │   │
│   │   └── repartidor/              # App Repartidor
│   │       ├── pedidos/
│   │       ├── navegacion/
│   │       └── historial/
│   │
│   └── shared/
│       ├── widgets/
│       ├── models/
│       └── providers/
│
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   ├── comercio/            # Flavor comercio
│   │   │   ├── repartidor/          # Flavor repartidor
│   │   │   └── main/                # Código compartido
│   │   └── build.gradle
│   └── build.gradle
│
├── web/
│   ├── index.html
│   ├── manifest.json                # PWA manifest
│   └── service-worker.js
│
└── pubspec.yaml
```

### 4.2 Flutter Flavors (Build Variants)

#### Configuración en build.gradle
```gradle
// android/app/build.gradle
android {
    flavorDimensions "app"
    
    productFlavors {
        comercio {
            dimension "app"
            applicationId "com.izy.comercio"
            versionCode 1
            versionName "1.0.0"
            resValue "string", "app_name", "IZY Comercio"
        }
        
        repartidor {
            dimension "app"
            applicationId "com.izy.repartidor"
            versionCode 1
            versionName "1.0.0"
            resValue "string", "app_name", "IZY Repartidor"
        }
    }
}
```

#### Entry Points Diferenciados
```dart
// lib/main_comercio.dart
import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'features/comercio/presentation/screens/comercio_app.dart';

void main() {
  AppConfig.initialize(
    appType: AppType.comercio,
    apiBaseUrl: 'https://api.izy.com',
  );
  
  runApp(const ComercioApp());
}

// lib/main_repartidor.dart
import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'features/repartidor/presentation/screens/repartidor_app.dart';

void main() {
  AppConfig.initialize(
    appType: AppType.repartidor,
    apiBaseUrl: 'https://api.izy.com',
  );
  
  runApp(const RepartidorApp());
}
```

#### Comandos de Build
```bash
# PWA Cliente
flutter build web --release

# App Comercio
flutter build apk --flavor comercio --release

# App Repartidor
flutter build apk --flavor repartidor --release
```

### 4.3 Arquitectura Clean + Riverpod

```dart
// Ejemplo: Feature de Productos

// 1. ENTITY (Domain Layer)
class Producto {
  final int id;
  final String nombre;
  final double precioUsd;
  final double precioBs;
  
  Producto({required this.id, required this.nombre, ...});
}

// 2. REPOSITORY INTERFACE (Domain Layer)
abstract class ProductoRepository {
  Future<List<Producto>> getProductos(int comercioId);
  Future<Producto> getProducto(int id);
  Future<void> createProducto(Producto producto);
}

// 3. REPOSITORY IMPLEMENTATION (Data Layer)
class ProductoRepositoryImpl implements ProductoRepository {
  final DioClient _client;
  
  ProductoRepositoryImpl(this._client);
  
  @override
  Future<List<Producto>> getProductos(int comercioId) async {
    final response = await _client.get('/productos');
    return (response.data as List)
        .map((json) => ProductoModel.fromJson(json).toEntity())
        .toList();
  }
}

// 4. PROVIDER (Presentation Layer)
final productoRepositoryProvider = Provider<ProductoRepository>((ref) {
  return ProductoRepositoryImpl(ref.watch(dioClientProvider));
});

final productosProvider = FutureProvider.autoDispose
    .family<List<Producto>, int>((ref, comercioId) async {
  final repository = ref.watch(productoRepositoryProvider);
  return repository.getProductos(comercioId);
});

// 5. UI (Presentation Layer)
class ProductosScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productosProvider(1));
    
    return productosAsync.when(
      data: (productos) => ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) => ProductoCard(productos[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

---

## 5. SISTEMA DE REAL-TIME (WEBSOCKETS)

### 5.1 Laravel Reverb Setup

```php
// config/broadcasting.php
'connections' => [
    'reverb' => [
        'driver' => 'reverb',
        'key' => env('REVERB_APP_KEY'),
        'secret' => env('REVERB_APP_SECRET'),
        'app_id' => env('REVERB_APP_ID'),
        'options' => [
            'host' => env('REVERB_HOST', '0.0.0.0'),
            'port' => env('REVERB_PORT', 8080),
            'scheme' => env('REVERB_SCHEME', 'http'),
        ],
    ],
],
```

### 5.2 Eventos Broadcast

```php
// app/Events/PedidoEstadoActualizado.php
namespace App\Events;

use App\Models\Pedido;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Queue\SerializesModels;

class PedidoEstadoActualizado implements ShouldBroadcast
{
    use InteractsWithSockets, SerializesModels;
    
    public $pedido;
    
    public function __construct(Pedido $pedido)
    {
        $this->pedido = $pedido;
    }
    
    public function broadcastOn()
    {
        return [
            new Channel('pedido.' . $this->pedido->id),
            new Channel('comercio.' . $this->pedido->comercio_id),
        ];
    }
    
    public function broadcastWith()
    {
        return [
            'pedido_id' => $this->pedido->id,
            'estado' => $this->pedido->estado,
            'timestamp' => now()->toIso8601String(),
        ];
    }
}
```

```php
// app/Events/RepartidorUbicacionActualizada.php
class RepartidorUbicacionActualizada implements ShouldBroadcast
{
    public $pedidoId;
    public $lat;
    public $lng;
    
    public function broadcastOn()
    {
        return new Channel('pedido.' . $this->pedidoId . '.tracking');
    }
}
```

### 5.3 Cliente WebSocket (Flutter)

```dart
// lib/core/network/websocket_client.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketClient {
  IO.Socket? _socket;
  
  void connect(String url, String token) {
    _socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'auth': {'token': token},
    });
    
    _socket!.onConnect((_) {
      print('WebSocket connected');
    });
    
    _socket!.onDisconnect((_) {
      print('WebSocket disconnected');
    });
  }
  
  void subscribeToPedido(int pedidoId, Function(Map<String, dynamic>) callback) {
    _socket!.on('pedido.$pedidoId', (data) {
      callback(data as Map<String, dynamic>);
    });
  }
  
  void subscribeToTracking(int pedidoId, Function(double, double) callback) {
    _socket!.on('pedido.$pedidoId.tracking', (data) {
      final lat = data['lat'] as double;
      final lng = data['lng'] as double;
      callback(lat, lng);
    });
  }
  
  void disconnect() {
    _socket?.disconnect();
  }
}
```

---

## 6. SEGURIDAD

### 6.1 Laravel Sanctum

```php
// app/Http/Controllers/AuthController.php
public function login(Request $request)
{
    $request->validate([
        'email' => 'required|email',
        'password' => 'required',
        'device_name' => 'required',
    ]);
    
    $user = User::where('email', $request->email)->first();
    
    if (!$user || !Hash::check($request->password, $user->password)) {
        throw ValidationException::withMessages([
            'email' => ['Las credenciales son incorrectas.'],
        ]);
    }
    
    // Crear token con habilidades específicas
    $token = $user->createToken($request->device_name, [
        'pedidos:create',
        'pedidos:read',
    ])->plainTextToken;
    
    return response()->json([
        'token' => $token,
        'user' => $user,
        'expires_in' => config('sanctum.expiration'),
    ]);
}
```

### 6.2 Rate Limiting

```php
// app/Http/Kernel.php
protected $middlewareGroups = [
    'api' => [
        'throttle:api',
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ],
];

// routes/api.php
Route::middleware(['throttle:60,1'])->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
});

Route::middleware(['auth:sanctum', 'throttle:120,1'])->group(function () {
    Route::apiResource('productos', ProductoController::class);
});
```

### 6.3 Validación y Sanitización

```php
// app/Http/Requests/StorePedidoRequest.php
class StorePedidoRequest extends FormRequest
{
    public function rules()
    {
        return [
            'items' => 'required|array|min:1',
            'items.*.producto_id' => 'required|exists:productos,id',
            'items.*.cantidad' => 'required|integer|min:1|max:99',
            'tipo_pago' => 'required|in:efectivo,pago_movil,transferencia',
            'direccion.lat' => 'required|numeric|between:-90,90',
            'direccion.lng' => 'required|numeric|between:-180,180',
            'vuelto_de' => 'nullable|numeric|min:0',
        ];
    }
    
    protected function prepareForValidation()
    {
        // Sanitizar datos
        $this->merge([
            'notas_cliente' => strip_tags($this->notas_cliente),
        ]);
    }
}
```

---

## 7. PERFORMANCE Y OPTIMIZACIÓN

### 7.1 Caching con Redis

```php
// Cachear productos por comercio
public function getProductos($comercioId)
{
    return Cache::remember("comercio.{$comercioId}.productos", 3600, function() use ($comercioId) {
        return Producto::where('comercio_id', $comercioId)
            ->where('is_active', true)
            ->with('categoria')
            ->get();
    });
}

// Invalidar cache al actualizar
public function updateProducto(Producto $producto)
{
    $producto->update($data);
    Cache::forget("comercio.{$producto->comercio_id}.productos");
}
```

### 7.2 Eager Loading

```php
// Evitar N+1 queries
$pedidos = Pedido::with([
    'items.producto',
    'cliente',
    'repartidor.user',
    'comercio'
])->get();
```

### 7.3 Queue Jobs

```php
// app/Jobs/EnviarNotificacionPedido.php
class EnviarNotificacionPedido implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;
    
    public $pedido;
    
    public function handle()
    {
        // Enviar notificación FCM
        FCM::send($this->pedido->cliente->fcm_token, [
            'title' => 'Pedido confirmado',
            'body' => "Tu pedido #{$this->pedido->numero_pedido} está en preparación",
        ]);
    }
}

// Dispatch
EnviarNotificacionPedido::dispatch($pedido);
```

---

## 8. DEPLOYMENT

### 8.1 Nginx Configuration

```nginx
server {
    listen 80;
    server_name api.izy.com;
    root /var/www/izy/public;
    
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    
    index index.php;
    
    charset utf-8;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }
    
    error_page 404 /index.php;
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

### 8.2 Environment Variables

```env
# .env
APP_NAME=IZY
APP_ENV=production
APP_KEY=base64:...
APP_DEBUG=false
APP_URL=https://api.izy.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=izy_production
DB_USERNAME=izy_user
DB_PASSWORD=...

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

REVERB_APP_ID=...
REVERB_APP_KEY=...
REVERB_APP_SECRET=...
REVERB_HOST=0.0.0.0
REVERB_PORT=8080
REVERB_SCHEME=https

FIREBASE_CREDENTIALS=...
```

---

## 9. MONITOREO Y LOGGING

### 9.1 Laravel Telescope

```php
// config/telescope.php
'watchers' => [
    Watchers\QueryWatcher::class => [
        'enabled' => env('TELESCOPE_QUERY_WATCHER', true),
        'slow' => 100, // ms
    ],
    Watchers\RequestWatcher::class => true,
    Watchers\ExceptionWatcher::class => true,
],
```

### 9.2 Custom Logging

```php
// Logging de eventos críticos
Log::channel('pedidos')->info('Pedido creado', [
    'pedido_id' => $pedido->id,
    'comercio_id' => $pedido->comercio_id,
    'total_usd' => $pedido->total_usd,
]);

Log::channel('repartidores')->warning('Repartidor rechazó pedido', [
    'repartidor_id' => $repartidor->id,
    'pedido_id' => $pedido->id,
    'razon' => $razon,
]);
```
