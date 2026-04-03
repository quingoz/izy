# 📋 Issues del Proyecto IZY

Este directorio contiene todos los issues detallados para el desarrollo del proyecto IZY.

## Estructura de Issues

Los issues están organizados por Epics:

### Epic 1: Backend Core & Database (Issues #1-11)
- **#1:** Setup Inicial del Proyecto Backend ⚙️
- **#2:** Crear Esquema de Base de Datos (13 tablas) 🗄️
- **#3:** Implementar Modelos Eloquent 📦
- **#4:** Sistema de Autenticación con Sanctum 🔐
- **#5:** Implementar Multi-tenancy 🏢
- **#6:** API de Comercios y Productos 🛍️
- **#7:** API de Pedidos (Cliente) 📝
- **#8:** Sistema de WebSockets con Laravel Reverb 🔌
- **#9:** Sistema de Notificaciones Push (FCM) 🔔
- **#10:** API de Gestión de Pedidos (Comercio) 📊
- **#11:** API de Repartidores y GPS Tracking 📍

### Epic 2: PWA Cliente (Issues #12-18)
- **#12:** Setup Proyecto Flutter Web 🌐
- **#13:** Cliente HTTP y State Management 🔄
- **#14:** Sistema de Branding Dinámico 🎨
- **#15:** Catálogo de Productos 📋
- **#16:** Carrito de Compras 🛒
- **#17:** Checkout y Métodos de Pago 💳
- **#18:** Tracking en Tiempo Real 🗺️

### Epic 3: App Comercio (Issues #19-23)
- **#19:** Setup App Android Comercio (Flutter Flavor) 📱
- **#20:** Dashboard de Comercio 📈
- **#21:** Kitchen Flow (Gestión de Estados) 👨‍🍳
- **#22:** Gestión de Productos ✏️
- **#23:** Logística y Asignación de Repartidores 🚚

### Epic 4: App Repartidor (Issues #24-30)
- **#24:** Setup App Android Repartidor (Flutter Flavor) 📱
- **#25:** GPS Tracking en Segundo Plano 🛰️
- **#26:** Gestión de Pedidos Disponibles 📦
- **#27:** Navegación y Entrega 🧭
- **#28:** Sistema de Asignación Inteligente 🤖
- **#29:** Modo Freelance 🆓
- **#30:** Estadísticas y Ganancias 💰

### Epic 5: Testing & Deployment (Issues #31-35)
- **#31:** Tests End-to-End ✅
- **#32:** Optimización de Performance ⚡
- **#33:** Deployment Backend 🚀
- **#34:** Deployment Frontend (PWA) 🌍
- **#35:** Generación de APKs 📲

## Cómo Usar los Issues

### Para Desarrollar un Issue Individual

1. Usar el workflow: `.windsurf/workflows/single-issue.md`
2. Comando: Mencionar el issue que quieres desarrollar
3. Ejemplo: "Quiero desarrollar el Issue #3"

### Para Desarrollar Múltiples Issues

1. Usar el workflow: `.windsurf/workflows/multi-issue.md`
2. Comando: Especificar los issues a desarrollar
3. Ejemplo: "Quiero desarrollar los Issues #1, #2 y #3"

## Paleta de Colores del Proyecto

Basada en el logo IZY:

- **Primary (Azul Oscuro):** `#1B3A57`
- **Secondary (Verde Mint):** `#5FD4A0`
- **Accent (Verde):** `#4CAF50`
- **Background:** Degradado verde claro a blanco

## Orden Recomendado de Desarrollo

### Sprint 0 (Día 1-3)
- Issue #1

### Sprint 1 (Semana 1-2)
- Issues #2, #3, #4, #5

### Sprint 2 (Semana 3-4)
- Issues #6, #7, #12, #13, #14, #15, #16, #17

### Sprint 3 (Semana 5-6)
- Issues #8, #9, #10, #18, #19, #20, #21, #22, #23

### Sprint 4 (Semana 7-8)
- Issues #11, #24, #25, #26, #27, #28, #29, #30

### Sprint 5 (Semana 8+)
- Issues #31, #32, #33, #34, #35

## Dependencias entre Issues

Cada issue tiene una sección de dependencias que indica qué issues deben completarse antes.

## Definición de Hecho (DoD)

Cada issue incluye:
- ✅ Descripción clara del objetivo
- ✅ Tareas técnicas detalladas
- ✅ Código de ejemplo
- ✅ Comandos de verificación
- ✅ Criterios de aceptación
- ✅ Tests requeridos

## Notas Importantes

- **Base de datos:** MySQL local (XAMPP)
- **Entorno:** Desarrollo local inicialmente
- **Testing:** Ejecutar tests antes de marcar como completado
- **Commits:** Hacer commits frecuentes por issue

## Soporte

Para dudas sobre los issues, consultar:
- `docs/` - Documentación técnica completa
- `.windsurf/workflows/` - Workflows de desarrollo
