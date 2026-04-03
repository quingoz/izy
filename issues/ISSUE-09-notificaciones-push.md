# Issue #9: Sistema de Notificaciones Push (FCM)

**Epic:** Backend Core & Database  
**Prioridad:** Media  
**Estimación:** 2 días  
**Sprint:** Sprint 3

---

## Descripción

Implementar sistema de notificaciones push usando Firebase Cloud Messaging para alertas en tiempo real.

## Objetivos

- Configurar Firebase Cloud Messaging
- Servicio para envío de notificaciones
- Jobs asíncronos para notificaciones
- Endpoint para actualizar FCM token
- Notificaciones por evento del pedido

## Tareas Técnicas

### 1. Configurar Firebase

1. Crear proyecto en Firebase Console
2. Descargar `google-services.json` (Android)
3. Descargar credenciales JSON del servidor

**Archivo:** `.env`

```env
FIREBASE_CREDENTIALS=path/to/firebase-credentials.json
```

### 2. Instalar Paquete

```bash
composer require kreait/firebase-php
```

### 3. Servicio FCM

**Archivo:** `app/Services/FCMService.php`

```php
<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FCMService
{
    protected $messaging;

    public function __construct()
    {
        $factory = (new Factory)->withServiceAccount(env('FIREBASE_CREDENTIALS'));
        $this->messaging = $factory->createMessaging();
    }

    public function sendToUser($userId, $title, $body, $data = [])
    {
        $user = \App\Models\User::find($userId);
        
        if (!$user || !$user->fcm_token) {
            return false;
        }

        return $this->sendToToken($user->fcm_token, $title, $body, $data);
    }

    public function sendToToken($token, $title, $body, $data = [])
    {
        try {
            $notification = Notification::create($title, $body);
            
            $message = CloudMessage::withTarget('token', $token)
                ->withNotification($notification)
                ->withData($data);

            $this->messaging->send($message);
            
            return true;
        } catch (\Exception $e) {
            logger()->error('Error enviando FCM', [
                'error' => $e->getMessage(),
                'token' => $token
            ]);
            return false;
        }
    }

    public function sendMulticast(array $tokens, $title, $body, $data = [])
    {
        try {
            $notification = Notification::create($title, $body);
            
            $message = CloudMessage::new()
                ->withNotification($notification)
                ->withData($data);

            $this->messaging->sendMulticast($message, $tokens);
            
            return true;
        } catch (\Exception $e) {
            logger()->error('Error enviando FCM multicast', [
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }
}
```

### 4. Jobs para Notificaciones

**Archivo:** `app/Jobs/SendPushNotification.php`

```php
<?php

namespace App\Jobs;

use App\Services\FCMService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendPushNotification implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $userId;
    public $title;
    public $body;
    public $data;

    public function __construct($userId, $title, $body, $data = [])
    {
        $this->userId = $userId;
        $this->title = $title;
        $this->body = $body;
        $this->data = $data;
        $this->onQueue('notifications');
    }

    public function handle(FCMService $fcm)
    {
        $fcm->sendToUser($this->userId, $this->title, $this->body, $this->data);
    }
}
```

### 5. Notificaciones por Evento

**Archivo:** `app/Listeners/EnviarNotificacionNuevoPedido.php`

```php
<?php

namespace App\Listeners;

use App\Events\PedidoEstadoActualizado;
use App\Jobs\SendPushNotification;

class EnviarNotificacionNuevoPedido
{
    public function handle(PedidoEstadoActualizado $event)
    {
        $pedido = $event->pedido;

        match($pedido->estado) {
            'pendiente' => $this->notificarComercio($pedido),
            'confirmado' => $this->notificarCliente($pedido, 'Pedido confirmado', 'Tu pedido está siendo preparado'),
            'listo' => $this->notificarRepartidor($pedido),
            'en_camino' => $this->notificarCliente($pedido, 'Pedido en camino', 'Tu pedido está en camino'),
            'entregado' => $this->notificarClienteYComercio($pedido),
            default => null,
        };
    }

    private function notificarComercio($pedido)
    {
        $comercio = $pedido->comercio;
        $admin = $comercio->users()->where('role', 'comercio')->first();

        if ($admin) {
            SendPushNotification::dispatch(
                $admin->id,
                '🔔 Nuevo Pedido',
                "Pedido #{$pedido->numero_pedido} - Total: \${$pedido->total_usd}",
                [
                    'type' => 'nuevo_pedido',
                    'pedido_id' => $pedido->id,
                    'action' => 'open_pedido'
                ]
            );
        }
    }

    private function notificarCliente($pedido, $title, $body)
    {
        SendPushNotification::dispatch(
            $pedido->cliente_id,
            $title,
            $body,
            [
                'type' => 'pedido_actualizado',
                'pedido_id' => $pedido->id,
                'estado' => $pedido->estado,
                'action' => 'open_tracking'
            ]
        );
    }

    private function notificarRepartidor($pedido)
    {
        if ($pedido->repartidor_id) {
            SendPushNotification::dispatch(
                $pedido->repartidor->user_id,
                '📦 Pedido Listo',
                "Pedido #{$pedido->numero_pedido} listo para recoger",
                [
                    'type' => 'pedido_listo',
                    'pedido_id' => $pedido->id,
                    'action' => 'open_pedido'
                ]
            );
        }
    }

    private function notificarClienteYComercio($pedido)
    {
        $this->notificarCliente($pedido, '✅ Pedido Entregado', 'Tu pedido ha sido entregado');
        
        $comercio = $pedido->comercio;
        $admin = $comercio->users()->where('role', 'comercio')->first();
        
        if ($admin) {
            SendPushNotification::dispatch(
                $admin->id,
                'Pedido Completado',
                "Pedido #{$pedido->numero_pedido} entregado exitosamente",
                ['type' => 'pedido_completado', 'pedido_id' => $pedido->id]
            );
        }
    }
}
```

**Registrar en:** `app/Providers/EventServiceProvider.php`

```php
protected $listen = [
    PedidoEstadoActualizado::class => [
        EnviarNotificacionNuevoPedido::class,
    ],
];
```

### 6. Endpoint para FCM Token

**Archivo:** `app/Http/Controllers/UserController.php`

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class UserController extends Controller
{
    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string'
        ]);

        $request->user()->update([
            'fcm_token' => $request->fcm_token
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Token actualizado'
        ]);
    }
}
```

**Ruta:** `routes/api.php`

```php
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/user/fcm-token', [UserController::class, 'updateFcmToken']);
});
```

## Definición de Hecho (DoD)

- [ ] Firebase configurado correctamente
- [ ] Servicio FCM funcionando
- [ ] Jobs en queue procesándose
- [ ] Notificaciones se envían por cada evento
- [ ] Endpoint de FCM token operativo
- [ ] Deep linking configurado
- [ ] Tests pasando

## Comandos de Verificación

```bash
# Procesar queue de notificaciones
php artisan queue:work --queue=notifications

# Probar envío manual
php artisan tinker
>>> $fcm = app(\App\Services\FCMService::class);
>>> $fcm->sendToUser(1, 'Test', 'Mensaje de prueba');
```

## Dependencias

- Issue #8: Sistema de WebSockets con Laravel Reverb

## Siguiente Issue

Issue #10: API de Gestión de Pedidos (Comercio)
