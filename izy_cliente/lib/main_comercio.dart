import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';
import 'features/comercio/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('auth');
  
  AppConfig.setFlavor(AppFlavor.comercio);
  AppConfig.initialize();
  
  runApp(
    const ProviderScope(
      child: IzyComercioApp(),
    ),
  );
}

class IzyComercioApp extends StatelessWidget {
  const IzyComercioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IZY Comercio',
      theme: ThemeConfig.lightTheme,
      home: const ComercioHomeScreen(),
    );
  }
}
