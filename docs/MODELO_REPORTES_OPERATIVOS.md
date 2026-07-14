# Modelo de reportes operativos

Este documento define una guía corta para ordenar los reportes futuros de BinTrack sin romper lo que ya funciona.

La prioridad es mantener la app simple, clara e intuitiva para el usuario.

---

## 1. Principio general

Los reportes deben responder preguntas concretas del negocio.

No deben obligar al usuario a interpretar datos técnicos.

La app debe mostrar información como:

```text
Cuánto vendí
Cuánto stock queda
Quién me debe envases
Qué ventas están pendientes
Qué pagos se registraron


2. Reportes/pantallas que ya existen
Actualmente la app ya tiene pantallas que funcionan como reportes operativos.
Inventario
Responde:
Cuánto stock hay disponible
Cuántos envases están llenos
Cuántos envases están en clientes
Qué disponibilidad existe por envase/producto
Fuente actual:
/api/inventario/
Ventas
Responde:
Qué ventas existen
Qué ventas están en borrador
Qué ventas están confirmadas
Qué ventas están pagadas
Qué ventas fueron canceladas
Fuente actual:
/api/ventas/sales/
Pagos
Responde:
Qué pagos fueron registrados
Qué venta fue pagada
Qué método de pago se usó
Fuente actual:
/api/pagos/
Comprobantes internos
Responde:
Qué comprobantes internos fueron generados
A qué venta pertenece cada comprobante
Fuente actual:
/api/facturas/
Nota: estos comprobantes no son boletas ni facturas tributarias.
Balance de envases
Responde:
Qué cliente debe envases
Cuántos envases recibió
Cuántos devolvió
Cuál es el saldo pendiente
Cuánto depósito está pendiente
Fuente actual:
/api/bins/balance/
Movimientos de envases
Responde:
Qué entradas, préstamos, devoluciones o bajas se registraron
Cómo se movieron los envases
3. Backend disponible
El backend ya tiene una base útil para reportes.
Dashboard de ventas
Existe lógica en backend para un dashboard de ventas.
Puede responder:
Ventas de hoy
Monto vendido hoy
Ventas del mes
Monto vendido del mes
Ventas confirmadas
Ventas pagadas
Ventas en borrador
Ventas canceladas
Este dashboard debería revisarse antes de crear uno nuevo.
Movimientos de inventario
El backend registra movimientos de inventario asociados a ventas.
Esto puede servir más adelante para trazabilidad:
Por qué bajó el stock
Qué venta descontó inventario
Qué producto se movió
4. Preguntas que faltan o pueden mejorar
Reportes futuros deseables:
Cuánto vendí este mes
Cuánto vendí por producto
Cuánto vendí por cliente
Qué productos tienen stock bajo
Qué presentaciones tienen stock disponible
Qué clientes tienen más envases pendientes
Qué ventas están pendientes de pago
Qué flujo tuvo un producto desde stock hasta venta
Qué reenvasados se realizaron
5. Reportes prioritarios
Para no extender demasiado el desarrollo, se recomienda avanzar por etapas.
Prioridad 1: Dashboard operativo simple
Debe mostrar:
Ventas de hoy
Monto vendido hoy
Ventas del mes
Monto vendido del mes
Ventas pendientes
Ventas pagadas
Objetivo:
Que el usuario entienda rápidamente cómo va su negocio.
Prioridad 2: Stock por presentación
Debe mostrar:
Producto
Envase/presentación
Stock disponible
Precio
Estado activo/inactivo
Ejemplo:
Ciruelas + Caja de Ciruelas: 90 disponibles
Ciruelas + Pallet Madera: 2 disponibles
Objetivo:
Que el usuario sepa qué puede vender.
Prioridad 3: Envases pendientes por cliente
Debe mostrar:
Cliente
Envase
Entregados
Devueltos
Saldo
Depósito pendiente
Objetivo:
Que el usuario sepa quién le debe envases.
6. Doctrina de implementación
Cada reporte debe cumplir estas reglas:
Ser fácil de entender
Usar lenguaje de negocio
No duplicar lógica innecesaria
No romper pantallas existentes
Implementarse por tramos pequeños
Validarse antes de pasar al siguiente tramo
7. Qué no hacer todavía
No crear un módulo de reportes demasiado grande desde el inicio.
No mezclar todos los datos en una sola pantalla confusa.
No implementar gráficos complejos antes de tener resúmenes simples.
No crear endpoints nuevos si ya existe información suficiente.
8. Plan recomendado
Etapa 1
Revisar el dashboard de ventas existente en backend.
Etapa 2
Conectarlo a Flutter si todavía no está conectado.
Etapa 3
Mostrar un dashboard simple en la app.
Etapa 4
Agregar stock por presentación.
Etapa 5
Mejorar reportes de envases pendientes.
Etapa 6
Diseñar reportes de reenvasado cuando el módulo exista.
9. Resumen
BinTrack ya tiene varias pantallas operativas útiles.
El siguiente paso no es crear reportes complejos, sino ordenar mejor la información existente para que el usuario responda rápido:
Cuánto vendió
Cuánto le queda
Quién le debe envases
Qué está pendiente

Luego:

```powershell
git status
Y hacemos commit + main.