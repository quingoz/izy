import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/app_config.dart';
import 'shared/providers/theme_provider.dart';
import 'features/carrito/data/models/carrito_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(CarritoItemAdapter());
  Hive.registerAdapter(VarianteSeleccionadaAdapter());
  
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
