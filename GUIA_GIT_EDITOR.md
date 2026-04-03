# 🎯 Guía: Usar Git desde el Editor (Sin Comandos)

## ✅ Problema Resuelto

Las credenciales de GitHub ya están configuradas correctamente para tu cuenta personal **quingoz**.

---

## 📋 Cómo Usar Git desde Windsurf/VS Code

### 1️⃣ Panel de Control de Código Fuente

**Ubicación:** Barra lateral izquierda → Icono de ramificación (Source Control)

O usa el atajo: `Ctrl + Shift + G`

---

### 2️⃣ Ver Cambios Pendientes

En el panel de Source Control verás:
- **Changes:** Archivos modificados
- **Staged Changes:** Archivos listos para commit
- **Untracked Files:** Archivos nuevos sin seguimiento

---

### 3️⃣ Agregar Archivos al Staging (git add)

**Opción A: Agregar todos los archivos**
1. En el panel Source Control
2. Haz clic en el icono **`+`** junto a "Changes"
3. Todos los archivos se mueven a "Staged Changes"

**Opción B: Agregar archivos individuales**
1. Pasa el mouse sobre el archivo
2. Haz clic en el icono **`+`** que aparece
3. El archivo se mueve a "Staged Changes"

**Atajo de teclado:**
- Selecciona archivos y presiona `Ctrl + Enter`

---

### 4️⃣ Crear Commit (git commit)

1. En el panel Source Control
2. En el campo de texto arriba (donde dice "Message")
3. Escribe tu mensaje de commit, ejemplo:
   ```
   feat: Agregar nuevos issues del proyecto
   ```
4. Presiona `Ctrl + Enter` o haz clic en el botón **✓ Commit**

**Tipos de mensajes recomendados:**
- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `refactor:` Refactorización de código
- `chore:` Tareas de mantenimiento

---

### 5️⃣ Subir Cambios a GitHub (git push)

**Opción A: Botón de Sync**
1. Después de hacer commit
2. Haz clic en el botón **"Sync Changes"** (icono de flechas circulares)
3. O haz clic en **"Publish Branch"** si es la primera vez

**Opción B: Menú de tres puntos**
1. Haz clic en los **`...`** (tres puntos) en el panel Source Control
2. Selecciona **"Push"**

**Atajo de teclado:**
- No hay atajo por defecto, pero puedes configurar uno

---

### 6️⃣ Descargar Cambios de GitHub (git pull)

1. Haz clic en los **`...`** (tres puntos)
2. Selecciona **"Pull"**

O simplemente usa el botón **"Sync Changes"** que hace pull + push

---

## 🔄 Flujo de Trabajo Completo (Sin Comandos)

### Escenario: Hiciste cambios y quieres subirlos a GitHub

```
1. Ctrl + Shift + G (Abrir Source Control)
   ↓
2. Clic en + junto a "Changes" (Stage All)
   ↓
3. Escribir mensaje en el campo de texto
   ↓
4. Ctrl + Enter (Commit)
   ↓
5. Clic en "Sync Changes" (Push)
   ✅ ¡Listo!
```

---

## 🎨 Interfaz Visual del Editor

### Panel Source Control

```
┌─────────────────────────────────────┐
│  SOURCE CONTROL                  ⚙️ │
├─────────────────────────────────────┤
│  Message (Ctrl+Enter to commit)     │
│  ┌─────────────────────────────────┐│
│  │ feat: Tu mensaje aquí          ││
│  └─────────────────────────────────┘│
│                                     │
│  ✓ Commit    ↻ Sync Changes        │
├─────────────────────────────────────┤
│  📁 STAGED CHANGES              (+) │
│    ✓ archivo1.md                    │
│    ✓ archivo2.md                    │
├─────────────────────────────────────┤
│  📁 CHANGES                     (+) │
│    M archivo3.md                (+) │
│    M archivo4.md                (+) │
└─────────────────────────────────────┘
```

---

## 🔍 Ver Diferencias (Diff)

**Para ver qué cambió en un archivo:**
1. Haz clic en el archivo en el panel Source Control
2. Se abrirá una vista de comparación:
   - **Izquierda:** Versión anterior
   - **Derecha:** Versión actual
   - **Colores:** Rojo = eliminado, Verde = agregado

---

## 🌿 Trabajar con Ramas (Branches)

### Ver rama actual
- Mira la esquina inferior izquierda del editor
- Verás algo como: `main` o `master`

### Crear nueva rama
1. Haz clic en el nombre de la rama (esquina inferior izquierda)
2. Selecciona **"Create new branch..."**
3. Escribe el nombre de la rama
4. Presiona Enter

### Cambiar de rama
1. Haz clic en el nombre de la rama
2. Selecciona la rama a la que quieres cambiar

---

## ⚙️ Configuración Útil

### Habilitar Auto-fetch
1. `Ctrl + ,` (Abrir Settings)
2. Buscar: `git.autofetch`
3. Activar la opción
4. Esto descarga cambios automáticamente cada cierto tiempo

### Mostrar cambios en línea
1. `Ctrl + ,` (Abrir Settings)
2. Buscar: `git.decorations.enabled`
3. Activar para ver indicadores en los archivos

---

## 🚨 Resolver Conflictos

Si hay conflictos al hacer pull o merge:

1. Los archivos con conflictos aparecerán marcados
2. Haz clic en el archivo
3. Verás marcadores como:
   ```
   <<<<<<< HEAD
   Tu código
   =======
   Código del servidor
   >>>>>>> origin/main
   ```
4. El editor te mostrará botones:
   - **Accept Current Change**
   - **Accept Incoming Change**
   - **Accept Both Changes**
5. Elige la opción correcta
6. Guarda el archivo
7. Haz commit de la resolución

---

## 📌 Atajos de Teclado Útiles

| Acción | Atajo |
|--------|-------|
| Abrir Source Control | `Ctrl + Shift + G` |
| Commit | `Ctrl + Enter` |
| Abrir Terminal | `` Ctrl + ` `` |
| Buscar archivos | `Ctrl + P` |
| Buscar en archivos | `Ctrl + Shift + F` |
| Guardar todo | `Ctrl + K S` |

---

## 🎯 Extensiones Recomendadas

### GitLens (Altamente recomendado)
- **Qué hace:** Muestra quién modificó cada línea, cuándo y por qué
- **Instalar:** 
  1. `Ctrl + Shift + X` (Extensiones)
  2. Buscar "GitLens"
  3. Instalar

### Git Graph
- **Qué hace:** Visualiza el historial de commits en forma de gráfico
- **Instalar:** Igual que GitLens

---

## 💡 Tips y Trucos

### 1. Ver historial de un archivo
- Clic derecho en el archivo → **"Open Timeline"**
- Verás todos los commits que modificaron ese archivo

### 2. Deshacer cambios en un archivo
- En Source Control, clic derecho en el archivo
- Selecciona **"Discard Changes"**
- ⚠️ Esto elimina los cambios sin guardar

### 3. Stash (Guardar cambios temporalmente)
- Menú `...` → **"Stash"** → **"Stash (Include Untracked)"**
- Útil cuando quieres cambiar de rama sin hacer commit

### 4. Ver commits anteriores
- Menú `...` → **"View History"** (requiere GitLens)

---

## 🔐 Autenticación

### Primera vez que hagas push
Se abrirá una ventana del navegador para autenticarte con GitHub:

1. Inicia sesión con tu cuenta **quingoz**
2. Autoriza la aplicación
3. Las credenciales se guardarán automáticamente
4. No tendrás que volver a autenticarte

### Si te pide credenciales en el futuro
- Usa tu **username:** `quingoz`
- Usa un **Personal Access Token** como contraseña (no tu contraseña de GitHub)

---

## 📝 Ejemplo Práctico Completo

### Escenario: Acabas de crear nuevos archivos

```
1. Presiona Ctrl + Shift + G
   → Se abre el panel Source Control

2. Ves tus archivos en "Changes"
   → Haz clic en el + junto a "Changes"
   → Todos pasan a "Staged Changes"

3. En el campo de mensaje escribe:
   "feat: Agregar documentación de issues"

4. Presiona Ctrl + Enter
   → Commit creado ✅

5. Haz clic en "Sync Changes"
   → Se suben los cambios a GitHub ✅

6. Ve a https://github.com/quingoz/izy
   → Verás tus cambios reflejados 🎉
```

---

## 🆘 Solución de Problemas

### "No se puede hacer push"
- Verifica que estés en la rama correcta
- Haz pull primero para sincronizar
- Revisa si hay conflictos

### "Credenciales incorrectas"
- Las credenciales ya están configuradas correctamente
- Si vuelve a pedir, usa tu Personal Access Token

### "Merge conflict"
- Sigue los pasos de "Resolver Conflictos" arriba
- O pregúntame y te ayudo

---

## ✅ Resumen: Todo lo que Necesitas

**Para subir cambios a GitHub:**
1. `Ctrl + Shift + G` → Abrir Source Control
2. `+` → Stage All Changes
3. Escribir mensaje → `Ctrl + Enter` → Commit
4. Click "Sync Changes" → Push

**¡Eso es todo! No necesitas la terminal. 🎉**

---

## 🔗 Recursos Adicionales

- **Documentación oficial de VS Code Git:** https://code.visualstudio.com/docs/sourcecontrol/overview
- **GitLens:** https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens
- **GitHub Desktop (alternativa visual):** https://desktop.github.com/

---

**¡Ahora puedes trabajar con Git completamente desde el editor sin escribir comandos! 🚀**
