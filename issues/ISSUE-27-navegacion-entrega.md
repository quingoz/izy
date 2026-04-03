# Issue #27: Navegación y Entrega

**Epic:** App Repartidor  
**Prioridad:** Alta  
**Estimación:** 3 días  
**Sprint:** Sprint 4

---

## Descripción

Flujo completo de navegación desde comercio hasta cliente con confirmación de recogida y entrega.

## Objetivos

- Navegación a comercio
- Confirmar recogida
- Navegación a cliente
- Confirmar entrega
- Integración con Google Maps
- Llamar al cliente

## Tareas Técnicas

### 1. Navegación Screen

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NavegacionScreen extends StatefulWidget {
  final Pedido pedido;

  const NavegacionScreen({super.key, required this.pedido});

  @override
  State<NavegacionScreen> createState() => _NavegacionScreenState();
}

class _NavegacionScreenState extends State<NavegacionScreen> {
  GoogleMapController? _mapController;
  bool _enComercio = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${widget.pedido.numero}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _llamarCliente,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.pedido.comercio.lat,
                  widget.pedido.comercio.lng,
                ),
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          _buildAcciones(),
        ],
      ),
    );
  }

  Widget _buildAcciones() {
    if (!_enComercio) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _abrirNavegacion,
              icon: const Icon(Icons.navigation),
              label: const Text('Navegar al Comercio'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _confirmarRecogida,
              child: const Text('Confirmar Recogida'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _abrirNavegacion,
            icon: const Icon(Icons.navigation),
            label: const Text('Navegar al Cliente'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _confirmarEntrega,
            child: const Text('Confirmar Entrega'),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirNavegacion() async {
    final lat = _enComercio 
        ? widget.pedido.cliente.lat 
        : widget.pedido.comercio.lat;
    final lng = _enComercio 
        ? widget.pedido.cliente.lng 
        : widget.pedido.comercio.lng;

    final url = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _confirmarRecogida() async {
    // API call
    setState(() {
      _enComercio = true;
    });
  }

  Future<void> _confirmarEntrega() async {
    // API call
    Navigator.pop(context);
  }

  Future<void> _llamarCliente() async {
    final url = Uri.parse('tel:${widget.pedido.cliente.telefono}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
```

## Definición de Hecho (DoD)

- [ ] Navegación a comercio funcional
- [ ] Confirmar recogida operativo
- [ ] Navegación a cliente funcional
- [ ] Confirmar entrega operativo
- [ ] Llamar al cliente funcional
- [ ] Tests pasando

## Dependencias

- Issue #26: Gestión de Pedidos Disponibles

## Siguiente Issue

Issue #28: Sistema de Asignación Inteligente
