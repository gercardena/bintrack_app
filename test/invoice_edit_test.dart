import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bintrack_app/features/invoices/data/invoices_service.dart';
import 'package:bintrack_app/features/invoices/models/invoice_model.dart';
import 'package:bintrack_app/features/invoices/presentation/edit_invoice_page.dart';
import 'package:bintrack_app/features/invoices/presentation/invoice_history_page.dart';

Invoice invoice({int version = 0, String observations = ''}) => Invoice(
  id: 1,
  saleId: 10,
  saleNumero: 'V0010',
  saleEstado: 'paid',
  numero: 'F0010',
  clienteNombre: 'Cliente demo',
  clienteRut: '12345678-9',
  clienteDireccion: 'Dirección original',
  subtotal: 100,
  iva: 0,
  total: 100,
  fechaEmision: '2026-10-21T12:00:00Z',
  items: [],
  version: version,
  observaciones: observations,
);

class FakeInvoicesService extends InvoicesService {
  int calls = 0;
  bool fail = false;
  Map<String, Object>? submitted;
  List<Map<String, dynamic>> history = [];

  @override
  Future<Invoice> editar(
    Invoice original, {
    required String nombre,
    required String direccion,
    required String observaciones,
  }) async {
    calls++;
    submitted = {
      'version': original.version,
      'nombre': nombre,
      'direccion': direccion,
      'observaciones': observaciones,
    };
    if (fail) throw Exception('Otra persona modificó este comprobante.');
    return invoice(version: original.version + 1, observations: observaciones);
  }

  @override
  Future<List<Map<String, dynamic>>> historial(int invoiceId) async => history;
}

Future<void> openEditor(
  WidgetTester tester,
  FakeInvoicesService service, {
  ValueChanged<Invoice?>? onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<Invoice>(
                MaterialPageRoute(
                  builder: (_) => EditInvoicePage(
                    invoice: invoice(version: 3),
                    service: service,
                  ),
                ),
              );
              onResult?.call(result);
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Guardar cambios'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Guardar cambios'));
  await tester.pumpAndSettle();
}

void main() {
  test('Older responses remain readable; new fields are parsed', () {
    expect(Invoice.fromJson({}).observaciones, '');
    expect(Invoice.fromJson({}).version, 0);
    final parsed = Invoice.fromJson({'version': 2, 'observaciones': 'Entrega'});
    expect(parsed.version, 2);
    expect(parsed.observaciones, 'Entrega');
  });

  testWidgets(
    'Only three editable fields; save trims and returns updated version',
    (tester) async {
      final service = FakeInvoicesService();
      Invoice? result;
      await openEditor(tester, service, onResult: (value) => result = value);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.textContaining('RUT: 12345678-9'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        ' Cliente corregido ',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        ' Dirección nueva ',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        ' Entrega por la tarde ',
      );
      await save(tester);
      expect(service.submitted, {
        'version': 3,
        'nombre': 'Cliente corregido',
        'direccion': 'Dirección nueva',
        'observaciones': 'Entrega por la tarde',
      });
      expect(result?.version, 4);
      expect(find.byType(EditInvoicePage), findsNothing);
    },
  );

  testWidgets('Empty name is rejected without sending a request', (
    tester,
  ) async {
    final service = FakeInvoicesService();
    await openEditor(tester, service);
    await tester.enterText(find.byType(TextFormField).first, '  ');
    await save(tester);
    expect(service.calls, 0);
    expect(find.text('El nombre es obligatorio.'), findsOneWidget);
  });

  testWidgets('Save failure keeps entered data and does not close the form', (
    tester,
  ) async {
    final service = FakeInvoicesService()..fail = true;
    await openEditor(tester, service);
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Conservar esta nota',
    );
    await save(tester);
    expect(find.byType(EditInvoicePage), findsOneWidget);
    expect(find.textContaining('Otra persona modificó'), findsOneWidget);
    expect(find.text('Conservar esta nota'), findsOneWidget);
    expect(service.calls, 1);
  });

  testWidgets('History shows author and before/after values', (tester) async {
    final service = FakeInvoicesService()
      ..history = [
        {
          'usuario_nombre': 'operador',
          'fecha': '2026-10-21T12:00:00Z',
          'cambios': {
            'observaciones': {'antes': 'Mañana', 'despues': 'Tarde'},
          },
        },
      ];
    await tester.pumpWidget(
      MaterialApp(home: InvoiceHistoryPage(invoiceId: 1, service: service)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('operador'), findsOneWidget);
    expect(find.text('Antes: Mañana\nDespués: Tarde'), findsOneWidget);
  });

  testWidgets('Empty history is explained', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InvoiceHistoryPage(invoiceId: 1, service: FakeInvoicesService()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Este comprobante aún no tiene modificaciones.'),
      findsOneWidget,
    );
  });
}
