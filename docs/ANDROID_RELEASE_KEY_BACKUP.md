# Respaldo de llave release Android - BinTrack

## Objetivo

Este documento explica cómo respaldar la llave de firma release de Android para BinTrack.

La llave release permite generar APK/AAB firmados. Es necesaria para distribuir la app y para futuras actualizaciones.

## Archivos sensibles

Estos archivos existen solo en la máquina local y NO deben subirse a GitHub:

```text
android/app/bintrack-release-key.jks
android/key.properties

Ambos están protegidos por .gitignore.
Archivo de llave
Ruta local actual:
C:\proyectos\bintrack_app\android\app\bintrack-release-key.jks
Certificado usado:
CN=BinTrack, OU=BinTrack, O=BinTrack, L=Santiago, ST=RM, C=CL
Alias:
bintrack
Huella SHA-256 del certificado
7684e87b6ce02301059ee0a90f078a484befbe1b94e62b541ab49f2c363e3b15
Qué respaldar
Guardar una copia segura de:
bintrack-release-key.jks
También guardar, en un gestor de contraseñas o lugar seguro, los datos usados en:
android/key.properties
Contenido esperado del archivo key.properties:
storePassword=NO_GUARDAR_AQUI
keyPassword=NO_GUARDAR_AQUI
keyAlias=bintrack
storeFile=bintrack-release-key.jks
No escribir contraseñas reales en este documento.
Dónde respaldar
Recomendado:
Disco externo.
Pendrive guardado físicamente.
Carpeta cifrada.
Gestor de contraseñas con adjuntos seguros.
Nube privada con cifrado.
Idealmente mantener al menos 2 copias.
Si se cambia de computador
Para poder volver a generar APK release firmado:
Copiar la llave a:
android/app/bintrack-release-key.jks
Crear manualmente:
android/key.properties
Completar key.properties con las contraseñas reales y el alias:
storePassword=CONTRASEÑA_REAL
keyPassword=CONTRASEÑA_REAL
keyAlias=bintrack
storeFile=bintrack-release-key.jks
Probar build release:
flutter build apk --release --dart-define=API_HOST=http://192.168.11.215:8000
Verificar firma:

& "C:\Users\camil\AppData\Local\Android\Sdk\build-tools\36.1.0\apksigner.bat" verify --verbose --print-certs C:\proyectos\bintrack_app\build\app\outputs\flutter-apk\app-release.apk

Importante
Si se pierde esta llave, puede ser difícil o imposible actualizar instalaciones firmadas con ella, especialmente si se distribuyen APK fuera de Play Store.
No compartir:
Archivo .jks
Contraseñas
key.properties
Estado actual
Fecha de creación de la llave: 04/07/2026
Estado:
APK release generado correctamente.
APK verificado con apksigner.
Firma release configurada en android/app/build.gradle.kts.