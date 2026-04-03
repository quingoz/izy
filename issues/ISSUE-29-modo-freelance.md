# Issue #29: Modo Freelance

**Epic:** App Repartidor  
**Prioridad:** Media  
**Estimación:** 2 días  
**Sprint:** Sprint 4

---

## Descripción

Modo freelance que permite a repartidores trabajar para múltiples comercios y recibir pedidos de cualquier comercio cercano.

## Objetivos

- Toggle modo freelance
- Recibir pedidos de cualquier comercio
- Radio de trabajo configurable
- Historial de comercios atendidos
- Comisiones diferenciadas

## Tareas Técnicas

### 1. Modo Freelance Toggle

```dart
class ConfiguracionScreen extends ConsumerWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(repartidorConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo Freelance'),
            subtitle: const Text('Recibir pedidos de todos los comercios'),
            value: config.isFreelance,
            onChanged: (value) {
              ref.read(repartidorConfigProvider.notifier)
                  .toggleFreelance(value);
            },
          ),
          ListTile(
            title: const Text('Radio de Trabajo'),
            subtitle: Text('${config.radioTrabajo} km'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Mostrar slider para ajustar radio
            },
          ),
        ],
      ),
    );
  }
}
```

## Definición de Hecho (DoD)

- [ ] Toggle freelance funcional
- [ ] Radio de trabajo configurable
- [ ] Pedidos de múltiples comercios
- [ ] Comisiones calculadas correctamente
- [ ] Tests pasando

## Dependencias

- Issue #26: Gestión de Pedidos Disponibles

## Siguiente Issue

Issue #30: Estadísticas y Ganancias
