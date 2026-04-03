# Issue #34: Deployment Frontend (PWA)

**Epic:** Testing & Deployment  
**Prioridad:** Alta  
**Estimación:** 1 día  
**Sprint:** Sprint 5

---

## Descripción

Desplegar PWA de cliente en hosting estático con CDN y configuración PWA completa.

## Objetivos

- Build optimizado de producción
- Deploy en Netlify/Vercel
- Service Worker configurado
- PWA instalable
- CDN para assets

## Tareas Técnicas

### 1. Build de Producción

```bash
# Build optimizado
flutter build web --release --web-renderer canvaskit

# Verificar tamaño
du -sh build/web
```

### 2. Configuración Netlify

**Archivo:** `netlify.toml`

```toml
[build]
  command = "flutter build web --release"
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "no-referrer"

[[headers]]
  for = "/assets/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

### 3. Service Worker

**Archivo:** `web/flutter_service_worker.js`

```javascript
const CACHE_NAME = 'izy-cliente-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/assets/AssetManifest.json',
  '/assets/FontManifest.json',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => response || fetch(event.request))
  );
});
```

### 4. Manifest PWA

**Archivo:** `web/manifest.json`

```json
{
  "name": "IZY Cliente",
  "short_name": "IZY",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#FFFFFF",
  "theme_color": "#1B3A57",
  "description": "Plataforma de delivery IZY",
  "orientation": "portrait",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}
```

### 5. Deploy Script

```bash
#!/bin/bash

# Build
flutter build web --release

# Deploy a Netlify
netlify deploy --prod --dir=build/web

# O deploy a Vercel
vercel --prod
```

## Definición de Hecho (DoD)

- [ ] Build de producción optimizado
- [ ] PWA desplegada y accesible
- [ ] Service Worker funcionando
- [ ] PWA instalable en móviles
- [ ] CDN configurado
- [ ] HTTPS habilitado

## Comandos de Verificación

```bash
# Lighthouse audit
lighthouse https://izy.app --view

# Test PWA
curl https://izy.app
```

## Dependencias

- Issue #33: Deployment Backend

## Siguiente Issue

Issue #35: Generación de APKs
