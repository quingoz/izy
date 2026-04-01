# 📅 PLAN DE DESARROLLO - IZY (8 SEMANAS)

## RESUMEN EJECUTIVO

**Duración Total:** 8 semanas (56 días)  
**Metodología:** Agile/Scrum con sprints de 2 semanas  
**Equipo:** 1-2 desarrolladores full-stack  
**Objetivo:** MVP funcional de plataforma multi-tenant de delivery  

---

## SPRINT 0: PREPARACIÓN (Días 1-3)

### Objetivos
- Configurar entorno de desarrollo
- Inicializar repositorios
- Configurar herramientas de CI/CD

### Tareas

#### Backend Setup
- [ ] Instalar Laravel 11 + PHP 8.3
- [ ] Configurar MySQL/MariaDB
- [ ] Instalar Redis
- [ ] Configurar Laravel Reverb
- [ ] Setup Laravel Sanctum
- [ ] Configurar Laravel Telescope (desarrollo)

#### Frontend Setup
- [ ] Instalar Flutter 3.19+
- [ ] Configurar estructura de proyecto multi-target
- [ ] Setup Riverpod + Dio
- [ ] Configurar Firebase (FCM)
- [ ] Setup Google Maps API

#### DevOps
- [ ] Crear repositorio Git
- [ ] Configurar .gitignore
- [ ] Setup Docker (opcional)
- [ ] Configurar entornos (dev, staging, prod)

#### Documentación
- [ ] README.md con instrucciones de instalación
- [ ] Guía de contribución
- [ ] Estándares de código

### Entregables
- ✅ Entorno de desarrollo funcional
- ✅ Repositorio Git inicializado
- ✅ Documentación básica

---

## SPRINT 1: BACKEND CORE + DATABASE (Semanas 1-2)

### Objetivos
- Implementar arquitectura multi-tenant
- Crear esquema de base de datos completo
- Desarrollar sistema de autenticación

### Tareas Detalladas

#### Semana 1: Database & Models

**Día 1-2: Migraciones**
- [ ] Crear migración `users`
- [ ] Crear migración `comercios`
- [ ] Crear migración `categorias`
- [ ] Crear migración `productos`
- [ ] Crear migración `repartidores`
- [ ] Crear migración `comercio_repartidor`
- [ ] Ejecutar y validar migraciones

**Día 3-4: Modelos Eloquent**
- [ ] Modelo `User` con roles
- [ ] Modelo `Comercio` con branding
- [ ] Modelo `Producto` con variantes
- [ ] Modelo `Repartidor` con GPS
- [ ] Trait `BelongsToTenant`
- [ ] Global Scope `TenantScope`
- [ ] Relaciones entre modelos

**Día 5: Seeders**
- [ ] `ConfiguracionSeeder`
- [ ] `UserSeeder` (datos de prueba)
- [ ] `ComercioSeeder` (2-3 comercios)
- [ ] `ProductoSeeder` (20+ productos)
- [ ] `RepartidorSeeder` (5+ repartidores)

#### Semana 2: Auth & Multi-tenancy

**Día 6-7: Autenticación**
- [ ] AuthController (login, register, logout)
- [ ] Sanctum token generation
- [ ] Password reset
- [ ] Email verification
- [ ] Phone verification (SMS)
- [ ] Middleware `auth:sanctum`

**Día 8-9: Multi-tenant Logic**
- [ ] Middleware `IdentifyTenant`
- [ ] Implementar TenantScope en modelos
- [ ] Políticas de autorización
- [ ] Testing de aislamiento de datos
- [ ] Validación de pertenencia

**Día 10: API Base**
- [ ] Rutas API organizadas
- [ ] Response formatters
- [ ] Exception handlers
- [ ] Rate limiting
- [ ] API versioning

### Entregables Sprint 1
- ✅ Base de datos completa con seeders
- ✅ Sistema de autenticación funcional
- ✅ Multi-tenancy implementado y testeado
- ✅ API base con endpoints de auth

### Testing Sprint 1
```bash
php artisan test --filter=AuthTest
php artisan test --filter=TenantTest
php artisan test --filter=UserTest
```

---

## SPRINT 2: API REST + PWA CLIENTE (Semanas 3-4)

### Objetivos
- Desarrollar API completa para cliente
- Implementar PWA con branding dinámico
- Sistema de carrito y checkout

### Tareas Detalladas

#### Semana 3: API Endpoints

**Día 11-12: API Comercios & Productos**
- [ ] `GET /api/comercios/{slug}` - Info del comercio
- [ ] `GET /api/comercios/{slug}/productos` - Catálogo
- [ ] `GET /api/comercios/{slug}/categorias` - Categorías
- [ ] `GET /api/productos/{id}` - Detalle producto
- [ ] `GET /api/comercios/cercanos` - Búsqueda por GPS
- [ ] Cache de productos por comercio
- [ ] Filtros y búsqueda

**Día 13-14: API Pedidos (Cliente)**
- [ ] `POST /api/pedidos` - Crear pedido
- [ ] `GET /api/pedidos/{id}` - Detalle pedido
- [ ] `GET /api/mis-pedidos` - Historial
- [ ] `GET /api/pedidos/{token}/tracking` - Tracking público
- [ ] Validación de stock
- [ ] Cálculo de totales
- [ ] Generación de número de pedido

**Día 15: API Direcciones**
- [ ] `POST /api/direcciones` - Guardar dirección
- [ ] `GET /api/direcciones` - Listar direcciones
- [ ] `PUT /api/direcciones/{id}` - Actualizar
- [ ] `DELETE /api/direcciones/{id}` - Eliminar
- [ ] Geocoding con Google Maps

#### Semana 4: PWA Cliente (Flutter Web)

**Día 16-17: Setup & Branding**
- [ ] Estructura de proyecto Flutter Web
- [ ] Routing con go_router
- [ ] State management con Riverpod
- [ ] API client con Dio
- [ ] Interceptor de autenticación
- [ ] Provider de branding dinámico
- [ ] Carga de colores/logo desde API

**Día 18-19: Catálogo & Carrito**
- [ ] Pantalla de inicio (slug detection)
- [ ] Listado de productos por categoría
- [ ] Detalle de producto con variantes
- [ ] Carrito de compras (state local)
- [ ] Modificar cantidades
- [ ] Cálculo de subtotales
- [ ] Persistencia en localStorage

**Día 20: Checkout**
- [ ] Pantalla de checkout
- [ ] Selección de dirección
- [ ] Métodos de pago:
  - [ ] Efectivo (cálculo de vuelto)
  - [ ] Pago Móvil (formulario)
- [ ] Resumen de pedido
- [ ] Confirmación y envío
- [ ] Redirección a tracking

### Entregables Sprint 2
- ✅ API REST completa para cliente
- ✅ PWA funcional con branding dinámico
- ✅ Flujo completo de compra
- ✅ Carrito y checkout operativos

### Testing Sprint 2
```bash
# Backend
php artisan test --filter=PedidoTest
php artisan test --filter=ProductoTest

# Frontend
flutter test test/features/catalogo
flutter test test/features/carrito
```

---

## SPRINT 3: TRACKING + APP COMERCIO (Semanas 5-6)

### Objetivos
- Implementar tracking en tiempo real
- Desarrollar app Android para comercios
- Kitchen flow completo

### Tareas Detalladas

#### Semana 5: Real-time & Tracking

**Día 21-22: Laravel Reverb**
- [ ] Configurar Reverb server
- [ ] Eventos broadcast:
  - [ ] `PedidoEstadoActualizado`
  - [ ] `RepartidorUbicacionActualizada`
  - [ ] `PedidoAsignado`
- [ ] Canales privados por pedido
- [ ] Canales por comercio
- [ ] Testing de WebSockets

**Día 23-24: Tracking PWA**
- [ ] WebSocket client en Flutter
- [ ] Pantalla de tracking
- [ ] Mapa con Google Maps
- [ ] Marcador de repartidor (actualización real-time)
- [ ] Progreso de estados
- [ ] Notificaciones en app
- [ ] Estimación de tiempo de llegada

**Día 25: Notificaciones Push**
- [ ] Setup Firebase Cloud Messaging
- [ ] Backend: envío de notificaciones
- [ ] Job queue para notificaciones
- [ ] Frontend: recepción y manejo
- [ ] Deep linking a tracking

#### Semana 6: App Comercio (Flutter Android)

**Día 26-27: Setup & Dashboard**
- [ ] Flavor "comercio" en build.gradle
- [ ] Entry point `main_comercio.dart`
- [ ] Login para comercios
- [ ] Dashboard principal:
  - [ ] Pedidos activos (tiempo real)
  - [ ] Métricas del día
  - [ ] Alertas sonoras
- [ ] Notificaciones push de nuevos pedidos

**Día 28-29: Kitchen Flow**
- [ ] Pantalla de cola de pedidos
- [ ] Detalle de pedido con items
- [ ] Cambio de estados:
  - [ ] Pendiente → Confirmado
  - [ ] Confirmado → Preparando
  - [ ] Preparando → Listo
- [ ] Temporizadores de preparación
- [ ] Confirmación de cambios
- [ ] Broadcast de estados

**Día 30: Gestión de Productos**
- [ ] Listado de productos
- [ ] Crear/editar producto
- [ ] Upload de imágenes
- [ ] Gestión de variantes
- [ ] Control de stock
- [ ] Activar/desactivar productos

### Entregables Sprint 3
- ✅ Tracking en tiempo real funcional
- ✅ App Android para comercios
- ✅ Kitchen flow operativo
- ✅ Gestión básica de productos

### Testing Sprint 3
```bash
# Backend
php artisan test --filter=WebSocketTest
php artisan test --filter=NotificationTest

# App Comercio
flutter test test/features/comercio
flutter build apk --flavor comercio --debug
```

---

## SPRINT 4: APP REPARTIDOR + LOGÍSTICA (Semanas 7-8)

### Objetivos
- Desarrollar app Android para repartidores
- Sistema de asignación de pedidos
- GPS tracking en segundo plano

### Tareas Detalladas

#### Semana 7: App Repartidor

**Día 31-32: Setup & GPS**
- [ ] Flavor "repartidor" en build.gradle
- [ ] Entry point `main_repartidor.dart`
- [ ] Login para repartidores
- [ ] Permisos de ubicación
- [ ] Background geolocation:
  - [ ] Plugin `geolocator`
  - [ ] Servicio en segundo plano
  - [ ] Envío de ubicación cada 10s
- [ ] API endpoint `POST /api/repartidor/ubicacion`

**Día 33-34: Gestión de Pedidos**
- [ ] Pantalla de pedidos disponibles
- [ ] Notificación de nuevo pedido
- [ ] Detalle de pedido:
  - [ ] Distancia al comercio
  - [ ] Distancia al cliente
  - [ ] Monto a cobrar
  - [ ] Método de pago
- [ ] Aceptar/Rechazar pedido
- [ ] Estados del repartidor:
  - [ ] Disponible
  - [ ] Ocupado
  - [ ] Offline

**Día 35: Navegación & Entrega**
- [ ] Deep link a Google Maps/Waze
- [ ] Botón "Navegar al comercio"
- [ ] Botón "Navegar al cliente"
- [ ] Confirmar recogida en comercio
- [ ] Confirmar entrega al cliente
- [ ] Registro de cobro (si es efectivo)
- [ ] Captura de firma (opcional)

#### Semana 8: Logística & Asignación

**Día 36-37: Sistema de Asignación**
- [ ] API `POST /api/pedidos/{id}/asignar-repartidor`
- [ ] Lógica de asignación:
  - [ ] Prioridad 1: Repartidores exclusivos
  - [ ] Prioridad 2: Freelancers en 3km
- [ ] Cálculo de distancia (Haversine)
- [ ] Broadcast a repartidores elegibles
- [ ] Timeout de aceptación (5 min)
- [ ] Reasignación automática

**Día 38-39: Modo Freelance**
- [ ] Toggle freelance/exclusivo
- [ ] Recepción de ofertas cercanas
- [ ] Filtro por radio de trabajo
- [ ] Sistema de reputación (rating)
- [ ] Historial de entregas
- [ ] Ganancias diarias/semanales

**Día 40: Integración Comercio-Repartidor**
- [ ] Pantalla de logística en app comercio
- [ ] Listado de repartidores exclusivos
- [ ] Asignación manual
- [ ] Solicitud de freelancer
- [ ] Vista de repartidores en mapa
- [ ] Estado de entrega en tiempo real

### Entregables Sprint 4
- ✅ App Android para repartidores
- ✅ GPS tracking en segundo plano
- ✅ Sistema de asignación inteligente
- ✅ Modo freelance operativo

### Testing Sprint 4
```bash
# Backend
php artisan test --filter=RepartidorTest
php artisan test --filter=AsignacionTest

# App Repartidor
flutter test test/features/repartidor
flutter build apk --flavor repartidor --release
```

---

## SPRINT 5: TESTING, OPTIMIZACIÓN & DEPLOYMENT (Semana 8+)

### Objetivos
- Testing integral del sistema
- Optimización de performance
- Deployment a producción

### Tareas Detalladas

**Día 41-42: Testing End-to-End**
- [ ] Flujo completo cliente → comercio → repartidor
- [ ] Testing de multi-tenancy
- [ ] Testing de WebSockets bajo carga
- [ ] Testing de notificaciones push
- [ ] Testing de GPS tracking
- [ ] Validación de cálculos (totales, vuelto)
- [ ] Testing de métodos de pago

**Día 43-44: Optimización**
- [ ] Optimizar queries N+1
- [ ] Implementar cache Redis
- [ ] Optimizar imágenes
- [ ] Minificar assets PWA
- [ ] Lazy loading en Flutter
- [ ] Indexación de DB
- [ ] Monitoring con Telescope

**Día 45-46: Deployment**
- [ ] Configurar servidor producción
- [ ] Setup Nginx + PHP-FPM
- [ ] SSL con Let's Encrypt
- [ ] Configurar Redis
- [ ] Configurar Laravel Reverb
- [ ] Variables de entorno
- [ ] Migraciones en producción
- [ ] Seeders de configuración

**Día 47-48: Documentación & Capacitación**
- [ ] Manual de usuario (Cliente)
- [ ] Manual de usuario (Comercio)
- [ ] Manual de usuario (Repartidor)
- [ ] Documentación técnica API
- [ ] Guía de deployment
- [ ] Video tutoriales
- [ ] FAQ

### Entregables Sprint 5
- ✅ Sistema completamente testeado
- ✅ Aplicación en producción
- ✅ Documentación completa
- ✅ Capacitación realizada

---

## CRONOGRAMA VISUAL

```
Semana 1-2 (Sprint 1): Backend Core + Database
├── Día 1-5:   Migraciones, Modelos, Seeders
└── Día 6-10:  Auth, Multi-tenancy, API Base

Semana 3-4 (Sprint 2): API REST + PWA Cliente
├── Día 11-15: API Endpoints (Comercios, Productos, Pedidos)
└── Día 16-20: PWA (Branding, Catálogo, Carrito, Checkout)

Semana 5-6 (Sprint 3): Tracking + App Comercio
├── Día 21-25: Real-time (Reverb, Tracking, Push)
└── Día 26-30: App Comercio (Dashboard, Kitchen, Productos)

Semana 7-8 (Sprint 4): App Repartidor + Logística
├── Día 31-35: App Repartidor (GPS, Pedidos, Navegación)
└── Día 36-40: Logística (Asignación, Freelance, Integración)

Semana 8+ (Sprint 5): Testing & Deployment
└── Día 41-48: Testing, Optimización, Deploy, Docs
```

---

## HITOS PRINCIPALES

| Hito | Fecha Estimada | Descripción |
|------|----------------|-------------|
| **M1: Backend Ready** | Fin Semana 2 | API base + Auth + Multi-tenant |
| **M2: Cliente Funcional** | Fin Semana 4 | PWA con checkout completo |
| **M3: Comercio Operativo** | Fin Semana 6 | App comercio con kitchen flow |
| **M4: Repartidor Activo** | Fin Semana 8 | App repartidor con GPS |
| **M5: MVP en Producción** | Fin Semana 8+ | Sistema completo deployado |

---

## RECURSOS NECESARIOS

### Humanos
- 1-2 Desarrolladores Full-stack (Laravel + Flutter)
- 1 Diseñador UI/UX (part-time)
- 1 QA Tester (últimas 2 semanas)

### Infraestructura
- Servidor VPS (4GB RAM, 2 CPU)
- Dominio + SSL
- Firebase (plan gratuito)
- Google Maps API (créditos gratuitos)
- Redis server

### Herramientas
- GitHub/GitLab
- Postman/Insomnia (testing API)
- Laravel Telescope
- Flutter DevTools
- Sentry (error tracking)

---

## RIESGOS Y CONTINGENCIAS

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Retrasos en desarrollo | Alta | Alto | Buffer de 1 semana adicional |
| Problemas con WebSockets | Media | Alto | Fallback a polling si falla |
| GPS impreciso | Media | Medio | Aumentar intervalo de actualización |
| Sobrecarga de servidor | Baja | Alto | Implementar queue y cache agresivo |
| Bugs en multi-tenancy | Media | Crítico | Testing exhaustivo desde Sprint 1 |

---

## MÉTRICAS DE ÉXITO

### Técnicas
- [ ] Cobertura de tests > 70%
- [ ] Tiempo de respuesta API < 200ms
- [ ] Uptime > 99%
- [ ] 0 errores críticos en producción

### Funcionales
- [ ] Flujo completo de pedido funcional
- [ ] Tracking en tiempo real operativo
- [ ] 3+ comercios activos en pruebas
- [ ] 5+ repartidores registrados

### Negocio
- [ ] 50+ pedidos de prueba exitosos
- [ ] Tasa de error < 5%
- [ ] Tiempo promedio de entrega < 45 min
- [ ] Satisfacción de usuarios > 4.0/5.0

---

## PRÓXIMOS PASOS POST-MVP

### Fase 2 (Semanas 9-12)
- [ ] App iOS (Flutter)
- [ ] Sistema de cupones y descuentos
- [ ] Programa de fidelización
- [ ] Chat en tiempo real
- [ ] Reportes avanzados
- [ ] Panel de super admin

### Fase 3 (Meses 4-6)
- [ ] Integración con pasarelas de pago
- [ ] Facturación electrónica
- [ ] Multi-idioma
- [ ] API pública para integraciones
- [ ] Marketplace de comercios

---

## COMANDOS ÚTILES

### Backend
```bash
# Desarrollo
php artisan serve
php artisan reverb:start
php artisan queue:work

# Migraciones
php artisan migrate:fresh --seed

# Testing
php artisan test
php artisan test --coverage

# Cache
php artisan cache:clear
php artisan config:cache
php artisan route:cache
```

### Frontend
```bash
# PWA
flutter run -d chrome
flutter build web --release

# App Comercio
flutter run --flavor comercio
flutter build apk --flavor comercio --release

# App Repartidor
flutter run --flavor repartidor
flutter build apk --flavor repartidor --release

# Testing
flutter test
flutter test --coverage
```

### Deployment
```bash
# Backend
git pull origin main
composer install --no-dev
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan queue:restart

# Frontend
flutter build web --release
rsync -avz build/web/ user@server:/var/www/izy/
```
