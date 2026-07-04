este contenido:
# Checklist de prueba release - BinTrack App

## Hito

Primera APK release funcional instalada y probada en teléfono real.

## Fecha

2026-07-03

## Rama

```text
develop / main
APK generado
build/app/outputs/flutter-apk/app-release.apk
Comando usado
flutter build apk --release --dart-define=API_HOST=http://192.168.11.215:8000
Instalación
APK instalado en teléfono Android mediante:
flutter install --release
Condiciones de prueba
Teléfono desconectado del cable USB.
Teléfono en la misma red WiFi que el PC.
Backend Django corriendo en el PC.
Backend levantado con:
python manage.py runserver 0.0.0.0:8000
Resultado general
Prueba release exitosa.
La app abrió desde el ícono BinTrack, permitió iniciar sesión y navegó por módulos principales usando el backend local.
Endpoints validados
POST /api/auth/login/ 200
GET /api/accounts/user/profile/ 200
GET /api/clientes/ 200
GET /api/bins/types/ 200
GET /api/bins/clientes/ 200
GET /api/bins/movements/ 200
GET /api/bins/balance/ 200
GET /api/productos/ 200
GET /api/productos/presentations/ 200
GET /api/inventario/ 200
GET /api/ventas/sales/ 200
GET /api/pagos/ 200
GET /api/facturas/ 200
Módulos revisados
Login
Perfil de usuario
Clientes
Tipos de envase
Clientes con envases
Movimientos de envases
Balance de envases
Productos
Presentaciones
Inventario
Ventas
Pagos
Comprobantes de venta
Observaciones
La app usa actualmente backend local por HTTP.
android:usesCleartextTraffic="true" se mantiene temporalmente para desarrollo local.
Para producción se debe usar backend público con HTTPS.
El ícono de la app sigue pendiente de personalización.
La firma release definitiva todavía está pendiente.
Esta APK no es todavía para Play Store.
Pendientes antes de Play Store
Crear ícono definitivo de BinTrack.
Configurar firma release real.
Usar backend público HTTPS.
Cambiar configuración de red para producción.
Revisar modelo de suscripción.
Generar Android App Bundle .aab.