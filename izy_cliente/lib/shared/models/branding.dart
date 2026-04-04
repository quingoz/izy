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

  Map<String, dynamic> toJson() {
    return {
      'colors': {
        'primary': '#${colors.primary.value.toRadixString(16).substring(2)}',
        'secondary': '#${colors.secondary.value.toRadixString(16).substring(2)}',
        'accent': '#${colors.accent.value.toRadixString(16).substring(2)}',
        'background': '#${colors.background.value.toRadixString(16).substring(2)}',
        'surface': '#${colors.surface.value.toRadixString(16).substring(2)}',
        'error': '#${colors.error.value.toRadixString(16).substring(2)}',
      },
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'theme': theme,
    };
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
      surface: surface,
      onSurface: Colors.black87,
    );
  }
}
