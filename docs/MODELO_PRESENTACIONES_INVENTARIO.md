# Modelo de presentaciones e inventario - BinTrack

## Objetivo

Este documento define cómo BinTrack debe representar productos, envases, presentaciones comerciales, inventario, ventas y futuras transformaciones/reempaques.

La idea principal es permitir que el usuario nombre sus envases y presentaciones de forma libre, pero que la app pueda entender internamente qué significa cada registro.

## Decisión principal

BinTrack debe separar internamente estos conceptos:

```text
Producto
Envase físico
Presentación comercial
Inventario
Movimiento / transformación

Aunque el usuario vea nombres simples como:
Pallet de tomates
Caja de paltas
Bin azul
Gamela cosecha
la app debe poder entender la estructura detrás de esos nombres.
Conceptos
Producto
Representa la mercadería o fruta/verdura/artículo manejado por el usuario.
Ejemplos:
Tomate
Palta
Cereza
Pera
Uva
Manzana
Limón
Durazno
Modelo actual relacionado:
Product
Envase físico
Representa el contenedor físico nombrado por el usuario.
Ejemplos:
Bin azul
Bin madera
Pallet madera
Caja cartón
Gamela plástica
Saco
Bandeja
Cajón
Modelo actual relacionado:
BinType
Regla:
BinType debe seguir representando el envase físico/base.
No debe absorber toda la lógica comercial del producto.
Presentación comercial
Representa una combinación vendible o inventariable de:
Producto + Envase + Precio + Reglas comerciales
Ejemplos:
Caja de tomate 20 kg
Pallet de tomate 80 cajas
Bin de palta 400 kg
Caja de uva 8 kg
Gamela de pera 18 kg
Modelo actual relacionado:
ProductPresentation
Regla:
ProductPresentation será el modelo principal para representar presentaciones comerciales vendibles.
Actualmente ya une:
Product + BinType + precio
Esto es una buena base y no debe romperse.
Modelo conceptual
Product
  ↓
ProductPresentation
  ↓
BinType
Ejemplo:
Product: Tomate
BinType: Caja cartón
ProductPresentation: Caja de tomate 20 kg
Otro ejemplo:
Product: Tomate
BinType: Pallet madera
ProductPresentation: Pallet de tomate 80 cajas
Campos futuros recomendados para ProductPresentation
Los siguientes campos deberían agregarse de forma opcional para no romper datos actuales:
unidad_medida
cantidad_por_envase
envase_contenido
cantidad_envase_contenido
unidad_medida
Unidad principal de medida de la presentación.
Ejemplos:
kg
cajas
unidades
gamelas
sacos
cantidad_por_envase
Cantidad de producto contenida en el envase.
Ejemplos:
Caja tomate 20 kg:
cantidad_por_envase = 20
unidad_medida = kg

Bin palta 400 kg:
cantidad_por_envase = 400
unidad_medida = kg
envase_contenido
Envase interno contenido dentro de otro envase.
Ejemplo:
Pallet tomate 80 cajas:
envase_contenido = Caja
cantidad_envase_contenido
Cantidad de envases internos contenidos.
Ejemplo:
Pallet tomate 80 cajas:
cantidad_envase_contenido = 80
Inventario
Modelo actual relacionado:
Inventory
Actualmente el inventario trabaja con:
usuario + product + bin
Esto permite saber stock por producto y envase.
Ejemplo:
Tomate + Caja cartón = 120 cajas
Tomate + Pallet madera = 3 pallets
Palta + Bin azul = 10 bins
Esta lógica debe mantenerse por ahora para no romper ventas ni reportes actuales.
Ventas
Modelos actuales relacionados:
Sale
SaleItem
Actualmente SaleItem usa:
product
bin
cantidad
bins_cantidad
precio_unitario
Y Flutter agrega items usando:
presentation.productId
presentation.binTypeId
Esto confirma que la venta ya trabaja indirectamente con una presentación comercial.
Regla actual delicada
Actualmente existe una regla en ventas:
bins_cantidad debe ser igual a cantidad
Esto funciona para casos simples donde cada unidad vendida implica un envase entregado.
Ejemplo:
Venta de 5 bins = 5 envases entregados
Pero puede ser insuficiente para casos futuros:
Venta de 30 cajas desde 1 pallet
Venta parcial de un pallet
Venta por kg desde un bin
Reempaque de bin a cajas
Por ahora NO se debe cambiar esta regla sin diseñar bien el flujo de stock y envases.
Transformaciones / reempaque
Funcionalidad futura.
Debe permitir convertir stock de una presentación a otra.
Ejemplos:
1 bin de palta → 20 cajas de palta
1 pallet de tomate → 80 cajas de tomate
1 caja grande → 10 bandejas
Movimiento conceptual:
Origen:
Producto + presentación origen + cantidad

Destino:
Producto + presentación destino + cantidad resultante
Ejemplo:
Origen:
1 bin de palta

Destino:
20 cajas de palta
Efecto en inventario:
-1 bin de palta
+20 cajas de palta
Reportes futuros
Con este modelo se podrán construir reportes como:
Stock por producto
Stock por presentación
Stock equivalente
Pallets completos disponibles
Cajas sueltas disponibles
Producto reenvasado
Envases prestados por cliente
Depósitos pendientes
Ventas por producto
Ventas por presentación
Historial de transformaciones
Estrategia para no romper lo existente
La evolución debe hacerse por etapas.
Etapa 1
Documentar este modelo.
No tocar código.
Etapa 2
Agregar campos opcionales a ProductPresentation.
No tocar ventas.
No tocar inventario.
No tocar movimientos de bins.
Etapa 3
Exponer los nuevos campos en serializers/API.
Mantener compatibilidad con respuestas actuales.
Etapa 4
Actualizar Flutter para mostrar y capturar los nuevos campos.
Los campos deben ser opcionales.
Etapa 5
Agregar visualización de equivalencias.
Ejemplos:
1 pallet = 80 cajas
1 caja = 20 kg
Todavía sin transformar stock automáticamente.
Etapa 6
Diseñar módulo de transformación/reempaque.
Etapa 7
Actualizar ventas para soportar ventas parciales, unidades internas y envases no equivalentes a cantidad vendida.
Regla de diseño
El usuario debe poder nombrar sus envases y presentaciones libremente.
La app debe agregar estructura interna sin obligar al usuario a pensar como programador.
Ejemplo visible para usuario:
Pallet tomates
Estructura interna:
Producto: Tomate
Envase externo: Pallet
Contiene: Caja tomate 20 kg
Cantidad contenida: 80
Estado actual
Fecha: 06/07/2026
Estado:
Product existe.
BinType existe.
ProductPresentation existe.
Inventory existe.
Sale/SaleItem existen.
Ventas ya usan ProductPresentation desde Flutter.
La base actual permite evolucionar sin romper el sistema.
