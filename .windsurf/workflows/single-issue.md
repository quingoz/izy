---
description: Desarrollar un issue individual del proyecto IZY
---

# Workflow: Desarrollar Issue Individual

Este workflow te guía para desarrollar un issue específico del proyecto IZY.

## Paso 1: Identificar el Issue

Indica qué issue quieres desarrollar. Ejemplo:
- "Quiero desarrollar el Issue #3"
- "Vamos con el Issue #15"

## Paso 2: Leer el Issue

Lee el archivo del issue en `issues/ISSUE-XX-nombre.md` para entender:
- Objetivos
- Tareas técnicas
- Definición de Hecho (DoD)
- Dependencias

## Paso 3: Verificar Dependencias

Antes de comenzar, verifica que los issues de los que depende estén completados.

## Paso 4: Ejecutar Tareas Técnicas

Sigue las tareas técnicas del issue en orden:

### Para Issues de Backend:

1. **Crear archivos necesarios:**
   - Modelos, Controllers, Requests, Resources
   - Migraciones si aplica
   - Tests

2. **Implementar código:**
   - Copiar y adaptar el código de ejemplo del issue
   - Seguir las convenciones de Laravel
   - Agregar validaciones necesarias

3. **Configurar rutas:**
   - Agregar rutas en `routes/api.php`
   - Configurar middleware si aplica

4. **Ejecutar migraciones:**
   ```bash
   php artisan migrate
   ```

5. **Crear seeders si aplica:**
   ```bash
   php artisan db:seed --class=NombreSeeder
   ```

### Para Issues de Frontend (Flutter):

1. **Crear estructura de carpetas:**
   - Seguir arquitectura Clean
   - Separar por features

2. **Implementar providers (Riverpod):**
   - State management
   - Repositories
   - API clients

3. **Crear pantallas y widgets:**
   - Seguir diseño del issue
   - Usar colores del logo IZY:
     - Primary: `#1B3A57`
     - Secondary: `#5FD4A0`

4. **Integrar con API:**
   - Configurar Dio
   - Manejar errores
   - Loading states

## Paso 5: Ejecutar Tests

```bash
# Backend
php artisan test --filter=NombreTest

# Frontend
flutter test
```

## Paso 6: Verificar Comandos

Ejecuta los comandos de verificación especificados en el issue.

## Paso 7: Validar DoD

Revisa que se cumplan TODOS los criterios de la Definición de Hecho:
- [ ] Código implementado
- [ ] Tests pasando
- [ ] Comandos de verificación ejecutados
- [ ] Sin errores

## Paso 8: Commit

```bash
git add .
git commit -m "feat: Issue #XX - Nombre del issue"
```

## Notas Importantes

- **NO saltar pasos** - Seguir el orden del issue
- **Probar antes de continuar** - Verificar que funciona
- **Leer errores** - Resolver problemas antes de avanzar
- **Consultar documentación** - En `docs/` si hay dudas

## Ejemplo de Uso

```
Usuario: "Quiero desarrollar el Issue #3"

Cascade:
1. Lee issues/ISSUE-03-modelos-eloquent.md
2. Verifica que Issue #2 esté completado
3. Crea los modelos según el issue
4. Implementa traits y scopes
5. Crea factories
6. Ejecuta tests
7. Valida DoD
8. Hace commit
```

## Troubleshooting

**Error en migraciones:**
```bash
php artisan migrate:fresh
```

**Error en tests:**
```bash
php artisan config:clear
php artisan cache:clear
composer dump-autoload
```

**Error en Flutter:**
```bash
flutter clean
flutter pub get
```
