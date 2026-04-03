# Issue #28: Sistema de Asignación Inteligente

**Epic:** App Repartidor  
**Prioridad:** Media  
**Estimación:** 2 días  
**Sprint:** Sprint 4

---

## Descripción

Algoritmo de asignación inteligente que considera distancia, rating, entregas completadas y disponibilidad.

## Objetivos

- Algoritmo de scoring
- Priorización de repartidores
- Notificación automática
- Timeout y reasignación
- Métricas de eficiencia

## Tareas Técnicas

### 1. Algoritmo de Asignación (Backend)

```php
class AsignacionInteligente
{
    public function asignarMejorRepartidor(Pedido $pedido)
    {
        $repartidores = Repartidor::disponibles()
            ->cercanos($pedido->direccion_json['lat'], $pedido->direccion_json['lng'], 5)
            ->get();

        if ($repartidores->isEmpty()) {
            return null;
        }

        $scores = $repartidores->map(function($repartidor) use ($pedido) {
            return [
                'repartidor' => $repartidor,
                'score' => $this->calcularScore($repartidor, $pedido),
            ];
        })->sortByDesc('score');

        return $scores->first()['repartidor'];
    }

    private function calcularScore(Repartidor $repartidor, Pedido $pedido)
    {
        $distancia = $this->calcularDistancia($repartidor, $pedido);
        $scoreDistancia = max(0, 100 - ($distancia * 10));
        
        $scoreRating = $repartidor->rating * 20;
        $scoreEntregas = min(100, $repartidor->total_entregas);
        $scoreTiempo = $this->calcularScoreTiempo($repartidor);

        return ($scoreDistancia * 0.4) + 
               ($scoreRating * 0.3) + 
               ($scoreEntregas * 0.2) + 
               ($scoreTiempo * 0.1);
    }
}
```

## Definición de Hecho (DoD)

- [ ] Algoritmo de scoring implementado
- [ ] Asignación automática funcional
- [ ] Timeout y reasignación operativos
- [ ] Métricas registradas
- [ ] Tests pasando

## Dependencias

- Issue #11: API de Repartidores y GPS Tracking

## Siguiente Issue

Issue #29: Modo Freelance
