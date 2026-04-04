import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/tracking_provider.dart';
import '../widgets/estado_timeline.dart';
import '../widgets/info_pedido_card.dart';
import '../../../../core/constants/app_constants.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final int pedidoId;

  const TrackingScreen({
    super.key,
    required this.pedidoId,
  });

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingProvider(widget.pedidoId));
    final theme = Theme.of(context);

    if (trackingState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (trackingState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tracking')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: IzyColors.error),
              const SizedBox(height: IzySpacing.md),
              Text(
                'Error al cargar tracking',
                style: IzyTextStyles.h3,
              ),
              const SizedBox(height: IzySpacing.sm),
              Text(
                trackingState.error!,
                style: IzyTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IzySpacing.lg),
              ElevatedButton(
                onPressed: () {
                  ref.read(trackingProvider(widget.pedidoId).notifier).loadTracking();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final pedido = trackingState.pedido!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${pedido.numeroPedido}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Compartir link de tracking
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _buildMapa(trackingState),
          ),

          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(IzySpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoPedidoCard(pedido: pedido),
                  const SizedBox(height: IzySpacing.md),
                  Text(
                    'Estado del Pedido',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: IzySpacing.md),
                  EstadoTimeline(
                    estadoActual: pedido.estado,
                    historial: pedido.historialEstados,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapa(TrackingState state) {
    final pedido = state.pedido!;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          pedido.comercio.lat,
          pedido.comercio.lng,
        ),
        zoom: 14,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
      },
      markers: {
        Marker(
          markerId: const MarkerId('comercio'),
          position: LatLng(pedido.comercio.lat, pedido.comercio.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: pedido.comercio.nombre),
        ),
        
        Marker(
          markerId: const MarkerId('cliente'),
          position: LatLng(pedido.cliente.lat, pedido.cliente.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
        ),
        
        if (state.ubicacionRepartidor != null)
          Marker(
            markerId: const MarkerId('repartidor'),
            position: LatLng(
              state.ubicacionRepartidor!.lat,
              state.ubicacionRepartidor!.lng,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            infoWindow: InfoWindow(
              title: pedido.repartidor?.nombre ?? 'Repartidor',
            ),
          ),
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
