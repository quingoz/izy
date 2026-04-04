# IZY Comercio - App Android Flutter

## Configuración Completada ✅

### Issue #19: Setup App Android Comercio (Flutter Flavor)

Se ha configurado exitosamente el flavor "comercio" para la aplicación Android de gestión de pedidos.

## Estructura del Proyecto

```
lib/
├── main_comercio.dart                    # Entry point para flavor comercio
├── core/
│   └── config/
│       ├── app_config.dart              # Configuración con soporte para flavors
│       └── theme_config.dart            # Tema con colores IZY
└── features/
    └── comercio/
        ├── data/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   └── entities/
        └── presentation/
            ├── providers/
            ├── screens/
            │   ├── home_screen.dart         # Pantalla principal con navegación
            │   ├── pedidos_screen.dart      # Gestión de pedidos
            │   ├── productos_screen.dart    # Gestión de productos
            │   └── estadisticas_screen.dart # Dashboard de estadísticas
            └── widgets/
```

## Configuración de Flavors

### Android (build.gradle.kts)

Se configuraron dos flavors:
- **comercio**: App para comercios (gestión de pedidos)
- **repartidor**: App para repartidores (entrega de pedidos)

```kotlin
productFlavors {
    create("comercio") {
        dimension = "app"
        applicationIdSuffix = ".comercio"
        versionNameSuffix = "-comercio"
        resValue("string", "app_name", "IZY Comercio")
    }
}
```

## Comandos de Ejecución

### Desarrollo
```bash
flutter run --flavor comercio
```

### Build APK Debug
```bash
flutter build apk --flavor comercio --debug
```

### Build APK Release
```bash
flutter build apk --flavor comercio --release
```

## Pantallas Implementadas

### 1. Home Screen
- Navegación principal con 3 secciones
- Bottom navigation bar
- AppBar con notificaciones y configuración

### 2. Pedidos Screen
- Tarjetas de estado (Pendientes, En Proceso, Completados)
- Lista de pedidos recientes
- FAB para agregar nuevo pedido

### 3. Productos Screen
- Barra de búsqueda
- Filtros por categoría (chips)
- Lista de productos con switch de disponibilidad
- FAB para agregar nuevo producto

### 4. Estadísticas Screen
- Selector de período (Hoy, Semana, Mes)
- Card de ingresos con tendencia
- Métricas de pedidos y ticket promedio
- Top 5 productos más vendidos

## Características

✅ Flavor comercio configurado  
✅ App ejecuta en Android  
✅ Tema IZY aplicado correctamente  
✅ Estructura de carpetas creada  
✅ Pantallas básicas implementadas  
✅ Navegación funcional  
✅ UI moderna con Material 3  

## Requisitos Previos

Para ejecutar la aplicación necesitas:

1. **Flutter SDK** instalado
2. **Android SDK** configurado
3. Variable de entorno `ANDROID_HOME` configurada
4. Dispositivo Android o emulador

## Próximos Pasos

- Issue #20: Dashboard de Comercio (funcionalidad completa)
- Configurar Firebase para el flavor comercio
- Implementar lógica de negocio en providers
- Conectar con backend API

## Notas Técnicas

- **AppConfig**: Soporta múltiples flavors (cliente, comercio, repartidor)
- **ThemeConfig**: Utiliza colores IZY definidos en `app_constants.dart`
- **Arquitectura**: Clean Architecture con separación de capas
- **State Management**: Flutter Riverpod
