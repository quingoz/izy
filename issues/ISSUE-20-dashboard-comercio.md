# Issue #20: Dashboard de Comercio

**Epic:** App Comercio  
**Prioridad:** Alta  
**Estimación:** 2 días  
**Sprint:** Sprint 3

---

## Descripción

Implementar dashboard principal del comercio con estadísticas, pedidos activos y accesos rápidos.

## Objetivos

- Vista general de estadísticas
- Pedidos activos en tiempo real
- Gráficas de ventas
- Accesos rápidos
- Notificaciones push

## Tareas Técnicas

### 1. Dashboard Screen

**Archivo:** `lib/features/comercio/presentation/screens/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/estadisticas_card.dart';
import '../widgets/pedidos_activos_list.dart';
import '../widgets/accesos_rapidos.dart';

class ComercioHomeScreen extends ConsumerWidget {
  const ComercioHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IZY Comercio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Ver notificaciones
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EstadisticasCard(stats: dashboardState.estadisticas),
              const SizedBox(height: 24),
              const AccesosRapidos(),
              const SizedBox(height: 24),
              Text(
                'Pedidos Activos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              PedidosActivosList(pedidos: dashboardState.pedidosActivos),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
```

### 2. Dashboard Provider

**Archivo:** `lib/features/comercio/presentation/providers/dashboard_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/comercio_repository.dart';

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

class DashboardState {
  final Estadisticas? estadisticas;
  final List<PedidoActivo> pedidosActivos;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.estadisticas,
    this.pedidosActivos = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    Estadisticas? estadisticas,
    List<PedidoActivo>? pedidosActivos,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      estadisticas: estadisticas ?? this.estadisticas,
      pedidosActivos: pedidosActivos ?? this.pedidosActivos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ComercioRepository _repository = ComercioRepository();

  DashboardNotifier() : super(DashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);

    try {
      final stats = await _repository.getEstadisticas();
      final pedidos = await _repository.getPedidosActivos();

      state = state.copyWith(
        estadisticas: stats,
        pedidosActivos: pedidos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => loadDashboard();
}
```

## Definición de Hecho (DoD)

- [ ] Dashboard muestra estadísticas
- [ ] Pedidos activos en tiempo real
- [ ] Refresh funcional
- [ ] Navegación bottom bar
- [ ] Notificaciones configuradas
- [ ] Tests pasando

## Comandos de Verificación

```bash
flutter test
flutter run --flavor comercio
```

## Dependencias

- Issue #19: Setup App Android Comercio

## Siguiente Issue

Issue #21: Kitchen Flow (Gestión de Estados)
