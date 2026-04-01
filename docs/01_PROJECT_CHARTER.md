# 🚀 PROJECT CHARTER: IZY - SAAS DELIVERY ECOSYSTEM

![IZY Logo](../izy-logo.png)

## 📋 INFORMACIÓN DEL PROYECTO

**Nombre del Proyecto:** IZY  
**Tipo:** Plataforma SaaS Multi-tenant de Delivery  
**Mercado Objetivo:** Venezuela  
**Versión:** 1.0.0  
**Fecha de Inicio:** Marzo 2026  

---

## 1. VISIÓN GENERAL

IZY es una plataforma de delivery SaaS Multi-tenant diseñada específicamente para el mercado venezolano. El sistema permite que múltiples comercios operen de forma completamente aislada bajo una misma infraestructura tecnológica, gestionando sus propios productos, pedidos y repartidores (tanto exclusivos como independientes).

### 1.1 Objetivos del Proyecto

- **Escalabilidad:** Soportar cientos de comercios simultáneamente sin degradación de rendimiento
- **Aislamiento:** Garantizar separación total de datos entre comercios (Multi-tenancy)
- **Flexibilidad:** Permitir personalización de marca por comercio (branding dinámico)
- **Tiempo Real:** Tracking GPS y actualizaciones de estado instantáneas
- **Economía Local:** Soporte nativo para Bolívares (Bs) y Dólares (USD)

### 1.2 Alcance del Proyecto

**Incluye:**
- PWA para clientes finales con branding dinámico
- App Android para comercios/administradores
- App Android para repartidores (modo exclusivo y freelance)
- Backend API RESTful con WebSockets
- Sistema de notificaciones push
- Tracking GPS en tiempo real
- Gestión multi-moneda (USD/Bs)

**No Incluye (Fase 1):**
- App iOS nativa
- Integración con pasarelas de pago internacionales
- Sistema de facturación electrónica
- Programa de fidelización

---

## 2. STAKEHOLDERS

### 2.1 Roles del Sistema

| Rol | Descripción | Responsabilidades |
|-----|-------------|-------------------|
| **Cliente** | Usuario final que realiza pedidos | Navegar catálogo, realizar pedidos, tracking |
| **Comercio/Admin** | Dueño o administrador del negocio | Gestión de productos, pedidos, repartidores |
| **Repartidor Exclusivo** | Vinculado a comercio(s) específico(s) | Entregas prioritarias de sus comercios |
| **Repartidor Freelance** | Independiente, acepta pedidos cercanos | Entregas bajo demanda en radio de 3km |
| **Super Admin** | Administrador de la plataforma | Gestión de comercios, configuración global |

### 2.2 Casos de Uso Principales

#### Cliente
- Buscar comercios cercanos
- Navegar catálogo de productos
- Agregar productos al carrito
- Realizar checkout con múltiples métodos de pago
- Rastrear pedido en tiempo real
- Calificar servicio

#### Comercio
- Recibir y gestionar pedidos
- Actualizar estados de preparación
- Asignar repartidores
- Gestionar inventario
- Configurar branding
- Ver reportes de ventas

#### Repartidor
- Activar/desactivar disponibilidad
- Recibir notificaciones de pedidos
- Aceptar/rechazar entregas
- Navegar a puntos de recogida/entrega
- Confirmar entregas
- Ver historial de ganancias

---

## 3. REQUERIMIENTOS FUNCIONALES

### 3.1 RF-001: Autenticación y Autorización
- **Prioridad:** Alta
- **Descripción:** Sistema de login/registro con roles diferenciados
- **Criterios de Aceptación:**
  - Login con email/password
  - Registro con verificación de teléfono
  - Recuperación de contraseña
  - Tokens JWT con expiración
  - Middleware de autorización por rol

### 3.2 RF-002: Multi-tenancy
- **Prioridad:** Alta
- **Descripción:** Aislamiento de datos por comercio
- **Criterios de Aceptación:**
  - Identificación por slug único
  - Queries automáticamente filtradas por comercio_id
  - Imposibilidad de acceso cruzado entre comercios
  - Validación de pertenencia en todas las operaciones

### 3.3 RF-003: Branding Dinámico
- **Prioridad:** Alta
- **Descripción:** Personalización visual por comercio
- **Criterios de Aceptación:**
  - Carga de colores desde DB
  - Logo personalizado
  - Aplicación de tema en toda la PWA
  - Caché de configuración de branding

### 3.4 RF-004: Gestión de Productos
- **Prioridad:** Alta
- **Descripción:** CRUD completo de productos con variantes
- **Criterios de Aceptación:**
  - Crear/editar/eliminar productos
  - Soporte para variantes (tamaño, extras)
  - Control de stock
  - Imágenes de productos
  - Categorización

### 3.5 RF-005: Carrito y Checkout
- **Prioridad:** Alta
- **Descripción:** Proceso de compra completo
- **Criterios de Aceptación:**
  - Agregar/quitar productos del carrito
  - Selección de variantes
  - Cálculo automático de totales
  - Múltiples métodos de pago
  - Validación de dirección de entrega

### 3.6 RF-006: Gestión de Pedidos
- **Prioridad:** Alta
- **Descripción:** Flujo completo de estados de pedido
- **Criterios de Aceptación:**
  - Estados: Pendiente → Confirmado → Preparando → Listo → En Camino → Entregado
  - Notificaciones en cada cambio de estado
  - Historial de cambios
  - Cancelación con validaciones

### 3.7 RF-007: Asignación de Repartidores
- **Prioridad:** Alta
- **Descripción:** Sistema inteligente de asignación
- **Criterios de Aceptación:**
  - Asignación manual a repartidores exclusivos
  - Broadcast a freelancers en radio de 3km
  - Cálculo de distancia por GPS
  - Sistema de aceptación/rechazo

### 3.8 RF-008: Tracking en Tiempo Real
- **Prioridad:** Alta
- **Descripción:** Seguimiento GPS del repartidor
- **Criterios de Aceptación:**
  - Actualización de ubicación cada 10 segundos
  - Visualización en mapa
  - WebSocket para actualizaciones instantáneas
  - Estimación de tiempo de llegada

### 3.9 RF-009: Notificaciones Push
- **Prioridad:** Media
- **Descripción:** Alertas en tiempo real
- **Criterios de Aceptación:**
  - Nuevo pedido (comercio)
  - Pedido disponible (repartidor)
  - Cambio de estado (cliente)
  - Configuración de preferencias

### 3.10 RF-010: Reportes y Analytics
- **Prioridad:** Media
- **Descripción:** Dashboard con métricas
- **Criterios de Aceptación:**
  - Ventas diarias/semanales/mensuales
  - Productos más vendidos
  - Rendimiento de repartidores
  - Exportación a PDF/Excel

---

## 4. REQUERIMIENTOS NO FUNCIONALES

### 4.1 RNF-001: Rendimiento
- Tiempo de respuesta API < 200ms (95th percentile)
- Carga de PWA < 3 segundos (3G)
- Soporte para 1000 usuarios concurrentes
- Actualización GPS cada 10 segundos sin lag

### 4.2 RNF-002: Seguridad
- Encriptación HTTPS/TLS 1.3
- Tokens con expiración de 24 horas
- Validación de entrada en todos los endpoints
- Rate limiting: 60 requests/minuto por IP
- Sanitización de datos SQL injection

### 4.3 RNF-003: Disponibilidad
- Uptime del 99.5%
- Backup automático diario
- Recuperación ante desastres < 4 horas
- Monitoreo 24/7

### 4.4 RNF-004: Escalabilidad
- Arquitectura horizontal escalable
- Cache distribuido con Redis
- Queue para procesos pesados
- CDN para assets estáticos

### 4.5 RNF-005: Usabilidad
- Interfaz intuitiva (< 3 clics para pedido)
- Responsive design (móvil first)
- Accesibilidad WCAG 2.1 AA
- Soporte para español

### 4.6 RNF-006: Compatibilidad
- PWA compatible con Chrome, Firefox, Safari
- App Android 8.0+
- MySQL 8.0+ / MariaDB 10.11+
- PHP 8.3+

---

## 5. RESTRICCIONES Y SUPUESTOS

### 5.1 Restricciones
- Presupuesto limitado para infraestructura cloud
- Equipo de desarrollo de 1-2 personas
- Plazo de 8 semanas para MVP
- Solo Android en Fase 1 (no iOS)

### 5.2 Supuestos
- Los comercios tienen acceso a internet estable
- Los repartidores tienen smartphones Android
- Existe conectividad GPS en zonas de operación
- Los usuarios finales tienen navegadores modernos

### 5.3 Dependencias
- Firebase Cloud Messaging para notificaciones
- Google Maps API para mapas y geocoding
- Servicio de tasa de cambio USD/Bs (BCV o manual)
- Servidor con PHP 8.3 y MySQL/MariaDB

---

## 6. RIESGOS Y MITIGACIÓN

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Problemas de conectividad GPS | Media | Alto | Implementar caché de última ubicación conocida |
| Sobrecarga de WebSockets | Media | Alto | Implementar throttling y reconexión automática |
| Inconsistencia de datos multi-tenant | Baja | Crítico | Testing exhaustivo de scopes y políticas |
| Falta de repartidores disponibles | Alta | Medio | Sistema de incentivos y notificaciones agresivas |
| Cambios frecuentes en tasa USD/Bs | Alta | Medio | Actualización manual diaria + API de respaldo |
| Fraude en pagos móviles | Media | Alto | Validación manual de comprobantes + sistema de reportes |

---

## 7. CRITERIOS DE ÉXITO

### 7.1 Métricas Técnicas
- [ ] 100% de cobertura de tests en lógica crítica
- [ ] Tiempo de respuesta API < 200ms
- [ ] 0 errores críticos en producción
- [ ] Uptime > 99%

### 7.2 Métricas de Negocio
- [ ] 10+ comercios activos en primer mes
- [ ] 100+ pedidos procesados exitosamente
- [ ] Tasa de error en pedidos < 5%
- [ ] Satisfacción de usuarios > 4.0/5.0

### 7.3 Entregables
- [ ] Código fuente completo en GitHub
- [ ] Documentación técnica
- [ ] Manual de usuario
- [ ] Scripts de deployment
- [ ] Base de datos con datos de prueba

---

## 8. CRONOGRAMA GENERAL

**Duración Total:** 8 semanas  
**Inicio:** Abril 2026  
**Fin Estimado:** Mayo 2026  

### Fases
1. **Semanas 1-2:** Setup + Backend Core + Database
2. **Semanas 3-4:** PWA Cliente + API Integration
3. **Semanas 5-6:** Apps Android (Comercio + Repartidor)
4. **Semanas 7-8:** Testing + Deployment + Documentación

---

## 9. APROBACIONES

| Rol | Nombre | Firma | Fecha |
|-----|--------|-------|-------|
| Product Owner | __________ | __________ | __________ |
| Tech Lead | __________ | __________ | __________ |
| Stakeholder | __________ | __________ | __________ |
