# Issue #14: Sistema de Branding Dinámico

**Epic:** PWA Cliente  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 2

---

## Descripción

Implementar sistema de branding dinámico que adapta colores, logo y tema según el comercio seleccionado.

## Objetivos

- Cargar branding desde API
- Aplicar colores dinámicamente
- Cambiar logo y banner
- Persistir tema seleccionado
- Transiciones suaves

## Tareas Técnicas

### 1. Branding Model

**Archivo:** `lib/shared/models/branding.dart`

```dart
import 'package:flutter/material.dart';

class Branding {
  final BrandingColors colors;
  final String? logoUrl;
  final String? bannerUrl;
  final String theme;

  Branding({
    required this.colors,
    this.logoUrl,
    this.bannerUrl,
    this.theme = 'light',
  });

  factory Branding.fromJson(Map<String, dynamic> json) {
    return Branding(
      colors: BrandingColors.fromJson(json['colors'] ?? {}),
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
      theme: json['theme'] ?? 'light',
    );
  }

  factory Branding.defaultBranding() {
    return Branding(
      colors: BrandingColors.defaultColors(),
      theme: 'light',
    );
  }
}

class BrandingColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color error;

  BrandingColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.error,
  });

  factory BrandingColors.fromJson(Map<String, dynamic> json) {
    return BrandingColors(
      primary: _parseColor(json['primary']) ?? const Color(0xFF1B3A57),
      secondary: _parseColor(json['secondary']) ?? const Color(0xFF5FD4A0),
      accent: _parseColor(json['accent']) ?? const Color(0xFF4CAF50),
      background: _parseColor(json['background']) ?? Colors.white,
      surface: _parseColor(json['surface']) ?? Colors.white,
      error: _parseColor(json['error']) ?? Colors.red,
    );
  }

  factory BrandingColors.defaultColors() {
    return BrandingColors(
      primary: const Color(0xFF1B3A57),
      secondary: const Color(0xFF5FD4A0),
      accent: const Color(0xFF4CAF50),
      background: Colors.white,
      surface: Colors.white,
      error: Colors.red,
    );
  }

  static Color? _parseColor(String? hexColor) {
    if (hexColor == null) return null;
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  ColorScheme toColorScheme({Brightness brightness = Brightness.light}) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      tertiary: accent,
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      background: background,
      onBackground: Colors.black87,
      surface: surface,
      onSurface: Colors.black87,
    );
  }
}
```

### 2. Branding Provider

**Archivo:** `lib/shared/providers/branding_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/branding.dart';
import '../../core/network/api_service.dart';

final brandingProvider = StateNotifierProvider<BrandingNotifier, BrandingState>((ref) {
  return BrandingNotifier();
});

class BrandingState {
  final Branding branding;
  final bool isLoading;
  final String? error;

  BrandingState({
    required this.branding,
    this.isLoading = false,
    this.error,
  });

  BrandingState copyWith({
    Branding? branding,
    bool? isLoading,
    String? error,
  }) {
    return BrandingState(
      branding: branding ?? this.branding,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BrandingNotifier extends StateNotifier<BrandingState> {
  final ApiService _api = ApiService();

  BrandingNotifier() : super(BrandingState(branding: Branding.defaultBranding())) {
    _loadSavedBranding();
  }

  Future<void> _loadSavedBranding() async {
    final box = await Hive.openBox('branding');
    final savedBranding = box.get('current_branding');

    if (savedBranding != null) {
      state = state.copyWith(
        branding: Branding.fromJson(savedBranding),
      );
    }
  }

  Future<void> loadBrandingForComercio(String slug) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.get('/comercios/$slug/branding');
      final branding = Branding.fromJson(response['data']);

      final box = await Hive.openBox('branding');
      await box.put('current_branding', response['data']);

      state = state.copyWith(
        branding: branding,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void resetToDefault() {
    state = state.copyWith(branding: Branding.defaultBranding());
  }
}
```

### 3. Dynamic Theme Provider

**Archivo:** `lib/shared/providers/theme_provider.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'branding_provider.dart';

final themeProvider = Provider<ThemeData>((ref) {
  final brandingState = ref.watch(brandingProvider);
  final branding = brandingState.branding;

  return ThemeData(
    useMaterial3: true,
    colorScheme: branding.colors.toColorScheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: branding.colors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: branding.colors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: branding.colors.accent,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: branding.colors.primary, width: 2),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
});
```

### 4. Actualizar Main

**Archivo:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/app_config.dart';
import 'shared/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('auth');
  await Hive.openBox('branding');
  
  AppConfig.initialize();
  
  runApp(
    const ProviderScope(
      child: IzyClienteApp(),
    ),
  );
}

class IzyClienteApp extends ConsumerWidget {
  const IzyClienteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: AppConfig.appName,
      theme: theme,
      home: const Scaffold(
        body: Center(
          child: Text('IZY Cliente - Branding Dinámico'),
        ),
      ),
    );
  }
}
```

### 5. Branding Widget

**Archivo:** `lib/shared/widgets/branded_logo.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/branding_provider.dart';

class BrandedLogo extends ConsumerWidget {
  final double height;
  final double width;

  const BrandedLogo({
    super.key,
    this.height = 60,
    this.width = 120,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandingState = ref.watch(brandingProvider);
    final logoUrl = brandingState.branding.logoUrl;

    if (logoUrl == null) {
      return Image.asset(
        'assets/images/logo.png',
        height: height,
        width: width,
      );
    }

    return CachedNetworkImage(
      imageUrl: logoUrl,
      height: height,
      width: width,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/logo.png',
        height: height,
        width: width,
      ),
    );
  }
}
```

## Definición de Hecho (DoD)

- [ ] Branding se carga desde API
- [ ] Colores se aplican dinámicamente
- [ ] Logo cambia según comercio
- [ ] Tema persiste en storage
- [ ] Transiciones suaves
- [ ] Fallback a branding por defecto
- [ ] Tests pasando

## Comandos de Verificación

```bash
flutter test
flutter run -d chrome
```

## Dependencias

- Issue #13: Cliente HTTP y State Management

## Siguiente Issue

Issue #15: Catálogo de Productos
