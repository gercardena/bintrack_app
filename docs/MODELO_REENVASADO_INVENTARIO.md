# Modelo de reenvasado e inventario

Este documento describe el modelo futuro para manejar operaciones donde un producto cambia de presentación.

Ejemplos:

- Un pallet se transforma en cajas.
- Un bin se vacía y se envasa en cajas.
- Una caja grande se divide en bandejas.
- Un saco se divide en bolsas.

Este flujo todavía no debe implementarse sin diseño previo, porque afecta inventario, envases, ventas y reportes.

---

## 1. Problema que resuelve

Actualmente BinTrack permite crear presentaciones como:

```text
Ciruelas + Caja de Ciruelas
Ciruelas + Pallet Madera

También permite indicar que una presentación contiene otra:
1 Pallet Madera contiene 80 Caja de Ciruelas
Pero vender o editar una presentación no convierte automáticamente el stock entre ellas.
Ejemplo actual:
Stock Ciruelas + Pallet Madera: 2
Stock Ciruelas + Caja de Ciruelas: 100
Si se vende 1 pallet:
Stock Pallet baja de 2 a 1
Stock Caja sigue en 100
Eso es correcto para la lógica actual, porque se vendió un pallet completo.
Pero hay otro caso distinto:
El usuario abre 1 pallet y lo transforma en 80 cajas para venderlas por separado.
Ese caso no es una venta. Es una operación de reenvasado o conversión de inventario.
2. Concepto principal
El reenvasado es una operación interna de bodega.
No representa una venta.
No representa un pago.
No representa una factura.
No representa un préstamo a cliente.
Representa transformar stock de una presentación origen en stock de una presentación destino.
Ejemplo:
Origen:
Ciruelas + Pallet Madera
Cantidad usada: 1

Destino:
Ciruelas + Caja de Ciruelas
Cantidad generada: 80
Resultado esperado:
Stock Pallet Madera baja en 1
Stock Caja de Ciruelas sube en 80
3. Ejemplo completo: pallet a cajas
Estado inicial:
Ciruelas + Pallet Madera: 2 unidades
Ciruelas + Caja de Ciruelas: 100 unidades
Operación:
Reenvasar 1 pallet de ciruelas en 80 cajas
Estado final:
Ciruelas + Pallet Madera: 1 unidad
Ciruelas + Caja de Ciruelas: 180 unidades
4. Ejemplo completo: bin a cajas
Estado inicial:
Peras + Bin Azul: 5 unidades
Peras + Caja Peras 10 kg: 0 unidades
Operación:
Reenvasar 1 bin de peras en 60 cajas
Estado final:
Peras + Bin Azul: 4 unidades
Peras + Caja Peras 10 kg: 60 unidades
5. Qué debe pasar con los envases
Este punto necesita diseño cuidadoso.
Cuando se transforma una presentación, puede pasar una de estas cosas:
Caso A: el envase origen sigue ocupado
Ejemplo:
Se vende 1 pallet completo.
En este caso:
El pallet sale como producto vendido.
No hay reenvasado.
Caso B: el envase origen queda vacío
Ejemplo:
Se abre 1 pallet y se sacan las cajas.
En este caso, puede que:
El pallet vuelva a estar disponible como envase vacío.
Caso C: el envase destino consume envases disponibles
Ejemplo:
Se crean 80 cajas de ciruelas.
La app debe decidir si esas 80 cajas:
ya venían dentro del pallet;
o se consumen desde envases vacíos disponibles;
o no se controlan como retornables.
Esto debe quedar configurable o bien definido por reglas.
6. Reglas de negocio propuestas
Regla 1
Una venta descuenta stock de la presentación vendida.
Ejemplo:
Venta de 1 pallet => baja 1 pallet.
No debe descontar cajas automáticamente.
Regla 2
Una conversión de inventario debe ser una operación explícita.
Ejemplo:
Convertir 1 pallet en 80 cajas.
Solo esa operación debe aumentar stock de cajas y reducir stock de pallets.
Regla 3
El usuario debe confirmar la conversión antes de aplicarla.
La app debería mostrar algo como:
Vas a convertir:
1 Ciruelas + Pallet Madera

En:
80 Ciruelas + Caja de Ciruelas
Regla 4
No se debe permitir convertir más stock del disponible.
Ejemplo:
Si hay 2 pallets, no se pueden convertir 3.
Regla 5
La operación debe quedar registrada en historial.
Ejemplo:
Fecha: 13/07/2026
Operación: Reenvasado
Origen: Ciruelas + Pallet Madera
Cantidad origen: 1
Destino: Ciruelas + Caja de Ciruelas
Cantidad destino: 80
Usuario: gerson
Referencia: Reenvasado interno
7. Campos posibles para un modelo futuro
Un modelo futuro podría llamarse:
InventoryConversion
Campos posibles:
usuario
product
presentacion_origen
cantidad_origen
presentacion_destino
cantidad_destino
fecha
referencia
observacion
Si se decide controlar envases vacíos, también podría incluir:
devuelve_envase_origen
consume_envases_destino
8. Pantalla futura sugerida
Nombre sugerido:
Reenvasar producto
Flujo:
1. Seleccionar producto
2. Seleccionar presentación origen
3. Ingresar cantidad origen
4. Seleccionar presentación destino
5. Ingresar cantidad destino
6. Revisar resumen
7. Confirmar reenvasado
Ejemplo visual:
Producto: Ciruelas

Origen:
Pallet Madera
Cantidad: 1

Destino:
Caja de Ciruelas
Cantidad generada: 80

Resumen:
Se descontará 1 pallet.
Se agregarán 80 cajas.
9. Qué no se debe hacer todavía
No implementar conversión automática al vender.
Ejemplo que NO debe hacerse por ahora:
Venta de 1 pallet => descontar automáticamente 80 cajas.
Eso puede ser incorrecto, porque vender un pallet completo no es lo mismo que abrirlo y reenvasarlo.
10. Plan por etapas
Etapa 1: documentar regla actual
La venta descuenta solo la presentación vendida.
La relación “contiene” es informativa.
El stock de cajas y pallets se maneja por separado.
Etapa 2: diseñar modelo backend
Crear modelo de conversión.
Definir validaciones.
Registrar historial.
Etapa 3: crear API
Endpoint para crear conversión.
Endpoint para listar conversiones.
Etapa 4: crear pantalla Flutter
Formulario de reenvasado.
Resumen antes de confirmar.
Mensajes claros para el usuario.
Etapa 5: reportes
Reporte de conversiones realizadas.
Flujo de productos por presentación.
Trazabilidad de origen y destino.
11. Resumen
BinTrack ya permite representar presentaciones relacionadas, como:
1 pallet contiene 80 cajas.
Pero la transformación real de stock debe ser una acción explícita.
Esto protege la integridad del inventario y evita descontar stock de forma incorrecta.

Luego:

```powershell
git status
Y lo subimos a develop y main.