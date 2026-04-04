# Configuración Android SDK sin Android Studio

## Requisitos
- Teléfono Android físico
- Cable USB
- Conexión a internet

---

## PASO 1: Descargar Android Command Line Tools

### 1.1 Descargar
1. Ve a: https://developer.android.com/studio#command-tools
2. Busca la sección **"Command line tools only"**
3. Descarga: **commandlinetools-win-[version]_latest.zip**
4. Guarda el archivo en tu carpeta de Descargas

### 1.2 Crear Estructura de Carpetas
```powershell
# Abre PowerShell y ejecuta:
mkdir C:\Android\sdk
mkdir C:\Android\sdk\cmdline-tools
```

### 1.3 Extraer el ZIP
1. Extrae el contenido del ZIP descargado
2. Verás una carpeta llamada `cmdline-tools`
3. Renombra esa carpeta a `latest`
4. Mueve la carpeta `latest` a: `C:\Android\sdk\cmdline-tools\`

**Estructura final:**
```
C:\Android\sdk\
└── cmdline-tools\
    └── latest\
        └── bin\
            ├── sdkmanager.bat
            └── avdmanager.bat
```

---

## PASO 2: Configurar Variables de Entorno

### 2.1 Abrir PowerShell como Administrador
1. Presiona `Win + X`
2. Selecciona **"Windows PowerShell (Administrador)"** o **"Terminal (Administrador)"**

### 2.2 Ejecutar Comandos

```powershell
# Configurar ANDROID_HOME
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Android\sdk', [System.EnvironmentVariableTarget]::Machine)

# Obtener PATH actual
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)

# Agregar rutas de Android al PATH
$androidPaths = ";C:\Android\sdk\cmdline-tools\latest\bin;C:\Android\sdk\platform-tools;C:\Android\sdk\build-tools\33.0.0"
$newPath = $currentPath + $androidPaths

# Guardar nuevo PATH
[System.Environment]::SetEnvironmentVariable('Path', $newPath, [System.EnvironmentVariableTarget]::Machine)
```

### 2.3 Cerrar y Abrir Nueva Terminal
**IMPORTANTE:** Cierra PowerShell y abre una nueva terminal para que cargue las variables.

---

## PASO 3: Instalar Componentes del SDK

### 3.1 Verificar sdkmanager
```powershell
# Abre nueva PowerShell normal (no administrador)
sdkmanager --version
```

Si muestra la versión, ¡perfecto! Continúa.

### 3.2 Aceptar Licencias
```powershell
sdkmanager --licenses
```
- Escribe `y` y presiona Enter para cada licencia
- Son varias, acepta todas

### 3.3 Instalar Componentes Necesarios
```powershell
# Platform tools (incluye ADB para conectar tu teléfono)
sdkmanager "platform-tools"

# Android API 33 (compatible con Flutter)
sdkmanager "platforms;android-33"

# Build tools
sdkmanager "build-tools;33.0.0"

# Command line tools
sdkmanager "cmdline-tools;latest"
```

**Nota:** Esto descargará ~500MB. Espera a que termine.

---

## PASO 4: Configurar tu Teléfono Android

### 4.1 Habilitar Opciones de Desarrollador
1. Ve a **Ajustes** → **Acerca del teléfono**
2. Busca **"Número de compilación"** o **"Versión de MIUI/One UI"**
3. Toca 7 veces seguidas
4. Verás mensaje: "Ahora eres desarrollador"

### 4.2 Habilitar Depuración USB
1. Ve a **Ajustes** → **Opciones de desarrollador**
2. Activa **"Depuración USB"**
3. (Opcional) Activa **"Instalación vía USB"**

### 4.3 Conectar Teléfono
1. Conecta tu teléfono a la PC con cable USB
2. En el teléfono aparecerá: **"¿Permitir depuración USB?"**
3. Marca **"Permitir siempre desde este equipo"**
4. Toca **"Permitir"**

---

## PASO 5: Verificar Conexión

### 5.1 Verificar ADB
```powershell
# Listar dispositivos conectados
adb devices
```

**Deberías ver:**
```
List of devices attached
ABC123456789    device
```

Si dice `unauthorized`, desconecta y vuelve a conectar el teléfono.

### 5.2 Verificar Flutter
```powershell
cd c:\xampp\htdocs\izy\izy_cliente

# Ver estado de Flutter
flutter doctor -v
```

**Deberías ver:**
```
[✓] Android toolchain - develop for Android devices (Android SDK version 33.0.0)
    • Android SDK at C:\Android\sdk
    • Platform android-33, build-tools 33.0.0
    • ANDROID_HOME = C:\Android\sdk
```

---

## PASO 6: Ejecutar App en tu Teléfono

### 6.1 Verificar Dispositivo
```powershell
flutter devices
```

Deberías ver tu teléfono listado.

### 6.2 Ejecutar App Comercio
```powershell
# Ejecutar en modo desarrollo
flutter run --flavor comercio

# O específicamente en tu dispositivo
flutter run --flavor comercio -d [ID_DE_TU_DISPOSITIVO]
```

### 6.3 Hot Reload
Una vez ejecutando:
- Presiona `r` para hot reload (recarga rápida)
- Presiona `R` para hot restart (reinicio completo)
- Presiona `q` para salir

---

## PASO 7: Compilar APK para Instalar

### 7.1 Build APK Debug
```powershell
flutter build apk --flavor comercio --debug
```

**APK generado en:**
```
izy_cliente\build\app\outputs\flutter-apk\app-comercio-debug.apk
```

### 7.2 Instalar APK en Teléfono
```powershell
# Instalar directamente
adb install build\app\outputs\flutter-apk\app-comercio-debug.apk

# O transferir el APK al teléfono e instalarlo manualmente
```

---

## Solución de Problemas

### Error: "sdkmanager no se reconoce"
**Solución:**
1. Verifica que la carpeta sea exactamente: `C:\Android\sdk\cmdline-tools\latest\bin`
2. Cierra TODAS las terminales y VS Code
3. Abre nueva PowerShell
4. Ejecuta: `echo $env:ANDROID_HOME`

### Error: "No devices found"
**Solución:**
1. Desconecta y reconecta el teléfono
2. Verifica que depuración USB esté activa
3. Ejecuta: `adb kill-server` y luego `adb devices`

### Error: "Unauthorized device"
**Solución:**
1. En el teléfono, revoca autorizaciones: Opciones de desarrollador → Revocar autorizaciones USB
2. Desconecta y reconecta
3. Acepta el diálogo nuevamente

### Flutter doctor muestra error en Android
**Solución:**
```powershell
flutter doctor --android-licenses
flutter config --android-sdk C:\Android\sdk
flutter doctor -v
```

---

## Comandos Útiles

```powershell
# Ver dispositivos conectados
adb devices

# Ver logs en tiempo real
adb logcat

# Reiniciar ADB
adb kill-server
adb start-server

# Desinstalar app
adb uninstall com.example.izy_cliente.comercio

# Verificar Flutter
flutter doctor -v

# Limpiar proyecto
flutter clean
flutter pub get
```

---

## Espacio en Disco Utilizado

- **Command Line Tools:** ~100 MB
- **Platform Tools:** ~15 MB
- **Build Tools:** ~80 MB
- **Android API 33:** ~70 MB
- **TOTAL:** ~265 MB

**vs Android Studio completo:** ~3-4 GB

---

## Resumen de Archivos Importantes

```
C:\Android\sdk\
├── cmdline-tools\latest\    # Herramientas CLI
├── platform-tools\          # ADB y fastboot
├── platforms\android-33\    # Android API 33
└── build-tools\33.0.0\      # Herramientas de compilación
```

---

## ¡Listo para Desarrollar!

Ahora puedes:
1. ✅ Ejecutar `flutter run --flavor comercio` en tu teléfono
2. ✅ Ver cambios en tiempo real con hot reload
3. ✅ Compilar APKs para distribución
4. ✅ Depurar directamente en dispositivo físico

**Próximo paso:** Ejecutar el Issue #19
```powershell
cd c:\xampp\htdocs\izy\izy_cliente
flutter run --flavor comercio
```
