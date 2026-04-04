import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/repartidor.dart';

final repartidoresProvider = StateNotifierProvider<RepartidoresNotifier, RepartidoresState>((ref) {
  return RepartidoresNotifier();
});

class RepartidoresState {
  final List<Repartidor> repartidores;
  final List<Repartidor> disponibles;
  final bool isLoading;
  final String? error;

  RepartidoresState({
    this.repartidores = const [],
    this.disponibles = const [],
    this.isLoading = false,
    this.error,
  });

  RepartidoresState copyWith({
    List<Repartidor>? repartidores,
    List<Repartidor>? disponibles,
    bool? isLoading,
    String? error,
  }) {
    return RepartidoresState(
      repartidores: repartidores ?? this.repartidores,
      disponibles: disponibles ?? this.disponibles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RepartidoresNotifier extends StateNotifier<RepartidoresState> {
  RepartidoresNotifier() : super(RepartidoresState()) {
    loadRepartidores();
  }

  Future<void> loadRepartidores() async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final repartidores = _generarRepartidoresMock();
      final disponibles = repartidores.where((r) => r.disponible).toList();

      state = state.copyWith(
        repartidores: repartidores,
        disponibles: disponibles,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> solicitarFreelancers() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      await loadRepartidores();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() => loadRepartidores();

  List<Repartidor> _generarRepartidoresMock() {
    return [
      Repartidor(
        id: '1',
        nombre: 'Carlos Méndez',
        telefono: '+58 412-1234567',
        disponible: true,
        esExclusivo: true,
        latitud: 10.4806,
        longitud: -66.9036,
        pedidosCompletados: 145,
        calificacion: 4.8,
        vehiculo: 'Moto',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      Repartidor(
        id: '2',
        nombre: 'Ana Rodríguez',
        telefono: '+58 424-7654321',
        disponible: true,
        esExclusivo: true,
        latitud: 10.4850,
        longitud: -66.9100,
        pedidosCompletados: 98,
        calificacion: 4.9,
        vehiculo: 'Bicicleta',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      Repartidor(
        id: '3',
        nombre: 'Luis Fernández',
        telefono: '+58 414-9876543',
        disponible: false,
        esExclusivo: true,
        latitud: 10.4900,
        longitud: -66.8950,
        pedidosCompletados: 203,
        calificacion: 5.0,
        vehiculo: 'Moto',
        createdAt: DateTime.now().subtract(const Duration(days: 240)),
      ),
      Repartidor(
        id: '4',
        nombre: 'María González',
        telefono: '+58 426-5551234',
        disponible: true,
        esExclusivo: false,
        latitud: 10.4750,
        longitud: -66.9150,
        pedidosCompletados: 45,
        calificacion: 4.6,
        vehiculo: 'Moto',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Repartidor(
        id: '5',
        nombre: 'Pedro Martínez',
        telefono: '+58 412-8889999',
        disponible: true,
        esExclusivo: false,
        latitud: 10.4820,
        longitud: -66.9080,
        pedidosCompletados: 67,
        calificacion: 4.7,
        vehiculo: 'Bicicleta',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];
  }
}
