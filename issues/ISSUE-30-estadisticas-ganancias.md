# Issue #30: Estadísticas y Ganancias

**Epic:** App Repartidor  
**Prioridad:** Media  
**Estimación:** 2 días  
**Sprint:** Sprint 4

---

## Descripción

Dashboard de estadísticas con ganancias diarias, semanales, mensuales y métricas de desempeño.

## Objetivos

- Ganancias por período
- Entregas completadas
- Rating promedio
- Gráficas de rendimiento
- Historial de pagos

## Tareas Técnicas

### 1. Estadísticas Screen

```dart
class EstadisticasScreen extends ConsumerWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(estadisticasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Estadísticas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGananciasCard(stats),
            const SizedBox(height: 16),
            _buildEntregasCard(stats),
            const SizedBox(height: 16),
            _buildRatingCard(stats),
            const SizedBox(height: 16),
            _buildGrafica(stats),
          ],
        ),
      ),
    );
  }

  Widget _buildGananciasCard(Estadisticas stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Ganancias', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGananciaItem('Hoy', stats.gananciasHoy),
                _buildGananciaItem('Semana', stats.gananciasSemana),
                _buildGananciaItem('Mes', stats.gananciasMes),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGananciaItem(String label, double monto) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '\$${monto.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
```

## Definición de Hecho (DoD)

- [ ] Ganancias por período mostradas
- [ ] Entregas completadas visibles
- [ ] Rating promedio calculado
- [ ] Gráficas implementadas
- [ ] Historial de pagos
- [ ] Tests pasando

## Dependencias

- Issue #27: Navegación y Entrega

## Siguiente Issue

Issue #31: Tests End-to-End
