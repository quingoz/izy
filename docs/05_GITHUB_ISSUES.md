# 🎯 GITHUB ISSUES - IZY

## ESTRUCTURA DE EPICS

Los issues están organizados en 4 Epics principales:

1. **Epic 1: API & Database** - Backend core y base de datos
2. **Epic 2: PWA Cliente** - Aplicación web para clientes
3. **Epic 3: App Comercio** - Aplicación Android para comercios
4. **Epic 4: App Repartidor** - Aplicación Android para repartidores

---

# EPIC 1: API & DATABASE

## Issue #1: Setup Inicial del Proyecto Backend

**Labels:** `backend`, `setup`, `priority:high`  
**Sprint:** Sprint 0  
**Estimación:** 1 día  

### Descripción
Configurar el entorno de desarrollo Laravel 11 con todas las dependencias necesarias para el proyecto IZY.

### User Story
Como desarrollador, necesito un entorno de desarrollo Laravel configurado correctamente para poder comenzar a desarrollar la API.

### Tareas Técnicas
- [ ] Instalar Laravel 11 con PHP 8.3
- [ ] Configurar archivo `.env` con credenciales de DB
- [ ] Instalar dependencias: Sanctum, Reverb
- [ ] Configurar Redis para cache y queues
- [ ] Instalar Laravel Telescope para debugging
- [ ] Configurar CORS para permitir requests desde Flutter
- [ ] Setup de logging personalizado
- [ ] Crear estructura de carpetas para organización

### Definición de Hecho (DoD)
- ✅ `php artisan serve` ejecuta sin errores
- ✅ Conexión a base de datos funcional
- ✅ Redis conectado y operativo
- ✅ Telescope accesible en `/telescope`
- ✅ `.env.example` actualizado con todas las variables

### Comandos de Verificación
```bash
php artisan serve
php artisan config:cache
php artisan migrate:status
redis-cli ping
```

---

## Issue #2: Crear Esquema de Base de Datos

**Labels:** `backend`, `database`, `priority:high`  
**Sprint:** Sprint 1  
**Estimación:** 2 días  

### Descripción
Implementar todas las migraciones necesarias para el esquema de base de datos multi-tenant de IZY.

### User Story
Como desarrollador backend, necesito un esquema de base de datos completo y normalizado para almacenar toda la información del sistema.

### Tareas Técnicas
- [ ] Migración `create_users_table`
  - Campos: id, name, email, phone, password, role, fcm_token
  - Índices: email, phone, role
- [ ] Migración `create_comercios_table`
  - Campos: id, slug, nombre, branding_json, lat, lng, horarios_json
  - Índices: slug (unique), location (lat, lng)
- [ ] Migración `create_categorias_table`
- [ ] Migración `create_productos_table`
  - Soporte para variantes JSON
  - Precios en USD y Bs
- [ ] Migración `create_repartidores_table`
  - Campos GPS: current_lat, current_lng
  - Status: disponible, ocupado, offline
- [ ] Migración `create_comercio_repartidor_table` (pivot)
- [ ] Migración `create_direcciones_table`
- [ ] Migración `create_pedidos_table`
  - Estados del pedido
  - Campos de pago (tipo_pago, vuelto_de, pago_movil_json)
- [ ] Migración `create_pedido_items_table`
- [ ] Migración `create_pedido_estados_table` (historial)
- [ ] Migración `create_repartidor_ubicaciones_table`
- [ ] Migración `create_notificaciones_table`
- [ ] Migración `create_configuraciones_table`

### Definición de Hecho (DoD)
- ✅ Todas las migraciones ejecutan sin errores
- ✅ Relaciones foreign keys correctamente definidas
- ✅ Índices creados para optimización
- ✅ Rollback funciona correctamente
- ✅ Documentación de esquema actualizada

### Comandos de Verificación
```bash
php artisan migrate:fresh
php artisan migrate:rollback
php artisan migrate:status
```

---

## Issue #3: Implementar Modelos Eloquent

**Labels:** `backend`, `models`, `priority:high`  
**Sprint:** Sprint 1  
**Estimación:** 2 días  

### Descripción
Crear todos los modelos Eloquent con sus relaciones, scopes y métodos auxiliares.

### User Story
Como desarrollador backend, necesito modelos Eloquent bien estructurados para interactuar con la base de datos de forma eficiente.

### Tareas Técnicas
- [ ] Modelo `User`
  - Relaciones: comercio, repartidor, pedidos, direcciones
  - Mutators para password hashing
  - Scopes: byRole, active
- [ ] Modelo `Comercio`
  - Relaciones: productos, pedidos, repartidores
  - Accessors para branding_json
  - Métodos: isOpen(), getDistanceTo($lat, $lng)
- [ ] Modelo `Producto`
  - Relaciones: comercio, categoria
  - Trait `BelongsToTenant`
  - Accessors para variantes_json
  - Scopes: active, destacados
- [ ] Modelo `Repartidor`
  - Relaciones: user, comercios, pedidos
  - Métodos: updateLocation(), isAvailable()
  - Scopes: disponibles, freelance
- [ ] Modelo `Pedido`
  - Relaciones: comercio, cliente, repartidor, items
  - Métodos: calcularTotal(), generarToken()
  - Observers para eventos
- [ ] Modelo `PedidoItem`
- [ ] Modelo `Direccion`
- [ ] Trait `BelongsToTenant`
  - Boot method para auto-asignar comercio_id
  - Global scope para filtrar por tenant
- [ ] Global Scope `TenantScope`

### Definición de Hecho (DoD)
- ✅ Todos los modelos creados con relaciones
- ✅ Trait BelongsToTenant funcionando
- ✅ Tests unitarios de modelos pasando
- ✅ Documentación de relaciones
- ✅ Factories creados para testing

### Comandos de Verificación
```bash
php artisan tinker
>>> User::factory()->create()
>>> Comercio::with('productos')->first()
>>> Producto::where('comercio_id', 1)->get()
```

---

## Issue #4: Sistema de Autenticación con Sanctum

**Labels:** `backend`, `auth`, `security`, `priority:high`  
**Sprint:** Sprint 1  
**Estimación:** 2 días  

### Descripción
Implementar sistema completo de autenticación usando Laravel Sanctum con soporte para múltiples roles.

### User Story
Como usuario de cualquier tipo (cliente, comercio, repartidor), necesito poder autenticarme de forma segura en el sistema.

### Tareas Técnicas
- [ ] Configurar Laravel Sanctum
- [ ] `AuthController` con métodos:
  - `login(Request $request)` - Login con email/password
  - `register(Request $request)` - Registro de usuarios
  - `logout(Request $request)` - Revocación de token
  - `refresh(Request $request)` - Refresh token
  - `me(Request $request)` - Info del usuario autenticado
- [ ] `PasswordResetController`
  - Envío de email con token
  - Validación y reset
- [ ] Form Requests:
  - `LoginRequest`
  - `RegisterRequest`
- [ ] Middleware `auth:sanctum`
- [ ] Middleware `role:cliente,comercio,repartidor`
- [ ] Rate limiting para login (5 intentos/minuto)
- [ ] Tests de autenticación

### Definición de Hecho (DoD)
- ✅ Login funcional retorna token
- ✅ Registro crea usuario y retorna token
- ✅ Logout revoca token correctamente
- ✅ Middleware protege rutas correctamente
- ✅ Rate limiting funciona
- ✅ Tests de auth pasando (>90% coverage)

### Endpoints
```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout
POST   /api/auth/refresh
GET    /api/auth/me
POST   /api/auth/password/email
POST   /api/auth/password/reset
```

---

## Issue #5: Implementar Multi-tenancy

**Labels:** `backend`, `multi-tenant`, `priority:critical`  
**Sprint:** Sprint 1  
**Estimación:** 2 días  

### Descripción
Implementar arquitectura multi-tenant con aislamiento de datos por comercio_id.

### User Story
Como comercio, necesito que mis datos estén completamente aislados de otros comercios en la plataforma.

### Tareas Técnicas
- [ ] Middleware `IdentifyTenant`
  - Detectar slug en URL o header
  - Cargar comercio y almacenar en contexto
  - Configurar tenant_id global
- [ ] Global Scope `TenantScope`
  - Aplicar WHERE comercio_id automáticamente
  - Excluir modelos que no son multi-tenant
- [ ] Trait `BelongsToTenant`
  - Auto-asignar comercio_id al crear
  - Aplicar global scope
- [ ] Políticas de autorización
  - `ProductoPolicy`
  - `PedidoPolicy`
  - `CategoriaPolicy`
- [ ] Tests de aislamiento:
  - Verificar que comercio A no puede ver datos de comercio B
  - Verificar auto-asignación de comercio_id
  - Verificar políticas de autorización

### Definición de Hecho (DoD)
- ✅ Middleware identifica tenant correctamente
- ✅ Global scope filtra queries automáticamente
- ✅ No es posible acceso cruzado entre comercios
- ✅ Tests de aislamiento pasando al 100%
- ✅ Documentación de multi-tenancy completa

### Comandos de Verificación
```bash
php artisan test --filter=TenantTest
php artisan test --filter=ProductoPolicyTest
```

---

## Issue #6: API de Comercios y Productos

**Labels:** `backend`, `api`, `priority:high`  
**Sprint:** Sprint 2  
**Estimación:** 2 días  

### Descripción
Desarrollar endpoints de API para gestión de comercios y productos.

### User Story
Como cliente, necesito poder ver información de comercios y sus productos para realizar pedidos.

### Tareas Técnicas
- [ ] `ComercioController`
  - `show($slug)` - Info del comercio por slug
  - `cercanos(Request $request)` - Comercios cercanos por GPS
  - `branding($slug)` - Configuración de branding
- [ ] `ProductoController`
  - `index($comercioSlug)` - Listar productos del comercio
  - `show($id)` - Detalle de producto
  - `search(Request $request)` - Búsqueda de productos
- [ ] `CategoriaController`
  - `index($comercioSlug)` - Categorías del comercio
- [ ] Resources para transformación:
  - `ComercioResource`
  - `ProductoResource`
  - `CategoriaResource`
- [ ] Cache de productos por comercio (1 hora)
- [ ] Cálculo de distancia con Haversine formula
- [ ] Filtros: categoría, precio, disponibilidad
- [ ] Paginación de resultados

### Definición de Hecho (DoD)
- ✅ Todos los endpoints funcionan correctamente
- ✅ Responses en formato JSON consistente
- ✅ Cache implementado y funcionando
- ✅ Filtros y búsqueda operativos
- ✅ Tests de API pasando
- ✅ Documentación de endpoints (Postman/OpenAPI)

### Endpoints
```
GET    /api/comercios/{slug}
GET    /api/comercios/{slug}/branding
GET    /api/comercios/cercanos?lat={lat}&lng={lng}&radio={km}
GET    /api/comercios/{slug}/productos
GET    /api/comercios/{slug}/categorias
GET    /api/productos/{id}
GET    /api/productos/search?q={query}
```

---

## Issue #7: API de Pedidos (Cliente)

**Labels:** `backend`, `api`, `pedidos`, `priority:high`  
**Sprint:** Sprint 2  
**Estimación:** 3 días  

### Descripción
Implementar API completa para gestión de pedidos desde el lado del cliente.

### User Story
Como cliente, necesito poder crear pedidos, ver su estado y hacer seguimiento en tiempo real.

### Tareas Técnicas
- [ ] `PedidoController`
  - `store(Request $request)` - Crear pedido
  - `show($id)` - Detalle de pedido
  - `index()` - Mis pedidos (historial)
  - `tracking($token)` - Tracking público por token
  - `cancel($id)` - Cancelar pedido
- [ ] `StorePedidoRequest` - Validación completa:
  - Items del pedido
  - Dirección de entrega
  - Método de pago
  - Validación de stock
  - Validación de horario del comercio
- [ ] Lógica de negocio:
  - Generar número de pedido único (IZY-YYYYMMDD-####)
  - Generar token de seguimiento
  - Calcular totales (subtotal + delivery fee)
  - Validar stock de productos
  - Crear snapshot de productos en pedido_items
  - Crear registro en pedido_estados
- [ ] Notificaciones:
  - Push al comercio (nuevo pedido)
  - Email al cliente (confirmación)
- [ ] Job `ProcessPedido` para tareas asíncronas
- [ ] Tests de creación de pedidos

### Definición de Hecho (DoD)
- ✅ Pedido se crea correctamente con todos los datos
- ✅ Validaciones funcionan (stock, horario, etc.)
- ✅ Número de pedido y token generados
- ✅ Notificaciones enviadas
- ✅ Tests pasando con diferentes escenarios
- ✅ Manejo de errores robusto

### Endpoints
```
POST   /api/pedidos
GET    /api/pedidos/{id}
GET    /api/mis-pedidos
GET    /api/pedidos/{token}/tracking
PUT    /api/pedidos/{id}/cancel
```

---

## Issue #8: Sistema de WebSockets con Laravel Reverb

**Labels:** `backend`, `real-time`, `websockets`, `priority:high`  
**Sprint:** Sprint 3  
**Estimación:** 2 días  

### Descripción
Configurar Laravel Reverb para comunicación en tiempo real (tracking GPS, estados de pedido).

### User Story
Como cliente, necesito ver actualizaciones en tiempo real del estado de mi pedido y la ubicación del repartidor.

### Tareas Técnicas
- [ ] Configurar Laravel Reverb
  - Archivo de configuración
  - Variables de entorno
  - Iniciar servidor Reverb
- [ ] Eventos Broadcast:
  - `PedidoEstadoActualizado` - Cambio de estado
  - `RepartidorUbicacionActualizada` - GPS update
  - `PedidoAsignado` - Repartidor asignado
  - `PedidoCancelado` - Pedido cancelado
- [ ] Canales:
  - `pedido.{id}` - Canal privado por pedido
  - `comercio.{id}` - Canal del comercio
  - `repartidor.{id}` - Canal del repartidor
- [ ] Autorización de canales privados
- [ ] Broadcasting en eventos del modelo:
  - Observer `PedidoObserver`
  - Dispatch de eventos en cambios de estado
- [ ] Tests de WebSockets

### Definición de Hecho (DoD)
- ✅ Servidor Reverb ejecutando sin errores
- ✅ Eventos se broadcaste correctamente
- ✅ Canales privados autorizados
- ✅ Cliente puede suscribirse y recibir eventos
- ✅ Tests de broadcasting pasando

### Comandos de Verificación
```bash
php artisan reverb:start
php artisan tinker
>>> broadcast(new PedidoEstadoActualizado($pedido))
```

---

## Issue #9: Sistema de Notificaciones Push (FCM)

**Labels:** `backend`, `notifications`, `firebase`, `priority:medium`  
**Sprint:** Sprint 3  
**Estimación:** 2 días  

### Descripción
Implementar sistema de notificaciones push usando Firebase Cloud Messaging.

### User Story
Como usuario, necesito recibir notificaciones push cuando hay eventos importantes (nuevo pedido, cambio de estado, etc.).

### Tareas Técnicas
- [ ] Configurar Firebase Cloud Messaging
  - Crear proyecto en Firebase Console
  - Descargar credenciales JSON
  - Configurar en Laravel
- [ ] Servicio `FCMService`
  - `sendToUser($userId, $title, $body, $data)`
  - `sendToTopic($topic, $title, $body, $data)`
  - `sendMulticast($tokens, $title, $body, $data)`
- [ ] Jobs para envío asíncrono:
  - `SendPushNotification`
  - Queue: 'notifications'
- [ ] Notificaciones por evento:
  - Nuevo pedido → Comercio
  - Pedido confirmado → Cliente
  - Pedido asignado → Repartidor
  - Pedido en camino → Cliente
  - Pedido entregado → Cliente y Comercio
- [ ] Almacenar FCM tokens en tabla `users`
- [ ] Endpoint para actualizar FCM token
- [ ] Tests de notificaciones

### Definición de Hecho (DoD)
- ✅ FCM configurado correctamente
- ✅ Notificaciones se envían exitosamente
- ✅ Jobs en queue procesándose
- ✅ Tokens almacenados y actualizados
- ✅ Deep linking funciona en notificaciones
- ✅ Tests pasando

### Endpoints
```
POST   /api/user/fcm-token
```

---

## Issue #10: API de Gestión de Pedidos (Comercio)

**Labels:** `backend`, `api`, `comercio`, `priority:high`  
**Sprint:** Sprint 3  
**Estimación:** 2 días  

### Descripción
Desarrollar endpoints para que comercios gestionen sus pedidos (cambiar estados, asignar repartidores).

### User Story
Como comercio, necesito poder gestionar los pedidos que recibo, cambiar sus estados y asignar repartidores.

### Tareas Técnicas
- [ ] `Comercio\PedidoController`
  - `index()` - Pedidos del comercio (filtros por estado)
  - `show($id)` - Detalle de pedido
  - `updateEstado($id, Request $request)` - Cambiar estado
  - `asignarRepartidor($id, Request $request)` - Asignar repartidor
  - `estadisticas()` - Métricas del día/semana/mes
- [ ] Validación de transiciones de estado:
  - Pendiente → Confirmado → Preparando → Listo
  - No permitir saltos de estados
- [ ] Lógica de asignación de repartidores:
  - Manual: seleccionar repartidor exclusivo
  - Automática: broadcast a freelancers cercanos
- [ ] Broadcast de cambios de estado
- [ ] Registro en `pedido_estados`
- [ ] Notificaciones a cliente y repartidor
- [ ] Tests de gestión de pedidos

### Definición de Hecho (DoD)
- ✅ Comercio puede ver sus pedidos
- ✅ Cambios de estado funcionan correctamente
- ✅ Validaciones de transición implementadas
- ✅ Asignación de repartidores operativa
- ✅ Notificaciones enviadas
- ✅ Tests pasando

### Endpoints
```
GET    /api/comercio/pedidos
GET    /api/comercio/pedidos/{id}
PUT    /api/comercio/pedidos/{id}/estado
POST   /api/comercio/pedidos/{id}/asignar-repartidor
GET    /api/comercio/estadisticas
```

---

## Issue #11: API de Repartidores y GPS Tracking

**Labels:** `backend`, `api`, `repartidor`, `gps`, `priority:high`  
**Sprint:** Sprint 4  
**Estimación:** 3 días  

### Descripción
Implementar API para repartidores: gestión de pedidos, actualización de ubicación GPS, y sistema de asignación.

### User Story
Como repartidor, necesito recibir pedidos disponibles, actualizar mi ubicación y gestionar mis entregas.

### Tareas Técnicas
- [ ] `Repartidor\PedidoController`
  - `disponibles()` - Pedidos disponibles (freelance)
  - `misPedidos()` - Pedidos asignados
  - `aceptar($id)` - Aceptar pedido
  - `rechazar($id)` - Rechazar pedido
  - `confirmarRecogida($id)` - Confirmar recogida en comercio
  - `confirmarEntrega($id)` - Confirmar entrega al cliente
- [ ] `Repartidor\UbicacionController`
  - `update(Request $request)` - Actualizar ubicación GPS
  - Almacenar en `repartidor_ubicaciones`
  - Broadcast a canal del pedido activo
- [ ] `Repartidor\PerfilController`
  - `show()` - Perfil del repartidor
  - `updateEstado(Request $request)` - Cambiar disponibilidad
  - `estadisticas()` - Ganancias y métricas
- [ ] Lógica de asignación:
  - Calcular repartidores en radio de 3km (Haversine)
  - Filtrar por status 'disponible'
  - Broadcast a repartidores elegibles
  - Timeout de 5 minutos para aceptación
- [ ] Job `AsignarRepartidorAutomatico`
- [ ] Tests de asignación y GPS

### Definición de Hecho (DoD)
- ✅ Repartidor puede ver pedidos disponibles
- ✅ Aceptar/rechazar funciona correctamente
- ✅ Ubicación GPS se actualiza y broadcaste
- ✅ Sistema de asignación operativo
- ✅ Timeout y reasignación funcionan
- ✅ Tests pasando

### Endpoints
```
GET    /api/repartidor/pedidos/disponibles
GET    /api/repartidor/pedidos/mis-pedidos
POST   /api/repartidor/pedidos/{id}/aceptar
POST   /api/repartidor/pedidos/{id}/rechazar
POST   /api/repartidor/pedidos/{id}/confirmar-recogida
POST   /api/repartidor/pedidos/{id}/confirmar-entrega
POST   /api/repartidor/ubicacion
PUT    /api/repartidor/estado
GET    /api/repartidor/estadisticas
```

---

# EPIC 2: PWA CLIENTE

## Issue #12: Setup Proyecto Flutter Web

**Labels:** `frontend`, `flutter`, `pwa`, `setup`, `priority:high`  
**Sprint:** Sprint 2  
**Estimación:** 1 día  

### Descripción
Configurar proyecto Flutter para PWA con estructura Clean Architecture y Riverpod.

### User Story
Como desarrollador frontend, necesito un proyecto Flutter Web bien estructurado para desarrollar la PWA del cliente.

### Tareas Técnicas
- [ ] Crear proyecto Flutter
- [ ] Configurar `pubspec.yaml` con dependencias:
  - riverpod, flutter_riverpod
  - dio, retrofit (HTTP)
  - go_router (navegación)
  - google_maps_flutter_web
  - socket_io_client (WebSockets)
  - hive, hive_flutter (storage local)
  - freezed, json_serializable (modelos)
- [ ] Estructura de carpetas Clean Architecture:
  - `lib/core/` - Config, network, utils
  - `lib/features/` - Features por módulo
  - `lib/shared/` - Widgets compartidos
- [ ] Configurar `web/manifest.json` para PWA
- [ ] Configurar `web/index.html`
- [ ] Setup de temas y constantes
- [ ] Configurar análisis estático (analysis_options.yaml)

### Definición de Hecho (DoD)
- ✅ Proyecto ejecuta en Chrome sin errores
- ✅ Estructura de carpetas creada
- ✅ Dependencias instaladas
- ✅ PWA manifest configurado
- ✅ Hot reload funciona correctamente

### Comandos de Verificación
```bash
flutter create izy_cliente
flutter pub get
flutter run -d chrome
flutter build web --release
```

---

## Issue #13: Implementar Cliente HTTP y State Management

**Labels:** `frontend`, `flutter`, `architecture`, `priority:high`  
**Sprint:** Sprint 2  
**Estimación:** 1 día  

### Descripción
Configurar cliente HTTP con Dio y sistema de state management con Riverpod.

### User Story
Como desarrollador, necesito un cliente HTTP configurado y un sistema de estado reactivo para comunicarme con la API.

### Tareas Técnicas
- [ ] `DioClient` con configuración:
  - Base URL desde environment
  - Timeout de 30 segundos
  - Headers por defecto
- [ ] `AuthInterceptor` para inyectar token
- [ ] `LoggingInterceptor` para debugging
- [ ] `ErrorInterceptor` para manejo de errores
- [ ] Providers de Riverpod:
  - `dioClientProvider`
  - `authStateProvider`
  - `comercioProvider`
- [ ] Modelos con Freezed:
  - `User`
  - `Comercio`
  - `Producto`
  - `Pedido`
- [ ] Repositories:
  - `AuthRepository`
  - `ComercioRepository`
  - `ProductoRepository`
  - `PedidoRepository`
- [ ] Exception handling personalizado

### Definición de Hecho (DoD)
- ✅ Cliente HTTP configurado
- ✅ Interceptores funcionando
- ✅ Providers de Riverpod creados
- ✅ Modelos generados con Freezed
- ✅ Repositories implementados
- ✅ Tests unitarios de repositories

---

## Issue #14: Sistema de Branding Dinámico

**Labels:** `frontend`, `flutter`, `branding`, `priority:high`  
**Sprint:** Sprint 2  
**Estimación:** 2 días  

### Descripción
Implementar sistema de carga dinámica de branding (colores, logo, tema) según el comercio.

### User Story
Como cliente, quiero ver la aplicación con los colores y logo del comercio que estoy visitando.

### Tareas Técnicas
- [ ] Detectar slug del comercio desde URL
  - Parsear `domain.com/{slug}`
  - Validar slug existe
- [ ] `BrandingProvider` (Riverpod):
  - Cargar branding desde API
  - Parsear JSON de colores
  - Cachear en local storage
- [ ] `DynamicTheme` widget:
  - Aplicar colores dinámicamente
  - Cargar logo desde URL
  - Cambiar fuentes si es necesario
- [ ] Pantalla de carga (splash):
  - Mostrar mientras carga branding
  - Animación de logo
- [ ] Manejo de errores:
  - Comercio no encontrado
  - Comercio inactivo
  - Error de red
- [ ] Tests de branding

### Definición de Hecho (DoD)
- ✅ Slug se detecta correctamente de URL
- ✅ Branding se carga desde API
- ✅ Colores se aplican dinámicamente
- ✅ Logo se muestra correctamente
- ✅ Cache funciona (no recarga en cada visita)
- ✅ Errores manejados apropiadamente

---

## Issue #15: Catálogo de Productos

**Labels:** `frontend`, `flutter`, `catalogo`, `priority:high`  
**Sprint:** Sprint 2  
**Estimación:** 2 días  

### Descripción
Desarrollar pantalla de catálogo de productos con categorías, búsqueda y filtros.

### User Story
Como cliente, quiero navegar por el catálogo de productos del comercio, buscar y filtrar para encontrar lo que necesito.

### Tareas Técnicas
- [ ] `CatalogoScreen`:
  - AppBar con logo del comercio
  - Barra de búsqueda
  - Tabs de categorías
  - Grid/List de productos
- [ ] `ProductoCard` widget:
  - Imagen del producto
  - Nombre y descripción
  - Precio en USD y Bs
  - Badge de "Agotado" si stock = 0
  - Botón "Agregar"
- [ ] `ProductoDetalleScreen`:
  - Imagen grande
  - Descripción completa
  - Selector de variantes (si tiene)
  - Selector de cantidad
  - Botón "Agregar al carrito"
- [ ] Búsqueda en tiempo real
- [ ] Filtros:
  - Por categoría
  - Por rango de precio
  - Solo disponibles
- [ ] Paginación o scroll infinito
- [ ] Estados de carga y error

### Definición de Hecho (DoD)
- ✅ Catálogo muestra productos correctamente
- ✅ Búsqueda funciona en tiempo real
- ✅ Filtros aplicables
- ✅ Detalle de producto completo
- ✅ Variantes seleccionables
- ✅ UI responsive y fluida

---

## Issue #16: Carrito de Compras

**Labels:** `frontend`, `flutter`, `carrito`, `priority:high`  
**Sprint:** Sprint 2  
**Estimación:** 2 días  

### Descripción
Implementar carrito de compras con gestión de items, cantidades y persistencia local.

### User Story
Como cliente, quiero agregar productos a un carrito, modificar cantidades y ver el total antes de hacer el pedido.

### Tareas Técnicas
- [ ] `CarritoProvider` (Riverpod):
  - State: List<CarritoItem>
  - Métodos: agregar, quitar, actualizar cantidad, limpiar
  - Cálculo de subtotal
- [ ] Modelo `CarritoItem`:
  - Producto
  - Cantidad
  - Variantes seleccionadas
  - Subtotal
- [ ] `CarritoScreen`:
  - Lista de items
  - Modificar cantidad (+/-)
  - Eliminar item
  - Resumen de totales
  - Botón "Proceder al checkout"
- [ ] `CarritoFloatingButton`:
  - Badge con cantidad de items
  - Mostrar en todas las pantallas
- [ ] Persistencia en Hive:
  - Guardar carrito al agregar/modificar
  - Restaurar al abrir app
  - Limpiar al completar pedido
- [ ] Validaciones:
  - Stock disponible
  - Cantidad mínima/máxima
  - Variantes requeridas

### Definición de Hecho (DoD)
- ✅ Items se agregan al carrito
- ✅ Cantidades modificables
- ✅ Cálculos correctos
- ✅ Persistencia funciona
- ✅ Validaciones implementadas
- ✅ UI intuitiva

---

## Issue #17: Checkout y Métodos de Pago

**Labels:** `frontend`, `flutter`, `checkout`, `priority:high`  
**Sprint:** Sprint 2  
**Estimación:** 2 días  

### Descripción
Desarrollar flujo completo de checkout con selección de dirección y métodos de pago.

### User Story
Como cliente, quiero completar mi pedido seleccionando dirección de entrega y método de pago.

### Tareas Técnicas
- [ ] `CheckoutScreen` con steps:
  1. Dirección de entrega
  2. Método de pago
  3. Resumen y confirmación
- [ ] Selección de dirección:
  - Listar direcciones guardadas
  - Agregar nueva dirección
  - Integración con Google Maps para geocoding
- [ ] Métodos de pago:
  - **Efectivo:**
    - Input "Pago con" (para calcular vuelto)
    - Mostrar vuelto calculado
    - Sugerencias de billetes
  - **Pago Móvil:**
    - Formulario: Banco, Teléfono, Referencia
    - Validación de referencia
    - Upload de comprobante (opcional)
- [ ] Resumen final:
  - Items del pedido
  - Subtotal
  - Delivery fee
  - Total
  - Dirección
  - Método de pago
- [ ] Botón "Confirmar Pedido"
- [ ] Loading state durante creación
- [ ] Redirección a tracking

### Definición de Hecho (DoD)
- ✅ Flujo completo de checkout funcional
- ✅ Dirección seleccionable/agregable
- ✅ Métodos de pago implementados
- ✅ Cálculo de vuelto correcto
- ✅ Validaciones de formularios
- ✅ Pedido se crea exitosamente

---

## Issue #18: Tracking en Tiempo Real

**Labels:** `frontend`, `flutter`, `tracking`, `websockets`, `priority:high`  
**Sprint:** Sprint 3  
**Estimación:** 2 días  

### Descripción
Implementar pantalla de tracking con mapa, ubicación del repartidor en tiempo real y progreso del pedido.

### User Story
Como cliente, quiero ver en tiempo real dónde está mi pedido y el repartidor que lo está entregando.

### Tareas Técnicas
- [ ] `TrackingScreen`:
  - Mapa de Google Maps
  - Marcador del comercio
  - Marcador del cliente (dirección de entrega)
  - Marcador del repartidor (actualización real-time)
  - Polyline de ruta
- [ ] WebSocket client:
  - Conectar a canal `pedido.{id}`
  - Suscribirse a eventos de ubicación
  - Actualizar marcador del repartidor
- [ ] Barra de progreso de estados:
  - Pendiente → Confirmado → Preparando → Listo → En Camino → Entregado
  - Highlight del estado actual
  - Timestamps de cada estado
- [ ] Card de información:
  - Número de pedido
  - Nombre del repartidor (cuando se asigna)
  - Tiempo estimado de llegada
  - Teléfono del repartidor (botón llamar)
- [ ] Notificaciones en app:
  - Toast al cambiar estado
  - Sonido/vibración
- [ ] Botón "Cancelar pedido" (solo si está pendiente)

### Definición de Hecho (DoD)
- ✅ Mapa se muestra correctamente
- ✅ Marcadores posicionados
- ✅ Ubicación del repartidor se actualiza en tiempo real
- ✅ Progreso de estados funcional
- ✅ WebSocket conecta y recibe eventos
- ✅ UI responsive y fluida

---

# EPIC 3: APP COMERCIO

## Issue #19: Setup App Android Comercio (Flutter Flavor)

**Labels:** `frontend`, `flutter`, `android`, `comercio`, `setup`, `priority:high`  
**Sprint:** Sprint 3  
**Estimación:** 1 día  

### Descripción
Configurar flavor "comercio" en Flutter para generar app Android independiente.

### User Story
Como desarrollador, necesito un build variant separado para la app de comercios.

### Tareas Técnicas
- [ ] Configurar `android/app/build.gradle`:
  - Flavor "comercio"
  - applicationId: com.izy.comercio
  - App name: "IZY Comercio"
  - Icono personalizado
- [ ] Crear `lib/main_comercio.dart`
- [ ] Configurar `AppConfig` para comercio:
  - Tipo de app
  - Colores del tema (diferente a cliente)
  - Features habilitadas
- [ ] Configurar Firebase para flavor comercio
- [ ] Permisos en AndroidManifest:
  - Internet
  - Notificaciones
- [ ] Splash screen personalizado
- [ ] Tests de build

### Definición de Hecho (DoD)
- ✅ Build de flavor comercio exitoso
- ✅ App se instala con nombre correcto
- ✅ Icono personalizado visible
- ✅ Firebase configurado
- ✅ No hay conflictos con otros flavors

### Comandos de Verificación
```bash
flutter run --flavor comercio
flutter build apk --flavor comercio --debug
flutter build apk --flavor comercio --release
```

---

## Issue #20: Dashboard de Comercio

**Labels:** `frontend`, `flutter`, `comercio`, `dashboard`, `priority:high`  
**Sprint:** Sprint 3  
**Estimación:** 2 días  

### Descripción
Desarrollar dashboard principal para comercios con pedidos activos y métricas en tiempo real.

### User Story
Como comercio, quiero ver todos mis pedidos activos y métricas del día en un dashboard centralizado.

### Tareas Técnicas
- [ ] `DashboardScreen`:
  - AppBar con logo y nombre del comercio
  - Drawer con navegación
  - Tabs: Pedidos Activos, Historial, Estadísticas
- [ ] `PedidosActivosTab`:
  - Lista de pedidos en estados activos
  - Filtros por estado
  - Ordenar por fecha
  - Pull to refresh
  - WebSocket para actualizaciones real-time
- [ ] `PedidoCard` widget:
  - Número de pedido
  - Estado actual
  - Items resumidos
  - Total
  - Tiempo transcurrido
  - Botón de acción según estado
- [ ] `EstadisticasTab`:
  - Cards con métricas:
    - Ventas del día (USD/Bs)
    - Total de pedidos
    - Pedidos completados
    - Ticket promedio
  - Gráfico de ventas (últimos 7 días)
  - Productos más vendidos
- [ ] Notificaciones push:
  - Alerta sonora al recibir pedido
  - Badge en icono de app
  - Vibración
- [ ] Refresh automático cada 30 segundos

### Definición de Hecho (DoD)
- ✅ Dashboard muestra pedidos activos
- ✅ Métricas calculadas correctamente
- ✅ Actualizaciones en tiempo real funcionan
- ✅ Notificaciones push operativas
- ✅ UI responsive y fluida

---

## Issue #21: Kitchen Flow (Gestión de Estados)

**Labels:** `frontend`, `flutter`, `comercio`, `kitchen`, `priority:high`  
**Sprint:** Sprint 3  
**Estimación:** 2 días  

### Descripción
Implementar flujo de cocina para gestión de estados de pedidos.

### User Story
Como comercio, quiero cambiar los estados de los pedidos de forma rápida y eficiente desde la cocina.

### User Story
Como comercio, quiero cambiar los estados de los pedidos de forma rápida y eficiente desde la cocina.

### Tareas Técnicas
- [ ] `PedidoDetalleScreen`:
  - Información completa del pedido
  - Lista de items con cantidades
  - Variantes y notas especiales
  - Datos del cliente
  - Dirección de entrega
  - Método de pago
- [ ] Botones de cambio de estado:
  - "Confirmar" (Pendiente → Confirmado)
  - "Iniciar Preparación" (Confirmado → Preparando)
  - "Marcar como Listo" (Preparando → Listo)
  - "Cancelar Pedido" (con razón)
- [ ] Temporizador de preparación:
  - Iniciar al cambiar a "Preparando"
  - Mostrar tiempo transcurrido
  - Alerta si excede tiempo estimado
- [ ] Confirmación de cambios:
  - Dialog de confirmación
  - Loading state
  - Feedback visual (snackbar)
- [ ] Broadcast de cambios:
  - Actualizar en tiempo real
  - Notificar al cliente
- [ ] Validación de transiciones:
  - No permitir saltos de estados
  - Mostrar error si transición inválida

### Definición de Hecho (DoD)
- ✅ Estados cambian correctamente
- ✅ Validaciones de transición funcionan
- ✅ Temporizador operativo
- ✅ Notificaciones enviadas
- ✅ UI intuitiva y rápida
- ✅ Feedback visual claro

---

## Issue #22: Gestión de Productos (CRUD)

**Labels:** `frontend`, `flutter`, `comercio`, `productos`, `priority:medium`  
**Sprint:** Sprint 3  
**Estimación:** 2 días  

### Descripción
Implementar CRUD completo de productos con soporte para variantes e imágenes.

### User Story
Como comercio, quiero gestionar mi catálogo de productos: crear, editar, eliminar y controlar stock.

### Tareas Técnicas
- [ ] `ProductosScreen`:
  - Lista de productos
  - Búsqueda
  - Filtro por categoría
  - Botón FAB "Agregar Producto"
- [ ] `ProductoFormScreen`:
  - Campos: nombre, descripción, categoría
  - Precios: USD y Bs
  - Stock: cantidad, ilimitado
  - Upload de imagen
  - Gestión de variantes:
    - Agregar grupo de variantes
    - Opciones con precios adicionales
    - Marcar como requerido
  - Toggle "Activo/Inactivo"
- [ ] Upload de imágenes:
  - Seleccionar de galería
  - Comprimir imagen
  - Upload a servidor
  - Preview
- [ ] Validaciones:
  - Campos requeridos
  - Precios > 0
  - Stock >= 0
- [ ] Acciones:
  - Crear producto
  - Editar producto
  - Eliminar producto (confirmación)
  - Activar/desactivar
- [ ] Tests de formulario

### Definición de Hecho (DoD)
- ✅ CRUD completo funcional
- ✅ Upload de imágenes operativo
- ✅ Variantes gestionables
- ✅ Validaciones implementadas
- ✅ UI intuitiva
- ✅ Tests pasando

---

## Issue #23: Asignación de Repartidores

**Labels:** `frontend`, `flutter`, `comercio`, `logistica`, `priority:high`  
**Sprint:** Sprint 4  
**Estimación:** 2 días  

### Descripción
Implementar sistema de asignación de repartidores (manual y automática).

### User Story
Como comercio, quiero asignar repartidores a los pedidos listos para entrega.

### Tareas Técnicas
- [ ] `AsignarRepartidorScreen`:
  - Información del pedido
  - Tabs: Exclusivos, Freelancers
- [ ] Tab "Repartidores Exclusivos":
  - Lista de repartidores vinculados
  - Estado actual (disponible/ocupado)
  - Rating y entregas completadas
  - Botón "Asignar"
- [ ] Tab "Freelancers":
  - Botón "Solicitar Repartidor Freelance"
  - Mostrar radio de búsqueda (3km)
  - Lista de repartidores que aceptaron
  - Distancia al comercio
  - Tiempo estimado de llegada
- [ ] Mapa de repartidores:
  - Mostrar ubicación de repartidores disponibles
  - Marcador del comercio
  - Radio de 3km
- [ ] Estados de asignación:
  - Buscando repartidores...
  - Esperando aceptación...
  - Repartidor asignado
  - Sin repartidores disponibles
- [ ] Notificaciones:
  - Repartidor aceptó pedido
  - Timeout sin aceptación
- [ ] Reasignación:
  - Si repartidor rechaza
  - Si timeout

### Definición de Hecho (DoD)
- ✅ Asignación manual funciona
- ✅ Solicitud a freelancers operativa
- ✅ Mapa muestra repartidores
- ✅ Estados de asignación claros
- ✅ Notificaciones funcionan
- ✅ Reasignación automática

---

# EPIC 4: APP REPARTIDOR

## Issue #24: Setup App Android Repartidor (Flutter Flavor)

**Labels:** `frontend`, `flutter`, `android`, `repartidor`, `setup`, `priority:high`  
**Sprint:** Sprint 4  
**Estimación:** 1 día  

### Descripción
Configurar flavor "repartidor" en Flutter para generar app Android independiente.

### User Story
Como desarrollador, necesito un build variant separado para la app de repartidores.

### Tareas Técnicas
- [ ] Configurar `android/app/build.gradle`:
  - Flavor "repartidor"
  - applicationId: com.izy.repartidor
  - App name: "IZY Repartidor"
  - Icono personalizado
- [ ] Crear `lib/main_repartidor.dart`
- [ ] Configurar `AppConfig` para repartidor
- [ ] Permisos en AndroidManifest:
  - Location (fine y coarse)
  - Location en background
  - Internet
  - Notificaciones
  - Vibración
- [ ] Configurar Firebase para flavor repartidor
- [ ] Splash screen personalizado
- [ ] Tests de build

### Definición de Hecho (DoD)
- ✅ Build de flavor repartidor exitoso
- ✅ Permisos configurados
- ✅ Firebase operativo
- ✅ App se instala correctamente

### Comandos de Verificación
```bash
flutter run --flavor repartidor
flutter build apk --flavor repartidor --release
```

---

## Issue #25: GPS Tracking en Segundo Plano

**Labels:** `frontend`, `flutter`, `repartidor`, `gps`, `priority:critical`  
**Sprint:** Sprint 4  
**Estimación:** 2 días  

### Descripción
Implementar servicio de GPS en segundo plano para tracking del repartidor.

### User Story
Como repartidor, necesito que mi ubicación se envíe automáticamente mientras estoy en una entrega, incluso si la app está en segundo plano.

### Tareas Técnicas
- [ ] Configurar plugin `geolocator`:
  - Permisos de ubicación
  - Configuración de precisión
  - Intervalo de actualización (10 segundos)
- [ ] Servicio en segundo plano:
  - Iniciar al aceptar pedido
  - Detener al completar entrega
  - Persistir incluso si app se cierra
- [ ] `LocationService`:
  - `startTracking(pedidoId)`
  - `stopTracking()`
  - `getCurrentLocation()`
  - Enviar ubicación a API cada 10s
- [ ] Optimización de batería:
  - Ajustar precisión según velocidad
  - Pausar si repartidor está quieto
  - Usar geofencing si disponible
- [ ] Manejo de errores:
  - Permisos denegados
  - GPS desactivado
  - Sin conexión a internet (queue)
- [ ] Notificación persistente:
  - Mostrar mientras tracking activo
  - Indicador de entrega en curso
- [ ] Tests de GPS

### Definición de Hecho (DoD)
- ✅ GPS funciona en segundo plano
- ✅ Ubicación se envía cada 10s
- ✅ Servicio persiste al cerrar app
- ✅ Optimización de batería implementada
- ✅ Permisos manejados correctamente
- ✅ Tests pasando

---

## Issue #26: Gestión de Pedidos (Repartidor)

**Labels:** `frontend`, `flutter`, `repartidor`, `pedidos`, `priority:high`  
**Sprint:** Sprint 4  
**Estimación:** 2 días  

### Descripción
Implementar pantallas para que repartidores vean, acepten y gestionen pedidos.

### User Story
Como repartidor, quiero ver pedidos disponibles, aceptarlos y gestionar mis entregas activas.

### Tareas Técnicas
- [ ] `HomeRepartidorScreen`:
  - Toggle de disponibilidad (Online/Offline)
  - Tabs: Disponibles, Mis Pedidos, Historial
  - Métricas del día (entregas, ganancias)
- [ ] Tab "Pedidos Disponibles":
  - Lista de pedidos cercanos (freelance)
  - Card con información:
    - Comercio
    - Dirección de entrega
    - Distancia total
    - Monto a cobrar
    - Método de pago
    - Tiempo estimado
  - Botones: Aceptar, Rechazar
  - Countdown de timeout (5 min)
- [ ] Tab "Mis Pedidos":
  - Pedidos asignados/aceptados
  - Estado actual
  - Botones de acción según estado
- [ ] `PedidoDetalleRepartidorScreen`:
  - Info completa del pedido
  - Mapa con ruta
  - Botones:
    - "Navegar al Comercio"
    - "Confirmar Recogida"
    - "Navegar al Cliente"
    - "Confirmar Entrega"
- [ ] Notificaciones push:
  - Nuevo pedido disponible
  - Pedido asignado
  - Vibración y sonido
- [ ] WebSocket para actualizaciones real-time

### Definición de Hecho (DoD)
- ✅ Repartidor ve pedidos disponibles
- ✅ Aceptar/rechazar funciona
- ✅ Mis pedidos se muestran correctamente
- ✅ Notificaciones operativas
- ✅ UI intuitiva y rápida

---

## Issue #27: Navegación y Confirmación de Entregas

**Labels:** `frontend`, `flutter`, `repartidor`, `navegacion`, `priority:high`  
**Sprint:** Sprint 4  
**Estimación:** 2 días  

### Descripción
Implementar navegación a puntos de recogida/entrega y confirmación de entregas.

### User Story
Como repartidor, quiero navegar fácilmente al comercio y al cliente, y confirmar las entregas.

### Tareas Técnicas
- [ ] Deep linking a apps de navegación:
  - Google Maps
  - Waze
  - Selector de app preferida
- [ ] Botón "Navegar al Comercio":
  - Abrir app de navegación
  - Pasar coordenadas del comercio
  - Mantener tracking activo
- [ ] Botón "Confirmar Recogida":
  - Cambiar estado a "En Camino"
  - Notificar al cliente
  - Iniciar navegación al cliente
- [ ] Botón "Navegar al Cliente":
  - Abrir app de navegación
  - Pasar coordenadas del cliente
- [ ] Botón "Confirmar Entrega":
  - Si es efectivo: mostrar monto a cobrar
  - Confirmación de cobro
  - Captura de firma (opcional)
  - Foto de comprobante (opcional)
  - Cambiar estado a "Entregado"
  - Detener tracking GPS
- [ ] `ConfirmarEntregaDialog`:
  - Monto cobrado (si es efectivo)
  - Checkbox "Cobro confirmado"
  - Botón "Completar Entrega"
- [ ] Validaciones:
  - No permitir confirmar entrega sin confirmar recogida
  - Validar cobro si es efectivo
- [ ] Feedback visual:
  - Animación de éxito
  - Actualizar ganancias del día

### Definición de Hecho (DoD)
- ✅ Navegación a apps externas funciona
- ✅ Confirmaciones cambian estados correctamente
- ✅ Tracking GPS se detiene al completar
- ✅ Validaciones implementadas
- ✅ UI clara y directa
- ✅ Ganancias se actualizan

---

## Issue #28: Modo Freelance y Sistema de Ofertas

**Labels:** `frontend`, `flutter`, `repartidor`, `freelance`, `priority:medium`  
**Sprint:** Sprint 4  
**Estimación:** 2 días  

### Descripción
Implementar modo freelance con recepción de ofertas de pedidos cercanos.

### User Story
Como repartidor freelance, quiero recibir notificaciones de pedidos cercanos y decidir cuáles aceptar.

### Tareas Técnicas
- [ ] Toggle "Modo Freelance":
  - Activar/desactivar en perfil
  - Persistir preferencia
- [ ] Configuración de radio de trabajo:
  - Slider de 1-10 km
  - Guardar preferencia
- [ ] Recepción de ofertas:
  - WebSocket escuchando ofertas
  - Notificación push con sonido
  - Dialog de oferta:
    - Info del pedido
    - Distancia
    - Ganancia estimada
    - Countdown (5 min)
    - Botones: Aceptar, Rechazar
- [ ] Sistema de reputación:
  - Mostrar rating actual
  - Historial de calificaciones
  - Impacto de rechazos
- [ ] Estadísticas freelance:
  - Ofertas recibidas
  - Ofertas aceptadas
  - Tasa de aceptación
  - Ganancias por período
- [ ] Filtros de ofertas:
  - Monto mínimo
  - Distancia máxima
  - Métodos de pago preferidos

### Definición de Hecho (DoD)
- ✅ Modo freelance activable
- ✅ Ofertas se reciben correctamente
- ✅ Notificaciones con sonido
- ✅ Aceptar/rechazar funciona
- ✅ Estadísticas calculadas
- ✅ Filtros aplicables

---

## Issue #29: Historial y Ganancias

**Labels:** `frontend`, `flutter`, `repartidor`, `historial`, `priority:medium`  
**Sprint:** Sprint 4  
**Estimación:** 1 día  

### Descripción
Implementar pantalla de historial de entregas y resumen de ganancias.

### User Story
Como repartidor, quiero ver mi historial de entregas y cuánto he ganado.

### Tareas Técnicas
- [ ] `HistorialScreen`:
  - Filtros: Hoy, Semana, Mes, Personalizado
  - Lista de entregas completadas
  - Card por entrega:
    - Fecha y hora
    - Comercio
    - Dirección de entrega
    - Ganancia
    - Rating recibido
- [ ] `GananciasScreen`:
  - Cards de resumen:
    - Ganancias del día
    - Ganancias de la semana
    - Ganancias del mes
    - Total histórico
  - Gráfico de ganancias diarias
  - Desglose por método de pago
  - Total de entregas
  - Promedio por entrega
- [ ] Exportación de reportes:
  - PDF con resumen
  - CSV con detalle
  - Compartir por WhatsApp/Email
- [ ] Filtros avanzados:
  - Por comercio
  - Por método de pago
  - Por rango de fechas
- [ ] Caché de datos históricos

### Definición de Hecho (DoD)
- ✅ Historial se muestra correctamente
- ✅ Ganancias calculadas correctamente
- ✅ Filtros funcionan
- ✅ Gráficos visualizan datos
- ✅ Exportación operativa

---

## Issue #30: Testing End-to-End y Deployment

**Labels:** `testing`, `deployment`, `priority:high`  
**Sprint:** Sprint 5  
**Estimación:** 3 días  

### Descripción
Realizar testing integral del sistema completo y deployment a producción.

### User Story
Como equipo de desarrollo, necesitamos asegurar que todo el sistema funciona correctamente antes de lanzar a producción.

### Tareas Técnicas
- [ ] **Testing Backend:**
  - Tests unitarios (>80% coverage)
  - Tests de integración
  - Tests de API (Postman/Insomnia)
  - Tests de WebSockets
  - Tests de multi-tenancy
  - Load testing (100 usuarios concurrentes)
- [ ] **Testing Frontend:**
  - Tests unitarios de providers
  - Tests de widgets
  - Tests de integración
  - Tests E2E con Flutter Driver
- [ ] **Testing Manual:**
  - Flujo completo cliente → comercio → repartidor
  - Diferentes métodos de pago
  - Tracking en tiempo real
  - Notificaciones push
  - GPS en segundo plano
- [ ] **Optimización:**
  - Optimizar queries N+1
  - Implementar cache agresivo
  - Comprimir imágenes
  - Minificar assets
  - Lazy loading
- [ ] **Deployment Backend:**
  - Configurar servidor producción
  - Setup Nginx + PHP-FPM + SSL
  - Configurar Redis y Reverb
  - Migraciones en producción
  - Seeders de configuración
  - Setup de backups automáticos
- [ ] **Deployment Frontend:**
  - Build PWA optimizado
  - Deploy a CDN
  - Build APKs release firmados
  - Subir a Google Play (internal testing)
- [ ] **Monitoring:**
  - Setup Sentry para error tracking
  - Configurar logs
  - Alertas de downtime
  - Dashboard de métricas

### Definición de Hecho (DoD)
- ✅ Todos los tests pasando
- ✅ Coverage >80%
- ✅ Sistema en producción
- ✅ PWA accesible
- ✅ APKs en Google Play
- ✅ Monitoring activo
- ✅ Backups configurados
- ✅ Documentación completa

---

## LABELS SUGERIDOS

```
# Por Tipo
backend
frontend
flutter
database
api
testing
deployment
setup

# Por Componente
auth
multi-tenant
websockets
gps
notifications
branding
productos
pedidos
carrito
checkout
tracking

# Por App
pwa
comercio
repartidor

# Por Prioridad
priority:critical
priority:high
priority:medium
priority:low

# Por Estado
bug
enhancement
documentation
help-wanted
```

---

## TEMPLATE DE ISSUE

```markdown
## Descripción
[Descripción clara y concisa del issue]

## User Story
Como [tipo de usuario], quiero [objetivo] para [beneficio].

## Tareas Técnicas
- [ ] Tarea 1
- [ ] Tarea 2
- [ ] Tarea 3

## Definición de Hecho (DoD)
- ✅ Criterio 1
- ✅ Criterio 2
- ✅ Criterio 3

## Notas Adicionales
[Cualquier información relevante]

## Enlaces
- Documentación relacionada
- Diseños en Figma
- PRs relacionados
```
