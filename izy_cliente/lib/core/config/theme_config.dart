import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ThemeConfig {
  ThemeConfig._();
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: IzyColors.primary,
      primary: IzyColors.primary,
      secondary: IzyColors.secondary,
      tertiary: IzyColors.accent,
      error: IzyColors.error,
      surface: IzyColors.white,
      background: IzyColors.greyLight,
    ),
    scaffoldBackgroundColor: IzyColors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: IzyColors.primary,
      foregroundColor: IzyColors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: IzyColors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: IzyColors.primary,
        foregroundColor: IzyColors.white,
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
        foregroundColor: IzyColors.primary,
        side: const BorderSide(color: IzyColors.primary, width: 2),
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
        foregroundColor: IzyColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: IzySpacing.md,
          vertical: IzySpacing.sm,
        ),
      ),
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
        borderSide: const BorderSide(color: IzyColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IzyRadius.md),
        borderSide: const BorderSide(color: IzyColors.error),
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
      color: IzyColors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: IzyColors.greyLight,
      selectedColor: IzyColors.secondary,
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
    iconTheme: const IconThemeData(
      color: IzyColors.primary,
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
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: IzyColors.primary,
      brightness: Brightness.dark,
      primary: IzyColors.secondary,
      secondary: IzyColors.primary,
      tertiary: IzyColors.accent,
      error: IzyColors.error,
      surface: IzyColors.darkBlue,
    ),
    scaffoldBackgroundColor: IzyColors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: IzyColors.darkBlue,
      foregroundColor: IzyColors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: IzyColors.white),
    ),
  );
}
