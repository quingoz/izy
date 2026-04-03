# 📚 Guía de Git - Subir Cambios al Repositorio

## ✅ Estado Actual

**Commit creado exitosamente:**
- **Hash:** `a6b6346`
- **Mensaje:** `feat: Generar 35 issues detallados y workflows para desarrollo completo del proyecto IZY`
- **Archivos:** 39 archivos nuevos (11,311 líneas agregadas)

**Problema:** Error de autenticación al hacer push (credenciales incorrectas)

---

## 🔧 Solución: Configurar Credenciales de GitHub

### Opción 1: Usar Personal Access Token (Recomendado)

#### Paso 1: Crear Personal Access Token en GitHub

1. Ve a GitHub: https://github.com/settings/tokens
2. Click en **"Generate new token"** → **"Generate new token (classic)"**
3. Configuración del token:
   - **Note:** `IZY Project - Windows PC`
   - **Expiration:** `90 days` (o el que prefieras)
   - **Scopes:** Marca `repo` (acceso completo a repositorios)
4. Click en **"Generate token"**
5. **IMPORTANTE:** Copia el token inmediatamente (solo se muestra una vez)

#### Paso 2: Configurar Git con el Token

```bash
# Navegar al proyecto
cd c:\xampp\htdocs\izy

# Configurar credenciales para este repositorio
git config credential.helper store

# Hacer push (te pedirá credenciales)
git push origin main
```

Cuando te pida credenciales:
- **Username:** `quingoz`
- **Password:** `[pega tu Personal Access Token aquí]`

---

### Opción 2: Usar SSH (Más Seguro)

#### Paso 1: Generar Clave SSH

```bash
# Generar clave SSH
ssh-keygen -t ed25519 -C "quintanaanthony7@gmail.com"

# Presiona Enter 3 veces (ubicación por defecto, sin passphrase)
```

#### Paso 2: Copiar Clave Pública

```bash
# Mostrar clave pública
cat ~/.ssh/id_ed25519.pub
```

Copia todo el contenido que aparece.

#### Paso 3: Agregar Clave a GitHub

1. Ve a GitHub: https://github.com/settings/keys
2. Click en **"New SSH key"**
3. **Title:** `Windows PC - IZY`
4. **Key:** Pega la clave pública copiada
5. Click en **"Add SSH key"**

#### Paso 4: Cambiar Remote a SSH

```bash
# Cambiar URL del remote a SSH
git remote set-url origin git@github.com:quingoz/izy.git

# Verificar
git remote -v

# Hacer push
git push origin main
```

---

## 📝 Comandos Completos para Subir Cambios

### Si ya tienes credenciales configuradas:

```bash
# 1. Ver estado
git status

# 2. Agregar archivos
git add .

# 3. Crear commit
git commit -m "feat: Generar 35 issues detallados y workflows"

# 4. Subir a GitHub
git push origin main
```

### Si necesitas forzar credenciales:

```bash
# Limpiar credenciales guardadas
git credential-cache exit

# O eliminar credenciales almacenadas
git config --unset credential.helper

# Hacer push (te pedirá credenciales nuevamente)
git push origin main
```

---

## 🚨 Solución Rápida al Error Actual

**El commit ya está creado**, solo falta hacer push. Ejecuta:

```bash
cd c:\xampp\htdocs\izy

# Opción A: Usar token
git push https://[TU_TOKEN]@github.com/quingoz/izy.git main

# Opción B: Configurar credential helper y reintentar
git config credential.helper manager
git push origin main
```

---

## 📊 Verificar que Todo Subió Correctamente

```bash
# Ver commits locales vs remotos
git log origin/main..main

# Si no muestra nada, todo está sincronizado ✅

# Ver último commit
git log -1

# Verificar en GitHub
# Ve a: https://github.com/quingoz/izy/commits/main
```

---

## 📦 Archivos que se Subirán

```
✅ 39 archivos nuevos:
├── .windsurf/workflows/
│   ├── multi-issue.md
│   └── single-issue.md
├── GUIA_RAPIDA.md
└── issues/
    ├── README.md
    ├── ISSUE-01-setup-backend.md
    ├── ISSUE-02-database-schema.md
    ├── ISSUE-03-modelos-eloquent.md
    ├── ISSUE-04-autenticacion-sanctum.md
    ├── ISSUE-05-multi-tenancy.md
    ├── ISSUE-06-api-comercios-productos.md
    ├── ISSUE-07-api-pedidos-cliente.md
    ├── ISSUE-08-websockets-reverb.md
    ├── ISSUE-09-notificaciones-push.md
    ├── ISSUE-10-api-comercio-pedidos.md
    ├── ISSUE-11-api-repartidores-gps.md
    ├── ISSUE-12-setup-flutter-web.md
    ├── ISSUE-13-cliente-http-state.md
    ├── ISSUE-14-branding-dinamico.md
    ├── ISSUE-15-catalogo-productos.md
    ├── ISSUE-16-carrito-compras.md
    ├── ISSUE-17-checkout-pago.md
    ├── ISSUE-18-tracking-tiempo-real.md
    ├── ISSUE-19-setup-app-comercio.md
    ├── ISSUE-20-dashboard-comercio.md
    ├── ISSUE-21-kitchen-flow.md
    ├── ISSUE-22-gestion-productos.md
    ├── ISSUE-23-logistica-repartidores.md
    ├── ISSUE-24-setup-app-repartidor.md
    ├── ISSUE-25-gps-tracking-background.md
    ├── ISSUE-26-pedidos-disponibles.md
    ├── ISSUE-27-navegacion-entrega.md
    ├── ISSUE-28-asignacion-inteligente.md
    ├── ISSUE-29-modo-freelance.md
    ├── ISSUE-30-estadisticas-ganancias.md
    ├── ISSUE-31-tests-e2e.md
    ├── ISSUE-32-optimizacion-performance.md
    ├── ISSUE-33-deployment-backend.md
    ├── ISSUE-34-deployment-pwa.md
    └── ISSUE-35-generacion-apks.md

Total: 11,311 líneas de código
```

---

## 🔍 Troubleshooting

### Error: "Permission denied"
**Causa:** Credenciales incorrectas o expiradas  
**Solución:** Usar Personal Access Token (ver Opción 1)

### Error: "Authentication failed"
**Causa:** Token inválido o sin permisos  
**Solución:** Generar nuevo token con scope `repo`

### Error: "Could not read from remote repository"
**Causa:** SSH key no configurada  
**Solución:** Usar HTTPS con token o configurar SSH (ver Opción 2)

---

## ✨ Comandos Útiles de Git

```bash
# Ver historial de commits
git log --oneline -10

# Ver cambios en un archivo
git diff ARCHIVO

# Ver archivos modificados
git status

# Deshacer último commit (mantener cambios)
git reset --soft HEAD~1

# Ver configuración de Git
git config --list

# Ver remote configurado
git remote -v

# Actualizar desde GitHub
git pull origin main
```

---

## 📌 Notas Importantes

1. **Personal Access Token:** Guárdalo en un lugar seguro (como un gestor de contraseñas)
2. **No compartas tu token:** Es como tu contraseña de GitHub
3. **Token expirado:** Genera uno nuevo cuando expire
4. **SSH es más seguro:** Considera usar SSH para proyectos a largo plazo

---

## 🎯 Próximos Pasos Después del Push

Una vez que hagas push exitoso:

1. Verifica en GitHub: https://github.com/quingoz/izy
2. Deberías ver los 35 issues en el directorio `issues/`
3. Los workflows estarán en `.windsurf/workflows/`
4. Listo para comenzar el desarrollo 🚀

---

**¿Necesitas ayuda?** Revisa la documentación oficial de GitHub:
- Personal Access Tokens: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
- SSH Keys: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
