import 'package:flutter/material.dart';

class IzyColors {
  IzyColors._();
  
  static const Color primary = Color(0xFF1B3A57);
  static const Color secondary = Color(0xFF5FD4A0);
  static const Color accent = Color(0xFF4CAF50);
  static const Color highlight = Color(0xFF50CF79);
  
  static const Color darkBlue = Color(0xFF0B2856);
  static const Color black = Color(0xFF000104);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyMedium = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF424242);
  static const Color textPrimary = Color(0xFF212121);
}

class IzyAssets {
  IzyAssets._();
  
  static const String logoSvg = 'assets/images/logo-izy.svg';
  static const String iconPng = 'assets/icons/icon-izy.png';
}

class IzySpacing {
  IzySpacing._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

class IzyRadius {
  IzyRadius._();
  
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double round = 999.0;
}

class IzyTextStyles {
  IzyTextStyles._();
  
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: IzyColors.primary,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: IzyColors.primary,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: IzyColors.primary,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: IzyColors.darkBlue,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: IzyColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: IzyColors.greyMedium,
  );
  
  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: IzyColors.greyMedium,
  );
}
