# Modelo operativo: productos, envases, reempaque y reportes

## Objetivo

Documentar el modelo operativo real que BinTrack debe soportar para productos agrícolas/comerciales, envases retornables, unidades de venta, reempaque, ventas y reportes.

Este documento sirve como guía antes de modificar backend o Flutter.

---

## Problema detectado

Actualmente el sistema permite registrar productos, tipos de envase, inventario, ventas y movimientos de envases.

Pero existen casos reales donde un producto no se vende solamente en el mismo envase en que ingresó.

Ejemplos:

- Un pallet de cerezas puede contener muchas cajas.
- Un bin de peras puede vaciarse y reenvasarse en gamelas/cajas.
- Un producto puede entrar en bins, pero venderse por cajas.
- Un cliente puede deber envases retornables.
- El usuario necesita saber cuánto vendió, cuánto queda y en qué formato queda.

---

## Caso 1: pallet de cerezas

Ejemplo:

```text
Producto: Cerezas
Envase/contenedor: Pallet
Unidad interna: Caja
Equivalencia: 1 pallet = 80 cajas

Necesidades:
Registrar cuántas cajas contiene un pallet.
Vender por pallet completo.
Vender por cajas sueltas.
Saber cuántas cajas quedan.
Saber cuántos pallets completos quedan.
Saber si quedan cajas sueltas.
Ejemplo de stock:
Stock inicial: 2 pallets de cerezas
Equivalencia: 160 cajas
Venta: 15 cajas
Stock final:
- 1 pallet completo
- 65 cajas sueltas
Caso 2: bin de peras reenvasado en cajas/gamelas
Ejemplo:
Producto: Peras
Origen: 1 bin plástico lleno
Destino: cajas/gamelas
Resultado: 50 cajas de peras
Necesidades:
Registrar que el bin fue vaciado.
Registrar cuántas cajas salieron del bin.
Aumentar stock de cajas disponibles para venta.
Marcar el bin como vacío/disponible.
Mantener trazabilidad del movimiento.
Flujo:
Antes:
- 1 bin lleno de peras
- 0 cajas de peras

Reempaque:
- consumir 1 bin lleno
- producir 50 cajas/gamelas

Después:
- 0 bins llenos de peras
- 50 cajas/gamelas de peras
- 1 bin vacío disponible
Conceptos necesarios
1. Producto
Ejemplos:
Cerezas
Peras
Ciruelas
Manzanas
2. Envase retornable o contenedor físico
Ejemplos:
Bin plástico
Bin madera
Pallet
Este elemento puede tener vida propia:
entregado
devuelto
en cliente
disponible
dado de baja
3. Unidad o presentación de venta
Ejemplos:
Caja
Gamela
Kilo
Bolsa
Pallet completo
Bin completo
4. Equivalencia
Define cuántas unidades internas contiene una presentación mayor.
Ejemplos:
1 pallet de cerezas = 80 cajas
1 bin de peras = 50 cajas
1 caja = 10 kilos
5. Reempaque o transformación
Movimiento interno donde un producto cambia de formato.
Ejemplos:
Bin de peras -> cajas de peras
Pallet de cerezas -> cajas de cerezas
Caja grande -> cajas pequeñas
Modelo inicial recomendado
Para una primera versión funcional, se recomienda manejar stock por presentación.
Ejemplo:
Producto: Peras
Stock:
- 3 bins llenos
- 40 cajas
- 10 gamelas
Esto es más simple para el usuario que manejar todo únicamente por kilos o unidad base.
Más adelante se puede agregar unidad base si el negocio lo requiere.
Flujo propuesto: reempaque
Pantalla sugerida:
Reenvasar producto

Producto: Peras
Desde: Bin plástico
Cantidad origen: 1
Hacia: Caja/Gamela
Cantidad resultante: 50
Observación: Reempaque para venta por cajas
Resultado automático:
- Descuenta stock en formato origen
- Aumenta stock en formato destino
- Libera o actualiza estado del envase retornable
- Crea movimiento de trazabilidad
Relación con ventas
La venta debería permitir elegir presentación:
Producto: Peras
Vender como:
- Bin completo
- Caja
- Gamela
- Kilo
Al vender:
- Descuenta stock de la presentación elegida
- Registra venta
- Registra cliente
- Registra envases entregados si aplica
- Actualiza deuda de envases si corresponde
Reportes necesarios
Reportes de producto
Stock actual por producto
Stock por presentación
Stock disponible para venta
Productos con bajo stock
Reportes de ventas
Ventas por día
Ventas por cliente
Ventas por producto
Ventas por presentación
Ventas pagadas
Ventas pendientes
Reportes de envases
Quién debe bins/envases
Cuántos envases debe cada cliente
Depósitos pendientes
Historial de entregas
Historial de devoluciones
Envases dados de baja
Reportes de flujo / trazabilidad
Entradas de producto
Reempaques realizados
Ventas realizadas
Saldo final
Origen de productos vendidos
Ejemplo:
Lote: Peras - 03/07/2026
Entrada: 2 bins
Reempaque: 1 bin -> 50 cajas
Venta: 20 cajas
Saldo:
- 1 bin lleno
- 30 cajas
Principio de diseño
Cada acción importante debe crear un movimiento.
Ejemplos:
Entrada
Ajuste
Reempaque
Venta
Devolución
Baja
Movimiento de envase
Pago
Esto permite construir reportes confiables.
Roadmap sugerido
Etapa 1: Análisis
Revisar modelos actuales de backend.
Revisar cómo se maneja inventario actual.
Revisar cómo ventas descuenta stock.
Revisar cómo bins/envases se relacionan con ventas.
Etapa 2: Diseño mínimo
Definir presentaciones.
Definir equivalencias.
Definir reempaque.
Definir stock por presentación.
Etapa 3: Backend
Ajustar modelos.
Crear endpoints.
Crear migraciones.
Crear validaciones.
Crear reportes básicos.
Etapa 4: Flutter
Pantalla de presentaciones.
Pantalla de reempaque.
Ajustar ventas.
Ajustar inventario.
Ajustar reportes.
Etapa 5: Reportes
Stock actual.
Ventas.
Envases por cliente.
Flujo de producto.
Exportación PDF/Excel futura.
Pendiente de decisión
Preguntas clave antes de implementar:
¿El stock principal será por presentación o por unidad base?
¿Las equivalencias serán fijas o editables por producto?
¿Se manejarán lotes?
¿Se necesita trazabilidad por fecha/proveedor?
¿Se venderá por kilos además de cajas/envases?
¿Los envases internos como cajas/gamelas son retornables o consumibles?
Estado
Documento de análisis.
No implementado todavía.