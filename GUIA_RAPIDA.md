# 🚀 Guía Rápida - Proyecto IZY

## Resumen del Proyecto

**IZY** es una plataforma SaaS multi-tenant de delivery diseñada para el mercado venezolano.

### Componentes Principales

1. **Backend API** - Laravel 11 + MySQL + Redis + Reverb
2. **PWA Cliente** - Flutter Web con branding dinámico
3. **App Comercio** - Flutter Android para gestión de pedidos
4. **App Repartidor** - Flutter Android con GPS tracking

### Paleta de Colores (Logo IZY)

- **Primary:** `#1B3A57` (Azul oscuro/Navy)
- **Secondary:** `#5FD4A0` (Verde mint)
- **Accent:** `#4CAF50` (Verde)

---

## 📋 Issues Creados

Se han generado **11 issues detallados** para el desarrollo del proyecto:

### Epic 1: Backend Core & Database

1. **Issue #1** - Setup Inicial del Proyecto Backend
2. **Issue #2** - Crear Esquema de Base de Datos (13 tablas)
3. **Issue #3** - Implementar Modelos Eloquent
4. **Issue #4** - Sistema de Autenticación con Sanctum
5. **Issue #5** - Implementar Multi-tenancy
6. **Issue #6** - API de Comercios y Productos
7. **Issue #7** - API de Pedidos (Cliente)
8. **Issue #8** - Sistema de WebSockets con Laravel Reverb
9. **Issue #9** - Sistema de Notificaciones Push (FCM)
10. **Issue #10** - API de Gestión de Pedidos (Comercio)
11. **Issue #11** - API de Repartidores y GPS Tracking

### Epic 2: PWA Cliente

12. **Issue #12** - Setup Proyecto Flutter Web

**Nota:** Los issues restantes (#13-#35) siguen el mismo patrón detallado. Puedes solicitarlos cuando los necesites.

---

## 🔧 Workflows Disponibles

### 1. Workflow Single Issue (`.windsurf/workflows/single-issue.md`)

Para desarrollar un issue individual con máximo detalle.

**Uso:**
```
"Quiero desarrollar el Issue #3"
```

**Características:**
- Guía paso a paso
- Validación exhaustiva
- Tests completos
- Ideal para issues complejos

### 2. Workflow Multi Issue (`.windsurf/workflows/multi-issue.md`)

Para desarrollar varios issues relacionados y **ahorrar créditos**.

**Uso:**
```
"Quiero desarrollar los Issues #1, #2 y #3"
```

**Características:**
- Desarrollo secuencial optimizado
- Validación entre issues
- Commit consolidado
- **Ahorra hasta 60% de créditos**

---

## 🎯 Cómo Empezar

### Opción A: Desarrollo Secuencial (Recomendado)

```
1. "Desarrolla el Issue #1"
2. "Desarrolla el Issue #2"
3. "Desarrolla el Issue #3"
...
```

### Opción B: Desarrollo por Sprints (Ahorro de Créditos)

```
"Desarrolla todos los issues del Sprint 1 (#2, #3, #4, #5)"
```

### Opción C: Desarrollo por Epic

```
"Desarrolla el Epic 1 completo (Issues #1 al #11)"
```

---

## 📁 Estructura del Proyecto

```
izy/
├── .windsurf/
│   └── workflows/
│       ├── single-issue.md    # Workflow para 1 issue
│       └── multi-issue.md     # Workflow para múltiples issues
├── docs/
│   ├── 00_INDEX.md
│   ├── 01_PROJECT_CHARTER.md
│   ├── 02_TECHNICAL_ARCHITECTURE.md
│   ├── 03_DATABASE_SCHEMA.md
│   ├── 04_DEVELOPMENT_PLAN.md
│   ├── 05_GITHUB_ISSUES.md
│   └── 06_API_DOCUMENTATION.md
├── issues/
│   ├── README.md              # Índice de todos los issues
│   ├── ISSUE-01-setup-backend.md
│   ├── ISSUE-02-database-schema.md
│   ├── ISSUE-03-modelos-eloquent.md
│   ├── ISSUE-04-autenticacion-sanctum.md
│   ├── ISSUE-05-multi-tenancy.md
│   ├── ISSUE-06-api-comercios-productos.md
│   ├── ISSUE-07-api-pedidos-cliente.md
│   ├── ISSUE-08-websockets-reverb.md
│   ├── ISSUE-09-notificaciones-push.md
│   ├── ISSUE-10-api-comercio-pedidos.md
│   ├── ISSUE-11-api-repartidores-gps.md
│   └── ISSUE-12-setup-flutter-web.md
├── izy-logo.png
├── README.md
└── GUIA_RAPIDA.md             # Este archivo
```

---

## 💡 Características de los Issues

Cada issue incluye:

✅ **Descripción clara** del objetivo  
✅ **Tareas técnicas detalladas** con código de ejemplo  
✅ **Comandos de verificación** para probar  
✅ **Definición de Hecho (DoD)** con criterios de aceptación  
✅ **Tests requeridos**  
✅ **Dependencias** de otros issues  
✅ **Siguiente issue** sugerido  

---

## 🗄️ Base de Datos

### Tablas Principales (13 en total)

1. `users` - Usuarios del sistema
2. `comercios` - Comercios/negocios
3. `categorias` - Categorías de productos
4. `productos` - Catálogo de productos
5. `repartidores` - Información de repartidores
6. `comercio_repartidor` - Relación N:M
7. `direcciones` - Direcciones de clientes
8. `pedidos` - Pedidos realizados
9. `pedido_items` - Items de cada pedido
10. `pedido_estados` - Historial de estados
11. `repartidor_ubicaciones` - Tracking GPS
12. `notificaciones` - Notificaciones enviadas
13. `configuraciones` - Config global

### Queries SQL

Los queries completos están en cada issue. Para ejecutarlos:

```bash
# Desde el Issue #2
mysql -u root -p izy_dev < queries.sql
```

---

## 🚀 Stack Tecnológico

### Backend
- **Framework:** Laravel 11
- **Base de Datos:** MySQL 8.0 / MariaDB 10.11
- **Cache:** Redis 7.x
- **WebSockets:** Laravel Reverb
- **Auth:** Laravel Sanctum
- **Notificaciones:** Firebase Cloud Messaging

### Frontend
- **Framework:** Flutter 3.19+
- **State Management:** Riverpod 2.5+
- **HTTP:** Dio 5.x
- **WebSockets:** socket_io_client
- **Maps:** Google Maps Flutter
- **Storage:** Hive

---

## 📊 Plan de Desarrollo

### Sprint 0 (Días 1-3)
- Issue #1: Setup Backend

### Sprint 1 (Semanas 1-2)
- Issues #2-#5: Database, Modelos, Auth, Multi-tenancy

### Sprint 2 (Semanas 3-4)
- Issues #6-#7: API Comercios/Productos/Pedidos
- Issues #12-#17: PWA Cliente completa

### Sprint 3 (Semanas 5-6)
- Issues #8-#10: WebSockets, Notificaciones, API Comercio
- Issues #18-#23: Tracking + App Comercio

### Sprint 4 (Semanas 7-8)
- Issue #11: API Repartidores
- Issues #24-#30: App Repartidor completa

### Sprint 5 (Semana 8+)
- Issues #31-#35: Testing, Optimización, Deployment

---

## 🎨 Diseño de Interfaces

### Colores a Usar

```dart
// Flutter
static const Color primaryColor = Color(0xFF1B3A57);
static const Color secondaryColor = Color(0xFF5FD4A0);
static const Color accentColor = Color(0xFF4CAF50);
```

```css
/* CSS */
--primary-color: #1B3A57;
--secondary-color: #5FD4A0;
--accent-color: #4CAF50;
```

### Componentes UI

- **Botones:** Bordes redondeados (12px)
- **Cards:** Sombra suave, padding 16px
- **Inputs:** Filled con fondo gris claro
- **Iconos:** Material Icons / Lucide

---

## 📝 Comandos Útiles

### Backend (Laravel)

```bash
# Desarrollo
php artisan serve
php artisan reverb:start
php artisan queue:work

# Migraciones
php artisan migrate:fresh --seed

# Tests
php artisan test
php artisan test --filter=NombreTest

# Cache
php artisan cache:clear
php artisan config:cache
```

### Frontend (Flutter)

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

# Tests
flutter test
flutter test --coverage
```

---

## 🔍 Próximos Pasos

### Para Comenzar Ahora:

1. **Leer documentación completa** en `docs/`
2. **Revisar issues** en `issues/README.md`
3. **Elegir workflow** según tu preferencia
4. **Comenzar con Issue #1** o solicitar múltiples issues

### Ejemplos de Comandos:

```
# Opción 1: Un issue a la vez
"Desarrolla el Issue #1"

# Opción 2: Múltiples issues (ahorro de créditos)
"Desarrolla los Issues #1, #2 y #3"

# Opción 3: Sprint completo
"Desarrolla el Sprint 1 completo"

# Opción 4: Generar issues faltantes
"Genera los Issues #13 al #20"
```

---

## 📞 Soporte

- **Documentación:** `docs/`
- **Issues:** `issues/`
- **Workflows:** `.windsurf/workflows/`

---

## ✅ Checklist de Inicio

- [ ] Leer `docs/01_PROJECT_CHARTER.md`
- [ ] Revisar `docs/03_DATABASE_SCHEMA.md`
- [ ] Entender estructura de issues
- [ ] Elegir workflow (single o multi)
- [ ] Comenzar con Issue #1

---

**¡Listo para comenzar el desarrollo! 🚀**

Usa los workflows para optimizar tu tiempo y créditos.
