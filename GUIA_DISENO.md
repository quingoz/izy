# 🎨 Guía de Diseño IZY Delivery

> **Documento de referencia para mantener consistencia visual en todo el proyecto**

---

## 📋 Índice

1. [Identidad Visual](#identidad-visual)
2. [Paleta de Colores](#paleta-de-colores)
3. [Tipografía](#tipografía)
4. [Logos y Assets](#logos-y-assets)
5. [Componentes UI](#componentes-ui)
6. [Espaciado y Grid](#espaciado-y-grid)
7. [Iconografía](#iconografía)
8. [Ejemplos de Uso](#ejemplos-de-uso)

---

## 🎯 Identidad Visual

### Concepto
IZY es una plataforma de delivery moderna, confiable y eficiente. El diseño debe transmitir:
- **Profesionalismo**: Colores corporativos sólidos
- **Velocidad**: Elementos dinámicos y fluidos
- **Confianza**: Interfaz clara y accesible
- **Modernidad**: UI limpia con Material Design 3

---

## 🎨 Paleta de Colores

### Colores Primarios

#### Azul Oscuro (Primary)
```
HEX: #1B3A57
RGB: rgb(27, 58, 87)
HSL: hsl(207, 53%, 22%)
Uso: Encabezados, botones principales, navegación
```

#### Verde Mint (Secondary)
```
HEX: #5FD4A0
RGB: rgb(95, 212, 160)
HSL: hsl(153, 59%, 60%)
Uso: Acentos, estados activos, confirmaciones
```

#### Verde Brillante (Accent)
```
HEX: #4CAF50
RGB: rgb(76, 175, 80)
HSL: hsl(122, 39%, 49%)
Uso: Botones de acción, éxito, disponibilidad
```

#### Verde Delivery (Highlight)
```
HEX: #50CF79
RGB: rgb(80, 207, 121)
HSL: hsl(139, 57%, 56%)
Uso: Tracking en tiempo real, repartidores activos
```

### Colores Secundarios

#### Azul Profundo (Dark)
```
HEX: #0B2856
RGB: rgb(11, 40, 86)
HSL: hsl(215, 77%, 19%)
Uso: Textos importantes, fondos oscuros
```

#### Negro Suave
```
HEX: #000104
RGB: rgb(0, 1, 4)
HSL: hsl(225, 100%, 1%)
Uso: Textos principales, iconos
```

### Colores de Estado

#### Éxito
```
HEX: #4CAF50
Uso: Pedido entregado, pago confirmado
```

#### Advertencia
```
HEX: #FF9800
RGB: rgb(255, 152, 0)
Uso: Pedido pendiente, tiempo de espera
```

#### Error
```
HEX: #F44336
RGB: rgb(244, 67, 54)
Uso: Pedido cancelado, error de pago
```

#### Información
```
HEX: #2196F3
RGB: rgb(33, 150, 243)
Uso: Notificaciones, tooltips
```

### Colores Neutros

```
Blanco: #FFFFFF
Gris Claro: #F5F5F5
Gris Medio: #9E9E9E
Gris Oscuro: #424242
Negro: #212121
```

---

## 🔤 Tipografía

### Fuente Principal
**Roboto** (Material Design)

#### Jerarquía de Texto

```
H1: 32px / Bold / #1B3A57
H2: 24px / Bold / #1B3A57
H3: 20px / SemiBold / #1B3A57
H4: 18px / Medium / #0B2856
Body: 16px / Regular / #212121
Caption: 14px / Regular / #9E9E9E
Small: 12px / Regular / #9E9E9E
```

### Pesos Disponibles
- Light (300)
- Regular (400)
- Medium (500)
- SemiBold (600)
- Bold (700)

---

## 🖼️ Logos y Assets

### Logo Principal

**Ubicación:** `docs/logo-izy.svg`

**Características:**
- Formato: SVG vectorial
- Colores: Azul oscuro (#0B2856) + Verde (#50CF79)
- Dimensiones originales: 2048x876px
- Proporción: 2.34:1

**Usos:**
- Landing page
- Header de aplicaciones
- Emails y comunicaciones
- Documentación

**Variantes:**
```
- Logo completo: Para headers y presentaciones
- Logo horizontal: Para navegación web
- Logo vertical: Para apps móviles
```

### Icono/Favicon

**Ubicación:** `docs/icon-izy.png`

**Características:**
- Formato: PNG con transparencia
- Diseño: Pin de ubicación con nodos conectados
- Colores: Azul oscuro + Verde mint
- Concepto: Delivery + Conexión + Ubicación

**Usos:**
- Favicon web (16x16, 32x32, 64x64)
- App icons (192x192, 512x512)
- PWA manifest icons
- Notificaciones push

**Tamaños Requeridos:**
```
16x16   - Favicon navegador
32x32   - Favicon retina
64x64   - Favicon alta resolución
192x192 - PWA icon
512x512 - PWA icon maskable
```

### Ubicación en Proyectos

#### Backend Laravel
```
public/images/logo-izy.svg
public/images/icon-izy.png
```

#### Frontend Flutter
```
assets/images/logo-izy.svg
assets/icons/icon-izy.png
web/icons/Icon-192.png
web/icons/Icon-512.png
web/favicon.png
```

---

## 🧩 Componentes UI

### Botones

#### Primario
```dart
backgroundColor: #1B3A57
foregroundColor: #FFFFFF
padding: 16px 32px
borderRadius: 12px
elevation: 2
```

#### Secundario
```dart
backgroundColor: #5FD4A0
foregroundColor: #FFFFFF
padding: 16px 32px
borderRadius: 12px
elevation: 1
```

#### Outline
```dart
borderColor: #1B3A57
foregroundColor: #1B3A57
padding: 16px 32px
borderRadius: 12px
borderWidth: 2px
```

### Cards

```dart
backgroundColor: #FFFFFF
borderRadius: 16px
elevation: 2
padding: 16px
shadow: 0 2px 8px rgba(0,0,0,0.1)
```

### Inputs

```dart
borderRadius: 12px
borderColor: #E0E0E0
fillColor: #F5F5F5
focusBorderColor: #1B3A57
padding: 16px
```

### AppBar

```dart
backgroundColor: #1B3A57
foregroundColor: #FFFFFF
elevation: 0
height: 56px
```

---

## 📐 Espaciado y Grid

### Sistema de Espaciado (8px base)

```
xs:  4px  (0.5 unidades)
sm:  8px  (1 unidad)
md:  16px (2 unidades)
lg:  24px (3 unidades)
xl:  32px (4 unidades)
2xl: 48px (6 unidades)
3xl: 64px (8 unidades)
```

### Márgenes de Contenido

```
Mobile:  16px laterales
Tablet:  24px laterales
Desktop: 32px laterales
```

### Grid System

```
Mobile:  4 columnas
Tablet:  8 columnas
Desktop: 12 columnas
Gutter:  16px
```

---

## 🎯 Iconografía

### Librería
**Material Icons** (Google)

### Tamaños Estándar
```
Small:  16px
Medium: 24px
Large:  32px
XLarge: 48px
```

### Colores de Iconos
```
Primario: #1B3A57
Secundario: #5FD4A0
Deshabilitado: #9E9E9E
Sobre oscuro: #FFFFFF
```

### Iconos Principales del Sistema

```
🏪 Comercio: store
📦 Pedido: shopping_bag
🛵 Repartidor: delivery_dining
📍 Ubicación: location_on
⏱️ Tiempo: schedule
💳 Pago: payment
✓ Confirmado: check_circle
⚠️ Pendiente: pending
❌ Cancelado: cancel
🔔 Notificación: notifications
```

---

## 💡 Ejemplos de Uso

### Header de Aplicación

```dart
AppBar(
  backgroundColor: Color(0xFF1B3A57),
  title: Image.asset('assets/images/logo-izy.svg', height: 32),
  actions: [
    IconButton(
      icon: Icon(Icons.notifications, color: Colors.white),
      onPressed: () {},
    ),
  ],
)
```

### Botón de Acción Principal

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF1B3A57),
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  onPressed: () {},
  child: Text('Realizar Pedido'),
)
```

### Card de Producto

```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        // Imagen del producto
        // Nombre con color primario
        Text(
          'Producto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3A57),
          ),
        ),
        // Precio con color accent
        Text(
          '\$10.00',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
          ),
        ),
      ],
    ),
  ),
)
```

### Estado de Pedido

```dart
// En camino
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: Color(0xFF50CF79).withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Color(0xFF50CF79)),
  ),
  child: Row(
    children: [
      Icon(Icons.delivery_dining, color: Color(0xFF50CF79), size: 16),
      SizedBox(width: 4),
      Text(
        'En camino',
        style: TextStyle(
          color: Color(0xFF50CF79),
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
)
```

---

## 🎨 Paleta Completa en Código

### Flutter (Dart)

```dart
class IzyColors {
  // Primarios
  static const Color primary = Color(0xFF1B3A57);
  static const Color secondary = Color(0xFF5FD4A0);
  static const Color accent = Color(0xFF4CAF50);
  static const Color highlight = Color(0xFF50CF79);
  
  // Oscuros
  static const Color darkBlue = Color(0xFF0B2856);
  static const Color black = Color(0xFF000104);
  
  // Estados
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFF FF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Neutros
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyMedium = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF424242);
  static const Color textPrimary = Color(0xFF212121);
}
```

### CSS/SCSS

```css
:root {
  /* Primarios */
  --color-primary: #1B3A57;
  --color-secondary: #5FD4A0;
  --color-accent: #4CAF50;
  --color-highlight: #50CF79;
  
  /* Oscuros */
  --color-dark-blue: #0B2856;
  --color-black: #000104;
  
  /* Estados */
  --color-success: #4CAF50;
  --color-warning: #FF9800;
  --color-error: #F44336;
  --color-info: #2196F3;
  
  /* Neutros */
  --color-white: #FFFFFF;
  --color-grey-light: #F5F5F5;
  --color-grey-medium: #9E9E9E;
  --color-grey-dark: #424242;
  --color-text-primary: #212121;
}
```

---

## 📱 Responsive Design

### Breakpoints

```
Mobile:  < 600px
Tablet:  600px - 1024px
Desktop: > 1024px
```

### Adaptaciones por Dispositivo

#### Mobile
- Logo: Icono solo (40x40px)
- Navegación: Bottom navigation bar
- Cards: Ancho completo con margen 16px
- Botones: Ancho completo

#### Tablet
- Logo: Horizontal (120px ancho)
- Navegación: Drawer lateral
- Cards: 2 columnas
- Botones: Ancho automático

#### Desktop
- Logo: Completo (200px ancho)
- Navegación: Top bar horizontal
- Cards: 3-4 columnas
- Botones: Ancho automático

---

## ✅ Checklist de Implementación

Al implementar nuevas pantallas o componentes, verificar:

- [ ] Usa colores de la paleta oficial
- [ ] Logo IZY visible en header
- [ ] Favicon configurado
- [ ] Tipografía Roboto aplicada
- [ ] Espaciado consistente (sistema 8px)
- [ ] Botones con border-radius 12px
- [ ] Cards con elevation y border-radius
- [ ] Iconos Material Icons
- [ ] Estados visuales claros (hover, active, disabled)
- [ ] Responsive en mobile, tablet y desktop
- [ ] Accesibilidad (contraste mínimo 4.5:1)
- [ ] Dark mode compatible (si aplica)

---

## 🔄 Actualizaciones

**Versión:** 1.0.0  
**Última actualización:** Abril 2026  
**Mantenido por:** Equipo IZY Delivery

---

## 📞 Contacto

Para consultas sobre diseño o solicitudes de assets:
- Revisar esta guía primero
- Consultar con el equipo de diseño
- Mantener consistencia visual en todo el proyecto

---

**Nota Importante:** Esta guía debe ser la referencia principal para cualquier decisión de diseño en el proyecto IZY. Todos los componentes, pantallas y elementos visuales deben seguir estas especificaciones para mantener la coherencia de la marca.
