# 🚀 IZY - SaaS Delivery Ecosystem

![IZY Logo](izy-logo.png)

**IZY** es una plataforma de delivery SaaS Multi-tenant diseñada específicamente para el mercado venezolano. Permite que múltiples comercios operen de forma aislada bajo una misma infraestructura, gestionando productos, pedidos y repartidores (exclusivos y freelance).

---

## 📋 Características Principales

### 🌐 PWA Cliente (Flutter Web)
- ✅ Acceso dinámico por slug: `domain.com/{slug_negocio}`
- ✅ Branding personalizado por comercio (colores, logos)
- ✅ Catálogo de productos con búsqueda y filtros
- ✅ Carrito de compras con persistencia local
- ✅ Checkout con múltiples métodos de pago (Efectivo, Pago Móvil)
- ✅ Tracking GPS en tiempo real del repartidor
- ✅ Soporte multi-moneda (USD/Bs)

### 📱 App Comercio (Flutter Android)
- ✅ Dashboard con pedidos activos en tiempo real
- ✅ Kitchen Flow: gestión de estados de pedidos
- ✅ Alertas sonoras para nuevos pedidos
- ✅ Gestión de productos (CRUD completo)
- ✅ Control de inventario
- ✅ Asignación de repartidores (manual y automática)
- ✅ Reportes y estadísticas de ventas

### 🏍️ App Repartidor (Flutter Android)
- ✅ Modo Exclusivo y Freelance
- ✅ GPS tracking en segundo plano
- ✅ Recepción de ofertas de pedidos cercanos (radio 3km)
- ✅ Navegación integrada (Google Maps/Waze)
- ✅ Confirmación de recogida y entrega
- ✅ Registro de cobros en efectivo
- ✅ Historial de entregas y ganancias

### 🔧 Backend (Laravel 11)
- ✅ API RESTful con Laravel Sanctum
- ✅ Arquitectura Multi-tenant (aislamiento por comercio_id)
- ✅ WebSockets con Laravel Reverb
- ✅ Notificaciones Push (Firebase FCM)
- ✅ Sistema de asignación inteligente de repartidores
- ✅ Cálculo de distancias con Haversine
- ✅ Cache con Redis

---

## 🛠️ Stack Tecnológico

### Backend
- **Framework:** Laravel 11 (PHP 8.3)
- **Base de Datos:** MySQL 8.0 / MariaDB 10.11
- **Real-time:** Laravel Reverb (WebSockets)
- **Cache/Queue:** Redis 7.x
- **Auth:** Laravel Sanctum
- **Notifications:** Firebase Cloud Messaging

### Frontend/Mobile
- **Framework:** Flutter 3.19+
- **State Management:** Riverpod 2.x
- **HTTP Client:** Dio
- **Maps:** Google Maps Flutter
- **WebSockets:** socket_io_client
- **Local Storage:** Hive

### Infraestructura
- **Web Server:** Nginx 1.24
- **PHP:** PHP-FPM 8.3
- **SSL:** Let's Encrypt
- **Monitoring:** Laravel Telescope

---

## 📁 Estructura del Proyecto

```
izy/
├── backend/                    # Laravel API
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   ├── Middleware/
│   │   │   └── Requests/
│   │   ├── Models/
│   │   ├── Policies/
│   │   ├── Events/
│   │   └── Jobs/
│   ├── database/
│   │   ├── migrations/
│   │   └── seeders/
│   ├── routes/
│   │   └── api.php
│   └── tests/
│
├── frontend/                   # Flutter Multi-target
│   ├── lib/
│   │   ├── core/
│   │   ├── features/
│   │   │   ├── cliente/       # PWA
│   │   │   ├── comercio/      # App Android
│   │   │   └── repartidor/    # App Android
│   │   └── shared/
│   ├── android/
│   │   └── app/
│   │       └── src/
│   │           ├── comercio/  # Flavor
│   │           └── repartidor/# Flavor
│   └── web/
│
├── docs/                       # Documentación
│   ├── 01_PROJECT_CHARTER.md
│   ├── 02_TECHNICAL_ARCHITECTURE.md
│   ├── 03_DATABASE_SCHEMA.md
│   ├── 04_DEVELOPMENT_PLAN.md
│   ├── 05_GITHUB_ISSUES.md
│   └── 06_API_DOCUMENTATION.md
│
└── README.md
```

---

## 🚀 Instalación y Configuración

### Requisitos Previos

- PHP 8.3+
- Composer
- MySQL 8.0+ / MariaDB 10.11+
- Redis 7.x
- Node.js 18+ (para Laravel Reverb)
- Flutter 3.19+
- Android Studio (para apps móviles)

### Backend Setup

```bash
# Clonar repositorio
git clone https://github.com/tu-usuario/izy.git
cd izy/backend

# Instalar dependencias
composer install

# Configurar entorno
cp .env.example .env
php artisan key:generate

# Configurar base de datos en .env
DB_DATABASE=izy_dev
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password

# Ejecutar migraciones y seeders
php artisan migrate:fresh --seed

# Iniciar servicios
php artisan serve                # API en http://localhost:8000
php artisan reverb:start         # WebSockets en ws://localhost:8080
php artisan queue:work           # Queue worker
```

### Frontend Setup

```bash
cd ../frontend

# Instalar dependencias
flutter pub get

# Ejecutar PWA Cliente
flutter run -d chrome

# Ejecutar App Comercio
flutter run --flavor comercio -d <device_id>

# Ejecutar App Repartidor
flutter run --flavor repartidor -d <device_id>
```

### Configuración de Firebase

1. Crear proyecto en [Firebase Console](https://console.firebase.google.com)
2. Descargar `google-services.json` para Android
3. Configurar FCM en Laravel:
   ```env
   FIREBASE_CREDENTIALS=path/to/firebase-credentials.json
   ```

### Configuración de Google Maps

1. Obtener API Key en [Google Cloud Console](https://console.cloud.google.com)
2. Habilitar APIs:
   - Maps JavaScript API
   - Geocoding API
   - Directions API
3. Configurar en Flutter:
   ```dart
   // lib/core/config/app_config.dart
   static const googleMapsApiKey = 'TU_API_KEY';
   ```

---

## 📊 Base de Datos

### Diagrama ER Simplificado

```
users ──┬── comercios ──── productos
        │                      │
        ├── repartidores       │
        │        │             │
        └── pedidos ───────────┘
                │
                └── pedido_items
```

### Migraciones

```bash
# Ejecutar migraciones
php artisan migrate

# Rollback
php artisan migrate:rollback

# Refresh (drop all + migrate)
php artisan migrate:fresh --seed
```

---

## 🧪 Testing

### Backend Tests

```bash
# Todos los tests
php artisan test

# Tests específicos
php artisan test --filter=AuthTest
php artisan test --filter=PedidoTest
php artisan test --filter=TenantTest

# Con coverage
php artisan test --coverage
```

### Frontend Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Con coverage
flutter test --coverage
```

---

## 🏗️ Build para Producción

### Backend

```bash
# Optimizar autoloader
composer install --optimize-autoloader --no-dev

# Cachear configuración
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Ejecutar migraciones
php artisan migrate --force
```

### PWA Cliente

```bash
flutter build web --release

# Output en: build/web/
# Subir a servidor o CDN
```

### App Comercio

```bash
flutter build apk --flavor comercio --release

# Output: build/app/outputs/flutter-apk/app-comercio-release.apk
```

### App Repartidor

```bash
flutter build apk --flavor repartidor --release

# Output: build/app/outputs/flutter-apk/app-repartidor-release.apk
```

---

## 🔐 Seguridad

### Autenticación
- Laravel Sanctum con tokens Bearer
- Expiración de tokens: 24 horas
- Rate limiting: 60 requests/minuto

### Multi-tenancy
- Aislamiento por `comercio_id`
- Global Scopes en modelos Eloquent
- Políticas de autorización estrictas

### Validación
- Form Requests en todos los endpoints
- Sanitización de inputs
- Protección contra SQL Injection
- CORS configurado

---

## 📡 API Endpoints

### Autenticación
```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout
GET    /api/auth/me
```

### Comercios y Productos
```
GET    /api/comercios/{slug}
GET    /api/comercios/cercanos
GET    /api/comercios/{slug}/productos
GET    /api/productos/{id}
```

### Pedidos (Cliente)
```
POST   /api/pedidos
GET    /api/mis-pedidos
GET    /api/pedidos/{id}
GET    /api/pedidos/{token}/tracking
```

### Pedidos (Comercio)
```
GET    /api/comercio/pedidos
PUT    /api/comercio/pedidos/{id}/estado
POST   /api/comercio/pedidos/{id}/asignar-repartidor
```

### Repartidor
```
GET    /api/repartidor/pedidos/disponibles
POST   /api/repartidor/pedidos/{id}/aceptar
POST   /api/repartidor/ubicacion
POST   /api/repartidor/pedidos/{id}/confirmar-entrega
```

**Documentación completa:** [docs/06_API_DOCUMENTATION.md](docs/06_API_DOCUMENTATION.md)

---

## 🌐 WebSockets (Laravel Reverb)

### Eventos Broadcast

- `PedidoEstadoActualizado` - Cambio de estado de pedido
- `RepartidorUbicacionActualizada` - Actualización GPS
- `PedidoAsignado` - Repartidor asignado
- `PedidoCancelado` - Pedido cancelado

### Canales

- `pedido.{id}` - Canal privado por pedido
- `comercio.{id}` - Canal del comercio
- `repartidor.{id}` - Canal del repartidor

### Conexión desde Flutter

```dart
final socket = IO.io('ws://localhost:8080', {
  'transports': ['websocket'],
  'auth': {'token': authToken},
});

socket.on('pedido.1', (data) {
  print('Estado actualizado: ${data['estado']}');
});
```

---

## 📱 Flutter Flavors

### Configuración

```gradle
// android/app/build.gradle
flavorDimensions "app"

productFlavors {
    comercio {
        applicationId "com.izy.comercio"
        resValue "string", "app_name", "IZY Comercio"
    }
    repartidor {
        applicationId "com.izy.repartidor"
        resValue "string", "app_name", "IZY Repartidor"
    }
}
```

### Comandos

```bash
# Desarrollo
flutter run --flavor comercio
flutter run --flavor repartidor

# Release
flutter build apk --flavor comercio --release
flutter build apk --flavor repartidor --release
```

---

## 🗺️ GPS Tracking

### Configuración de Permisos (Android)

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### Servicio en Segundo Plano

```dart
// Iniciar tracking
await LocationService.startTracking(pedidoId);

// Detener tracking
await LocationService.stopTracking();

// Envía ubicación cada 10 segundos a:
// POST /api/repartidor/ubicacion
```

---

## 📈 Monitoreo y Logs

### Laravel Telescope

Acceder a: `http://localhost:8000/telescope`

- Requests HTTP
- Queries SQL (con detección de N+1)
- Jobs y Queues
- Exceptions
- Cache hits/misses

### Logs

```bash
# Ver logs en tiempo real
tail -f storage/logs/laravel.log

# Logs por canal
tail -f storage/logs/pedidos.log
tail -f storage/logs/repartidores.log
```

---

## 🐛 Troubleshooting

### Error: "Class 'Redis' not found"

```bash
# Instalar extensión PHP Redis
sudo apt-get install php8.3-redis
sudo systemctl restart php8.3-fpm
```

### Error: WebSocket connection failed

```bash
# Verificar que Reverb está ejecutando
php artisan reverb:start

# Verificar puerto en .env
REVERB_PORT=8080
```

### Error: GPS no actualiza en segundo plano

```xml
<!-- Agregar en AndroidManifest.xml -->
<service
    android:name=".LocationService"
    android:foregroundServiceType="location" />
```

---

## 📚 Documentación Adicional

- **[Project Charter](docs/01_PROJECT_CHARTER.md)** - Visión general y objetivos
- **[Arquitectura Técnica](docs/02_TECHNICAL_ARCHITECTURE.md)** - Stack y patrones
- **[Esquema de Base de Datos](docs/03_DATABASE_SCHEMA.md)** - Tablas y relaciones
- **[Plan de Desarrollo](docs/04_DEVELOPMENT_PLAN.md)** - Sprints de 8 semanas
- **[GitHub Issues](docs/05_GITHUB_ISSUES.md)** - Issues detallados por Epic
- **[API Documentation](docs/06_API_DOCUMENTATION.md)** - Endpoints completos

---

## 🤝 Contribución

### Workflow

1. Fork el repositorio
2. Crear branch: `git checkout -b feature/nueva-funcionalidad`
3. Commit: `git commit -m 'Add: nueva funcionalidad'`
4. Push: `git push origin feature/nueva-funcionalidad`
5. Crear Pull Request

### Estándares de Código

**Backend (Laravel):**
- PSR-12 coding standard
- PHPStan level 5
- Tests para nuevas features

**Frontend (Flutter):**
- Effective Dart guidelines
- Análisis estático sin warnings
- Tests unitarios y de widgets

---

## 📝 Roadmap

### ✅ Fase 1 - MVP (8 semanas)
- Backend API completo
- PWA Cliente funcional
- App Comercio Android
- App Repartidor Android
- Tracking GPS en tiempo real

### 🔄 Fase 2 - Mejoras (Semanas 9-12)
- App iOS (Flutter)
- Sistema de cupones y descuentos
- Programa de fidelización
- Chat en tiempo real
- Reportes avanzados

### 🔮 Fase 3 - Escalabilidad (Meses 4-6)
- Integración con pasarelas de pago
- Facturación electrónica
- Multi-idioma (inglés, portugués)
- API pública para integraciones
- Marketplace de comercios

---

## 📄 Licencia

Este proyecto es privado y propietario. Todos los derechos reservados.

---

## 👥 Equipo

- **Product Owner:** [Nombre]
- **Tech Lead:** [Nombre]
- **Backend Developer:** [Nombre]
- **Frontend Developer:** [Nombre]

---

## 📞 Soporte

- **Email:** soporte@izy.com
- **WhatsApp:** +58 412 123 4567
- **Documentación:** https://docs.izy.com

---

## 🙏 Agradecimientos

- Laravel Team por el excelente framework
- Flutter Team por la plataforma multi-target
- Comunidad de desarrolladores venezolanos

---

**Hecho con ❤️ en Venezuela 🇻🇪**
