---
description: Desarrollar múltiples issues del proyecto IZY en un solo prompt
---

# Workflow: Desarrollar Múltiples Issues

Este workflow te permite desarrollar varios issues relacionados en una sola sesión para optimizar créditos.

## Cuándo Usar Este Workflow

- Cuando quieres desarrollar issues consecutivos (ej: #1, #2, #3)
- Cuando los issues son del mismo Epic
- Cuando quieres avanzar rápido en un sprint
- **Para ahorrar créditos** desarrollando varios issues juntos

## Paso 1: Especificar Issues

Indica qué issues quieres desarrollar. Ejemplo:
- "Quiero desarrollar los Issues #1, #2 y #3"
- "Desarrolla los Issues del #12 al #15"
- "Haz los Issues #19, #20 y #21"

**Recomendación:** No más de 3-5 issues por sesión para mantener calidad.

## Paso 2: Validar Orden y Dependencias

Verifica que:
1. Los issues estén en orden lógico
2. Las dependencias estén satisfechas
3. Sean del mismo Epic o relacionados

**Ejemplo válido:** Issues #2, #3, #4 (secuenciales del Epic 1)  
**Ejemplo inválido:** Issues #2, #15, #28 (de diferentes Epics sin relación)

## Paso 3: Desarrollo Secuencial

Para cada issue en orden:

### 3.1 Leer Issue
- Abrir `issues/ISSUE-XX-nombre.md`
- Entender objetivos y tareas

### 3.2 Implementar
// turbo
- Crear archivos necesarios
- Implementar código del issue
- Seguir convenciones del proyecto

### 3.3 Verificar
// turbo
- Ejecutar comandos de verificación
- Probar funcionalidad básica

### 3.4 Tests Rápidos
- Ejecutar tests críticos
- Validar que no haya errores

## Paso 4: Validación Final

Al completar todos los issues:

```bash
# Backend - Tests completos
php artisan test

# Verificar migraciones
php artisan migrate:status

# Verificar rutas
php artisan route:list
```

```bash
# Frontend - Tests completos
flutter test

# Verificar build
flutter build web --release
```

## Paso 5: Commit Consolidado

```bash
git add .
git commit -m "feat: Issues #X-#Y - Descripción general

- Issue #X: Descripción
- Issue #Y: Descripción
- Issue #Z: Descripción
"
```

## Estrategias de Optimización

### Opción A: Sprint Completo
Desarrollar todos los issues de un sprint:
```
"Desarrolla todos los issues del Sprint 1 (#2, #3, #4, #5)"
```

### Opción B: Por Epic
Desarrollar un Epic completo:
```
"Desarrolla el Epic 2 completo (Issues #12 al #18)"
```

### Opción C: Por Funcionalidad
Desarrollar una funcionalidad end-to-end:
```
"Desarrolla la funcionalidad de pedidos completa (Issues #7, #10, #11)"
```

## Ejemplo de Uso Eficiente

```
Usuario: "Quiero desarrollar los Issues #1, #2 y #3 para tener la base de datos lista"

Cascade:
1. Issue #1: Setup Backend
   - Instala Laravel
   - Configura .env
   - Instala dependencias
   - ✓ Verifica que funciona

2. Issue #2: Database Schema
   - Crea 13 migraciones
   - Ejecuta migraciones
   - ✓ Verifica tablas creadas

3. Issue #3: Modelos Eloquent
   - Crea modelos
   - Implementa traits
   - Crea factories
   - ✓ Ejecuta tests

4. Validación final:
   - Tests completos
   - Commit consolidado
   - Resumen de lo completado
```

## Límites Recomendados

| Tipo de Issues | Cantidad Máxima | Tiempo Estimado |
|----------------|-----------------|-----------------|
| Backend simples | 5 issues | 1-2 horas |
| Backend complejos | 3 issues | 2-3 horas |
| Frontend | 4 issues | 2-3 horas |
| Mixtos | 3 issues | 2-4 horas |

## Notas Importantes

- **Calidad > Cantidad:** Mejor hacer 3 issues bien que 5 mal
- **Probar entre issues:** Verificar que cada issue funciona antes de continuar
- **No saltar validaciones:** Ejecutar tests aunque sean múltiples issues
- **Commits intermedios:** Si un issue es muy grande, hacer commit antes de continuar

## Troubleshooting

**Si un issue falla a mitad del proceso:**
1. Completar el issue actual
2. Hacer commit de lo completado
3. Resolver el problema
4. Continuar con los siguientes

**Si hay conflictos entre issues:**
1. Revisar dependencias
2. Ajustar orden de desarrollo
3. Resolver conflictos antes de continuar

## Ventajas de Este Workflow

✅ **Ahorro de créditos:** Menos prompts, más trabajo  
✅ **Contexto continuo:** No perder el hilo entre issues  
✅ **Desarrollo rápido:** Avanzar varios issues en una sesión  
✅ **Menos overhead:** Menos setup entre issues  

## Desventajas a Considerar

⚠️ **Riesgo de errores acumulados:** Un error puede afectar múltiples issues  
⚠️ **Menos detalle:** Puede haber menos validación por issue  
⚠️ **Complejidad:** Más difícil de debuggear si algo falla  

## Recomendación Final

Para **máximo ahorro de créditos** sin sacrificar calidad:
- Desarrolla 3 issues relacionados por sesión
- Valida cada issue antes de continuar
- Haz commit después de cada issue crítico
- Usa este workflow para issues del mismo Epic
