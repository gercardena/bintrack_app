import 'package:bintrack_app/features/clientes/models/cliente.dart';
import 'package:bintrack_app/features/sales/presentation/sale_client_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final clientes = [
    Cliente(
      id: 1,
      nombre: 'Agrícola Santa Rosa',
      rut: '76.086.428-5',
      activo: true,
    ),
    Cliente(id: 2, nombre: 'Pedro Pérez', rut: '12345678-K', activo: true),
    Cliente(
      id: 3,
      nombre: 'Cliente inactivo',
      rut: '11111111-1',
      activo: false,
    ),
  ];

  Future<void> openPicker(
    WidgetTester tester,
    ValueChanged<Cliente?> onResult,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                onResult(
                  await showDialog<Cliente>(
                    context: context,
                    builder: (_) =>
                        SaleClientPicker(clientes: clientes, selectedId: 1),
                  ),
                );
              },
              child: const Text('Elegir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Elegir'));
    await tester.pumpAndSettle();
  }

  testWidgets('Busca por nombre sin tildes y RUT con o sin formato', (
    tester,
  ) async {
    Cliente? selected;
    await openPicker(tester, (value) => selected = value);
    expect(find.text('Cliente inactivo'), findsNothing);
    await tester.enterText(find.byType(TextField), 'AGRICOLA');
    await tester.pump();
    expect(find.text('Agrícola Santa Rosa'), findsOneWidget);
    expect(find.text('Pedro Pérez'), findsNothing);
    await tester.enterText(find.byType(TextField), '760864285');
    await tester.pump();
    expect(find.text('Agrícola Santa Rosa'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '12.345.678-k');
    await tester.pump();
    expect(find.text('Pedro Pérez'), findsOneWidget);
    await tester.tap(find.text('Pedro Pérez'));
    await tester.pumpAndSettle();
    expect(selected?.id, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sin resultados, limpiar y cancelar no selecciona otro cliente', (
    tester,
  ) async {
    Cliente? result = clientes.first;
    await openPicker(tester, (value) => result = value);
    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pump();
    expect(
      find.text('No hay clientes activos que coincidan con la búsqueda.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Limpiar búsqueda'));
    await tester.pump();
    expect(find.text('Agrícola Santa Rosa'), findsOneWidget);
    expect(find.text('Pedro Pérez'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });
}
