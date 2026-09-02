# Modelo de venta por kilos

## Objetivo

Permitir que BinTrack registre ventas donde el producto se cobra por kilos pesados, pero el movimiento físico sigue ocurriendo por envases.

Este caso aplica cuando la bodega recibe o maneja fruta en bins, cajas u otros envases completos, y el cliente compra el contenido valorizado por peso.

Ejemplo:

- Producto: Peras
- Envase: Bin
- Precio kilo: $600
- Peso del bin: 420 kg
- Total venta: 420 x 600 = $252.000
- Movimiento físico: sale 1 bin lleno
- Balance de envases: el cliente queda con 1 bin pendiente, salvo que devuelva uno vacío

## Regla principal

El tipo de cobro define cómo se calcula el dinero.

El envase define qué se mueve físicamente.

Por lo tanto:

- Si se cobra por envase, el total se calcula por cantidad de envases.
- Si se cobra por kilo, el total se calcula por kilos pesados.
- Si la presentación usa un envase físico, la venta siempre mueve ese envase.
- Una venta por kilos no significa venta suelta necesariamente.
- En BinTrack, una venta por kilos puede representar la venta de un bin completo pesado en bodega.

## Presentaciones

Una presentación representa la forma en que un producto se ofrece al cliente.

Ejemplos:

- Peras + Bin
- Peras + Caja plástica
- Peras + Caja exportación
- Naranjas + Bin

Cada presentación puede tener una forma de cobro:

- Por envase completo
- Por kilo pesado

Ejemplos:

| Producto | Envase | Tipo de cobro | Precio |
|---|---|---:|---:|
| Peras | Bin | Por envase | $250.000 |
| Peras | Bin | Por kilo | $600 |
| Peras | Caja plástica | Por envase | $10.000 |
| Peras | Caja exportación | Por envase | $20.000 |

## Venta por envase

Cuando una presentación se cobra por envase:

- El usuario ingresa cantidad de envases.
- El subtotal se calcula como cantidad x precio.
- El stock lleno baja según la cantidad de envases.
- El balance de envases aumenta según la cantidad de envases entregados al cliente.

Ejemplo:

- Presentación: Peras + Bin
- Tipo cobro: Por envase
- Precio: $250.000
- Cantidad vendida: 2 bins

Resultado:

- Subtotal: 2 x 250.000 = $500.000
- Stock lleno baja en 2 bins
- Cliente queda con 2 bins entregados en balance

## Venta por kilo

Cuando una presentación se cobra por kilo:

- El usuario ingresa cantidad de envases vendidos.
- El usuario ingresa kilos pesados.
- El subtotal se calcula como kilos x precio kilo.
- El stock lleno baja según la cantidad de envases vendidos.
- El balance de envases aumenta según la cantidad de envases entregados al cliente.

Ejemplo:

- Presentación: Peras + Bin
- Tipo cobro: Por kilo
- Precio kilo: $600
- Cantidad de envases: 1 bin
- Kilos pesados: 420 kg

Resultado:

- Subtotal: 420 x 600 = $252.000
- Stock lleno baja en 1 bin
- Cliente queda con 1 bin entregado en balance

## Devolución de envases

Si el cliente devuelve envases vacíos después de la venta, se registra en:

Bodega > Movimientos > Devolución

Ejemplo:

- Cliente: Pedro Perez
- Envase: Bin
- Cantidad devuelta: 1

Resultado:

- El saldo de envases del cliente baja en 1.
- Los envases vacíos disponibles aumentan en 1.

## Cliente trae envases de reposición al momento de la venta

Si el cliente se lleva 1 bin lleno y entrega 1 bin vacío en el mismo momento:

1. Se confirma la venta.
2. La venta registra 1 bin entregado al cliente.
3. Se registra una devolución de 1 bin vacío.
4. El balance final del cliente queda igualado.

## Decisión de diseño

No se debe crear "Kilo" como tipo de envase.

El kilo es una forma de cobro, no un envase físico.

La estructura recomendada es:

### ProductPresentation

Agregar:

- tipo_cobro

Valores posibles:

- envase
- kilo

### SaleItem

Agregar o preparar campos para:

- cantidad de envases vendidos
- kilos pesados, cuando aplique
- precio unitario según tipo de cobro
- subtotal calculado según tipo de cobro

## Compatibilidad con el modelo actual

La lógica actual de BinTrack ya descuenta stock lleno y registra envases entregados al cliente al confirmar una venta.

La venta por kilos debe reutilizar esa lógica.

Solo cambia la forma de calcular el subtotal:

- Por envase: cantidad x precio
- Por kilo: kilos x precio

No cambia el movimiento físico:

- Stock lleno baja por cantidad de envases
- Balance sube por cantidad de envases entregados