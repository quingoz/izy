<?php

namespace Tests\Feature;

use App\Events\PedidoEstadoActualizado;
use App\Models\Pedido;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Tests\TestCase;

class WebSocketTest extends TestCase
{
    use RefreshDatabase;

    public function test_pedido_estado_actualizado_broadcasts()
    {
        Event::fake();

        $pedido = Pedido::factory()->create();
        $pedido->update(['estado' => 'confirmado']);

        Event::assertDispatched(PedidoEstadoActualizado::class, function ($event) use ($pedido) {
            return $event->pedido->id === $pedido->id;
        });
    }

    public function test_user_can_subscribe_to_pedido_channel()
    {
        $user = User::factory()->create();
        $pedido = Pedido::factory()->create(['cliente_id' => $user->id]);

        $this->actingAs($user);

        $this->postJson('/broadcasting/auth', [
            'channel_name' => 'pedido.' . $pedido->id,
        ])->assertStatus(200);
    }

    public function test_user_cannot_subscribe_to_other_pedido_channel()
    {
        $user = User::factory()->create();
        $otroPedido = Pedido::factory()->create();

        $this->actingAs($user);

        $this->postJson('/broadcasting/auth', [
            'channel_name' => 'pedido.' . $otroPedido->id,
        ])->assertStatus(403);
    }
}
