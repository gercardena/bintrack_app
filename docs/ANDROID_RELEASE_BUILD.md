# Build release Android - BinTrack

## Objetivo

Este documento explica cómo generar artefactos release de Android para BinTrack:

- APK release: útil para instalar directamente en teléfonos de prueba.
- AAB release: formato usado normalmente para Google Play Store.

## Requisitos previos

Antes de generar builds release:

1. Estar en la carpeta del proyecto Flutter:

```powershell
cd C:\proyectos\bintrack_app

Tener configurada la firma release:
android/app/bintrack-release-key.jks
android/key.properties
Estos archivos NO se suben a GitHub.
Verificar entorno Android:
flutter doctor -v
La sección Android debe aparecer como:
[√] Android toolchain
Si faltan licencias:
flutter doctor --android-licenses
Aceptar con y.
Backend local
Para builds apuntando al backend local, el backend debe estar accesible desde el teléfono en la red WiFi.
Ejemplo de backend:
python manage.py runserver 0.0.0.0:8000
La IP usada en estos ejemplos es:
http://192.168.11.215:8000
Si cambia la IP del computador, se debe cambiar también el valor de API_HOST.
Generar APK release
Comando:
flutter build apk --release --dart-define=API_HOST=http://192.168.11.215:8000
Salida esperada:
build\app\outputs\flutter-apk\app-release.apk
Verificar archivo:

Get-ChildItem C:\proyectos\bintrack_app\build\app\outputs\flutter-apk\app-release.apk | Select-Object FullName, Length, LastWriteTime

Instalar APK release en teléfono conectado
Con el teléfono conectado por USB:
flutter install --release
Después de instalar, la app puede usarse sin cable mientras el teléfono y el backend estén en la misma red.
Verificar firma del APK
Ubicar apksigner:

Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\build-tools" -Recurse -Filter apksigner.bat | Select-Object -Last 1 FullName

& "C:\Users\camil\AppData\Local\Android\Sdk\build-tools\36.1.0\apksigner.bat" verify --verbose --print-certs C:\proyectos\bintrack_app\build\app\outputs\flutter-apk\app-release.apk

Verifies
Verified using v2 scheme (APK Signature Scheme v2): true
Number of signers: 1
Signer #1 certificate DN: CN=BinTrack, OU=BinTrack, O=BinTrack, L=Santiago, ST=RM, C=CL

Generar AAB release
Comando:
flutter build appbundle --release --dart-define=API_HOST=http://192.168.11.215:8000
Salida esperada:
build\app\outputs\bundle\release\app-release.aab
Verificar archivo:
Get-ChildItem C:\proyectos\bintrack_app\build\app\outputs\bundle\release\app-release.aab | Select-Object FullName, Length, LastWriteTime
Diferencia entre APK y AAB
APK:
Se puede instalar directamente en teléfonos.
Útil para pruebas internas rápidas.
Archivo generado:app-release.apk

AAB:
No se instala directamente como APK normal.
Es el formato recomendado/pedido por Google Play Store.
Google Play genera APKs optimizados desde el AAB.
Archivo generado:app-release.aab

Archivos generados
Los artefactos release quedan dentro de:
build/
La carpeta build/ está ignorada por Git, por lo que los APK/AAB no se suben al repositorio.
Estado validado
Fecha: 04/07/2026
Validado:
APK release generado correctamente.
APK firmado con firma release real.
APK verificado con apksigner.
AAB release generado correctamente.
Android toolchain corregido.
Licencias Android aceptadas.