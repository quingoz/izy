# 📁 Assets IZY Cliente

Este directorio contiene todos los recursos estáticos del proyecto IZY Cliente.

## 📂 Estructura

```
assets/
├── images/
│   └── logo-izy.svg          # Logo principal IZY (SVG vectorial)
├── icons/
│   └── icon-izy.png          # Icono/favicon IZY (PNG)
└── README.md                 # Este archivo
```

## 🖼️ Imágenes

### Logo Principal (`images/logo-izy.svg`)

**Descripción:** Logo completo de IZY Delivery  
**Formato:** SVG vectorial  
**Colores:** Azul oscuro (#0B2856) + Verde (#50CF79)  
**Dimensiones originales:** 2048x876px  
**Proporción:** 2.34:1

**Uso en código:**
```dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:izy_cliente/core/constants/app_constants.dart';

// En AppBar
SvgPicture.asset(
  IzyAssets.logoSvg,
  height: 32,
  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
)

// En pantalla de inicio
SvgPicture.asset(
  IzyAssets.logoSvg,
  width: 200,
)
```

## 🎯 Iconos

### Icono Principal (`icons/icon-izy.png`)

**Descripción:** Icono de la aplicación (pin de ubicación con nodos)  
**Formato:** PNG con transparencia  
**Colores:** Azul oscuro + Verde mint  
**Concepto:** Delivery + Conexión + Ubicación

**Uso en código:**
```dart
import 'package:izy_cliente/core/constants/app_constants.dart';

Image.asset(
  IzyAssets.iconPng,
  width: 48,
  height: 48,
)
```

## 📱 Iconos PWA

Los iconos para PWA están ubicados en `web/icons/`:

- `Icon-192.png` - Icono PWA estándar (192x192)
- `Icon-512.png` - Icono PWA grande (512x512)
- `Icon-maskable-192.png` - Icono maskable (192x192)
- `Icon-maskable-512.png` - Icono maskable (512x512)

**Nota:** Estos deben ser generados a partir de `icon-izy.png` en los tamaños correspondientes.

## 🎨 Guía de Diseño

Para más información sobre colores, tipografía y uso de assets, consulta:
- **Guía de Diseño:** `/GUIA_DISENO.md` (raíz del proyecto)
- **Constantes de Diseño:** `lib/core/constants/app_constants.dart`
- **Configuración de Tema:** `lib/core/config/theme_config.dart`

## ✅ Checklist de Assets

Al agregar nuevos assets:

- [ ] Optimizar imágenes (compresión sin pérdida de calidad)
- [ ] Usar formatos apropiados (SVG para logos, PNG para iconos, WebP para fotos)
- [ ] Agregar referencia en `IzyAssets` (`app_constants.dart`)
- [ ] Documentar en este README
- [ ] Verificar que cargue correctamente en la app
- [ ] Probar en diferentes tamaños de pantalla

## 📏 Tamaños Recomendados

### Logos
- Header móvil: 120px ancho
- Header tablet: 150px ancho
- Header desktop: 200px ancho
- Splash screen: 300px ancho

### Iconos
- Pequeño: 24x24px
- Mediano: 48x48px
- Grande: 96x96px

### Imágenes de Productos
- Thumbnail: 100x100px
- Tarjeta: 300x300px
- Detalle: 600x600px

## 🔄 Actualización de Assets

Para actualizar el logo o icono:

1. Reemplazar archivo en la carpeta correspondiente
2. Mantener mismo nombre de archivo
3. Verificar que las dimensiones sean apropiadas
4. Ejecutar `flutter pub get` si es necesario
5. Hacer hot reload/restart de la app

## 📞 Soporte

Para consultas sobre assets o diseño, revisar primero:
1. Este README
2. `/GUIA_DISENO.md`
3. Documentación de Flutter sobre assets

---

**Última actualización:** Abril 2026
