import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'branding_provider.dart';
import '../../core/constants/app_constants.dart';

final themeProvider = Provider<ThemeData>((ref) {
  final brandingState = ref.watch(brandingProvider);
  final branding = brandingState.branding;

  return ThemeData(
    useMaterial3: true,
    colorScheme: branding.colors.toColorScheme(),
    scaffoldBackgroundColor: branding.colors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: branding.colors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: branding.colors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: IzySpacing.xl,
          vertical: IzySpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IzyRadius.md),
        ),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: branding.colors.primary,
        side: BorderSide(color: branding.colors.primary, width: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: IzySpacing.xl,
          vertical: IzySpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IzyRadius.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: branding.colors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: IzySpacing.md,
          vertical: IzySpacing.sm,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: branding.colors.accent,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IzyRadius.md),
        borderSide: const BorderSide(color: IzyColors.greyMedium),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IzyRadius.md),
        borderSide: const BorderSide(color: IzyColors.greyMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IzyRadius.md),
        borderSide: BorderSide(color: branding.colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IzyRadius.md),
        borderSide: BorderSide(color: branding.colors.error),
      ),
      filled: true,
      fillColor: IzyColors.greyLight,
      contentPadding: const EdgeInsets.all(IzySpacing.md),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IzyRadius.lg),
      ),
      color: branding.colors.surface,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: IzyColors.greyLight,
      selectedColor: branding.colors.secondary,
      labelStyle: IzyTextStyles.caption,
      padding: const EdgeInsets.symmetric(
        horizontal: IzySpacing.md,
        vertical: IzySpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IzyRadius.md),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: IzyColors.greyLight,
      thickness: 1,
      space: IzySpacing.md,
    ),
    iconTheme: IconThemeData(
      color: branding.colors.primary,
      size: 24,
    ),
    textTheme: const TextTheme(
      displayLarge: IzyTextStyles.h1,
      displayMedium: IzyTextStyles.h2,
      displaySmall: IzyTextStyles.h3,
      headlineMedium: IzyTextStyles.h4,
      bodyLarge: IzyTextStyles.body,
      bodyMedium: IzyTextStyles.caption,
      bodySmall: IzyTextStyles.small,
    ),
  );
});
