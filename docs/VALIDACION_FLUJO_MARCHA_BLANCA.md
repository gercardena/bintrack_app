# Validación de flujo de marcha blanca

## Objetivo

Documentar el flujo probado desde una base operativa limpia para confirmar que la app permite registrar una operación completa sin choques de uso ni errores técnicos principales.

Este documento funciona como checklist práctico para pruebas de marcha blanca con un usuario real.

## Contexto de la prueba

- App: BinTrack Flutter.
- Backend: Django + PostgreSQL.
- Usuario probado: usuario con suscripción activa.
- Base de datos: limpia de datos operativos antes de iniciar.
- Se conservaron usuarios, plan y suscripción.
- Fecha de validación: 2026-08-02.

## Flujo validado

### 1. Login

Resultado esperado:

- El usuario puede iniciar sesión.
- Home carga correctamente.
- Se muestra estado de suscripción activa.

Resultado observado:

- Correcto.

### 2. Crear cliente

Acción:

- Crear un cliente nuevo para usarlo en ventas, pagos y movimientos con cliente.

Resultado esperado:

- Cliente creado correctamente.
- Cliente aparece disponible en los módulos que lo necesitan.

Resultado observado:

- Correcto.

### 3. Crear tipo de envase

Acción:

- Crear un envase físico, por ejemplo `Bin Gris`.

Resultado esperado:

- El envase queda disponible para movimientos, inventario y presentaciones de producto.

Resultado observado:

- Correcto.

### 4. Registrar entrada de envases al almacén

Acción:

- Registrar una entrada al almacén del envase creado.
- Ejemplo:
  - Tipo: Entrada al almacén.
  - Envase: Bin Gris.
  - Cantidad: 2.
  - Referencia: Stock inicial.

Resultado esperado:

- La entrada no debe pedir cliente.
- La entrada aumenta la disponibilidad física de envases.
- El usuario entiende que los envases entran al almacén, no a un cliente.

Resultado observado:

- Correcto.

Regla validada:

- Entrada al almacén no se asocia a cliente.
- Préstamo/devolución sí se asocian a cliente.

### 5. Crear producto

Acción:

- Crear producto, por ejemplo `Limones`.

Resultado esperado:

- Producto creado correctamente.
- Producto queda disponible para crear presentaciones.

Resultado observado:

- Correcto.

### 6. Crear presentación

Acción:

- Crear presentación del producto usando el envase creado.
- Ejemplo:
  - Producto: Limones.
  - Envase: Bin Gris.
  - Precio: 100000.

Resultado esperado:

- El selector de envase debe mostrar visualmente el envase seleccionado.
- La presentación debe quedar creada.
- Si el producto ya usa todos los envases disponibles, la pantalla no debe permitir duplicar presentación.

Resultado observado:

- Correcto.

Regla validada:

- Un producto no duplica presentación con el mismo envase.

### 7. Cargar stock

Acción:

- Cargar stock inicial o editar stock de la presentación.
- Ejemplo:
  - Stock cargado: 2.

Resultado esperado:

- El sistema permite cargar stock si existen envases físicos disponibles.
- El sistema bloquea cargar más stock que envases disponibles.

Resultado observado:

- Stock 2 cargó correctamente.
- Intentar stock 4 fue bloqueado porque solo había 2 envases físicos disponibles.

Regla validada:

- El stock lleno no puede superar la disponibilidad física de envases.

### 8. Crear venta

Acción:

- Crear venta con el producto/presentación.
- Ejemplo:
  - Limones + Bin Gris.
  - Cantidad: 1.

Resultado esperado:

- Venta creada correctamente.
- Producto/presentación aparece disponible para agregar a la venta.

Resultado observado:

- Correcto.

### 9. Confirmar venta

Acción:

- Confirmar la venta creada.

Resultado esperado:

- La venta cambia de estado.
- El inventario se descuenta según la cantidad vendida.

Resultado observado:

- Correcto.

### 10. Registrar pago

Acción:

- Registrar pago asociado a la venta.

Resultado esperado:

- Pago registrado correctamente.
- Venta queda reflejada como pagada o con pago asociado, según el flujo actual.

Resultado observado:

- Correcto.

### 11. Ver comprobante

Acción:

- Revisar comprobante generado o disponible para la venta.

Resultado esperado:

- El comprobante aparece correctamente.
- La información principal de la venta se conserva.

Resultado observado:

- Correcto.

### 12. Ver inventario

Acción:

- Revisar módulo de inventario.

Resultado esperado:

- El inventario refleja el stock posterior a la venta.
- La información se entiende según envases físicos y envases llenos.

Resultado observado:

- Correcto.

### 13. Ver balance de envases

Acción:

- Revisar balance de envases.

Resultado esperado:

- El balance diferencia envases prestados/debidos por cliente.
- Una entrada al almacén no genera deuda de cliente.

Resultado observado:

- Correcto.

## Correcciones aplicadas durante la validación

### Entrada de envases

Antes:

- La pantalla de movimientos asociaba visualmente la entrada a un cliente.
- Esto confundía el flujo porque parecía que la entrada era para el cliente y no para el almacén.

Después:

- Entrada al almacén no exige cliente.
- Baja de envases no exige cliente.
- Préstamo a cliente exige cliente.
- Devolución de cliente exige cliente.

### Selector de envase en presentación

Antes:

- Al seleccionar un envase en “Crear presentación”, el campo quedaba visualmente en blanco aunque guardaba bien.

Después:

- El envase seleccionado se ve correctamente antes de guardar.

## Conclusión

El flujo principal de marcha blanca quedó validado desde una base operativa limpia.

El sistema permite:

1. Cargar envases físicos al almacén.
2. Crear productos.
3. Relacionar productos con envases mediante presentaciones.
4. Cargar stock respetando disponibilidad física.
5. Crear y confirmar ventas.
6. Registrar pagos.
7. Revisar comprobantes.
8. Revisar inventario.
9. Revisar balance de envases.

## Pendientes sugeridos

- Mejorar el mensaje cuando un producto ya no tiene envases disponibles para nuevas presentaciones.
- Revisar textos de ayuda en módulos relacionados para mantener el flujo simple e intuitivo.
- Repetir la prueba con más de un envase y más de un producto.
- Repetir la prueba con préstamo y devolución de envases a cliente.