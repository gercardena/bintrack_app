# Comandos para correr BinTrack App

## Desarrollo local normal

Comando:

```powershell
flutter run
Usa la IP por defecto configurada en:
lib/core/config/api_config.dart
Desarrollo local con otra IP
Usar cuando el PC cambie de WiFi o cambie su IP local.
Revisar la IP actual del PC:
ipconfig
Correr la app indicando la IP:
flutter run --dart-define=API_HOST=http://NUEVA_IP:8000
Ejemplo:
flutter run --dart-define=API_HOST=http://192.168.11.120:8000
Backend local Django
Para que el teléfono pueda conectarse al backend:
cd C:\proyectos\BINTRACK
python manage.py runserver 0.0.0.0:8000
Probar conexión desde el teléfono
Abrir en el navegador del teléfono:
http://IP_DEL_PC:8000/api/
Ejemplo:
http://192.168.11.215:8000/api/
Si eso no abre, la app tampoco podrá conectarse.
Build futuro
APK de prueba o demo:
flutter build apk --dart-define=API_HOST=https://api.bintrack.cl
Play Store:
flutter build appbundle --dart-define=API_HOST=https://api.bintrack.cl
Limpieza antes de commit
Si Flutter modifica archivos generados de Linux, macOS o Windows:
git restore linux/flutter/generated_plugin_registrant.cc linux/flutter/generated_plugins.cmake macos/Flutter/GeneratedPluginRegistrant.swift windows/flutter/generated_plugin_registrant.cc windows/flutter/generated_plugins.cmake
Luego revisar:
git status

Después de guardar, corre:

```powershell
git status