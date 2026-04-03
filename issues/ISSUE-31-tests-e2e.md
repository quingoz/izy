# Issue #31: Tests End-to-End

**Epic:** Testing & Deployment  
**Prioridad:** Alta  
**Estimación:** 3 días  
**Sprint:** Sprint 5

---

## Descripción

Suite completa de tests end-to-end para flujos críticos del sistema.

## Objetivos

- Tests de flujo completo de pedido
- Tests de autenticación
- Tests de multi-tenancy
- Tests de WebSockets
- Coverage >80%

## Tareas Técnicas

### 1. Test Flujo Completo Pedido

```php
class PedidoFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_flujo_completo_pedido()
    {
        // Setup
        $comercio = Comercio::factory()->create();
        $cliente = User::factory()->create(['role' => 'cliente']);
        $producto = Producto::factory()->create(['comercio_id' => $comercio->id]);
        $repartidor = Repartidor::factory()->create();

        // Cliente crea pedido
        $response = $this->actingAs($cliente)->postJson('/api/pedidos', [
            'comercio_id' => $comercio->id,
            'items' => [
                [
                    'producto_id' => $producto->id,
                    'cantidad' => 2,
                ],
            ],
            'tipo_pago' => 'efectivo',
            'direccion' => [
                'calle' => 'Test',
                'lat' => 10.5,
                'lng' => -66.9,
            ],
        ]);

        $response->assertStatus(201);
        $pedido = Pedido::first();

        // Comercio confirma
        $adminComercio = User::factory()->create([
            'role' => 'comercio',
            'comercio_id' => $comercio->id,
        ]);

        $this->actingAs($adminComercio)
            ->putJson("/api/comercio/pedidos/{$pedido->id}/estado", [
                'estado' => 'confirmado',
            ])
            ->assertStatus(200);

        $pedido->refresh();
        $this->assertEquals('confirmado', $pedido->estado);

        // Asignar repartidor
        $this->actingAs($adminComercio)
            ->postJson("/api/comercio/pedidos/{$pedido->id}/asignar-repartidor", [
                'tipo' => 'manual',
                'repartidor_id' => $repartidor->id,
            ])
            ->assertStatus(200);

        // Repartidor confirma recogida
        $userRepartidor = $repartidor->user;
        $this->actingAs($userRepartidor)
            ->postJson("/api/repartidor/pedidos/{$pedido->id}/confirmar-recogida")
            ->assertStatus(200);

        // Repartidor confirma entrega
        $this->actingAs($userRepartidor)
            ->postJson("/api/repartidor/pedidos/{$pedido->id}/confirmar-entrega", [
                'cobro_confirmado' => true,
            ])
            ->assertStatus(200);

        $pedido->refresh();
        $this->assertEquals('entregado', $pedido->estado);
    }
}
```

### 2. Flutter Integration Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Flujo completo de pedido', (tester) async {
    // Login
    await tester.pumpWidget(const IzyClienteApp());
    await tester.pumpAndSettle();

    // Navegar a productos
    await tester.tap(find.text('Ver Productos'));
    await tester.pumpAndSettle();

    // Agregar al carrito
    await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
    await tester.pumpAndSettle();

    // Ir al carrito
    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();

    // Checkout
    await tester.tap(find.text('Continuar al Checkout'));
    await tester.pumpAndSettle();

    // Confirmar pedido
    await tester.tap(find.text('Confirmar Pedido'));
    await tester.pumpAndSettle();

    // Verificar navegación a tracking
    expect(find.text('Tracking'), findsOneWidget);
  });
}
```

## Definición de Hecho (DoD)

- [ ] Tests E2E de flujo completo
- [ ] Coverage >80%
- [ ] Tests de regresión
- [ ] CI/CD configurado
- [ ] Todos los tests pasando

## Comandos de Verificación

```bash
# Backend
php artisan test --coverage

# Flutter
flutter test --coverage
flutter test integration_test/
```

## Dependencias

- Todos los issues anteriores

## Siguiente Issue

Issue #32: Optimización de Performance
