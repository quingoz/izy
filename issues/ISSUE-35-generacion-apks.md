# Issue #35: Generación de APKs

**Epic:** Testing & Deployment  
**Prioridad:** Alta  
**Estimación:** 1 día  
**Sprint:** Sprint 5

---

## Descripción

Generar APKs firmados de producción para App Comercio y App Repartidor con configuración de release.

## Objetivos

- Keystore de firma creado
- APKs de release firmados
- Ofuscación de código
- Optimización de tamaño
- Versionado correcto

## Tareas Técnicas

### 1. Crear Keystore

```bash
keytool -genkey -v -keystore izy-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias izy
```

### 2. Configurar Signing

**Archivo:** `android/key.properties`

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=izy
storeFile=../izy-release-key.jks
```

**Archivo:** `android/app/build.gradle`

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. ProGuard Rules

**Archivo:** `android/app/proguard-rules.pro`

```proguard
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**
```

### 4. Build Scripts

**Archivo:** `scripts/build-comercio.sh`

```bash
#!/bin/bash

echo "Building IZY Comercio APK..."

# Limpiar
flutter clean
flutter pub get

# Build release
flutter build apk --flavor comercio --release

# Copiar APK
cp build/app/outputs/flutter-apk/app-comercio-release.apk releases/izy-comercio-v1.0.0.apk

echo "APK generado: releases/izy-comercio-v1.0.0.apk"
```

**Archivo:** `scripts/build-repartidor.sh`

```bash
#!/bin/bash

echo "Building IZY Repartidor APK..."

# Limpiar
flutter clean
flutter pub get

# Build release
flutter build apk --flavor repartidor --release

# Copiar APK
cp build/app/outputs/flutter-apk/app-repartidor-release.apk releases/izy-repartidor-v1.0.0.apk

echo "APK generado: releases/izy-repartidor-v1.0.0.apk"
```

### 5. App Bundle (Para Google Play)

```bash
# Build App Bundle
flutter build appbundle --flavor comercio --release
flutter build appbundle --flavor repartidor --release
```

### 6. Versionado

**Archivo:** `pubspec.yaml`

```yaml
version: 1.0.0+1
```

Incrementar versión:
- **Major:** Cambios incompatibles (2.0.0)
- **Minor:** Nuevas funcionalidades (1.1.0)
- **Patch:** Bug fixes (1.0.1)
- **Build number:** +1, +2, +3...

### 7. Verificación de APK

```bash
# Analizar tamaño
flutter build apk --analyze-size --flavor comercio

# Verificar firma
jarsigner -verify -verbose -certs app-comercio-release.apk

# Instalar en dispositivo
adb install releases/izy-comercio-v1.0.0.apk
```

## Definición de Hecho (DoD)

- [ ] Keystore creado y seguro
- [ ] APK Comercio firmado
- [ ] APK Repartidor firmado
- [ ] Ofuscación habilitada
- [ ] Tamaño optimizado (<50MB)
- [ ] APKs instalables en Android
- [ ] Versionado correcto

## Comandos de Verificación

```bash
# Build Comercio
./scripts/build-comercio.sh

# Build Repartidor
./scripts/build-repartidor.sh

# Verificar tamaños
ls -lh releases/

# Test instalación
adb install releases/izy-comercio-v1.0.0.apk
adb install releases/izy-repartidor-v1.0.0.apk
```

## Notas Importantes

- **Keystore:** Guardar en lugar seguro, NO subir a Git
- **Passwords:** Usar variables de entorno en CI/CD
- **Versionado:** Incrementar en cada release
- **Testing:** Probar APKs en dispositivos reales

## Dependencias

- Issue #34: Deployment Frontend (PWA)

## Siguiente Issue

¡Proyecto completado! 🎉
