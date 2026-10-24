import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bintrack_app/features/account/data/account_service.dart';
import 'package:bintrack_app/features/account/models/account_summary.dart';
import 'package:bintrack_app/features/account/presentation/account_page.dart';
import 'package:bintrack_app/features/account/presentation/account_shortcut.dart';
import 'package:bintrack_app/features/account/presentation/secondary_form_page.dart';

Map<String, dynamic> secondary(int id, {bool active = true}) => {
  'id': id,
  'username': 'operador$id',
  'email': 'u$id@example.test',
  'first_name': 'Operador',
  'last_name': 'Demo',
  'telefono': '',
  'activo': active,
};

Map<String, dynamic> summaryJson({
  List<Map<String, dynamic>> users = const [],
}) {
  final count = users.where((user) => user['activo'] == true).length;
  final plans = [
    for (var i = 0; i <= 2; i++)
      {'secundarios': i, 'precio_final_clp': 50000 + i * 10000},
  ];
  return {
    'titular': {'username': 'principal'},
    'secundarios_activos': count,
    'max_secundarios': 2,
    'adicional_alta_clp': 10000,
    'puede_agregar': count < 2,
    'requiere_revision': count > 2,
    'suscripcion_vigente': true,
    'fecha_fin': '2026-11-01T12:00:00Z',
    'plan_segun_usuarios': count > 2 ? null : plans[count],
    'planes': plans,
    'usuarios': users,
  };
}

class FakeAccountService extends AccountService {
  List<Map<String, dynamic>> users = [];
  bool failLoad = false, failSave = false;
  int loadCalls = 0, saveCalls = 0;
  Map<String, dynamic>? saved;

  @override
  Future<AccountSummary> load() async {
    loadCalls++;
    if (failLoad) {
      throw Exception(
        'Solo el principal puede administrar usuarios y suscripción.',
      );
    }
    return AccountSummary.fromJson(summaryJson(users: users));
  }

  @override
  Future<void> create(Map<String, dynamic> fields) async {
    saveCalls++;
    saved = fields;
    if (failSave) {
      throw AccountValidationException(
        'La cuenta admite como máximo dos secundarios activos.',
      );
    }
  }

  @override
  Future<void> update(int id, Map<String, dynamic> fields) async {
    saveCalls++;
    saved = fields;
    if (failSave) throw AccountValidationException('No se pudo guardar.');
    for (final user in users) {
      if (user['id'] == id) user.addAll(fields);
    }
  }
}

Future<void> showAccount(
  WidgetTester tester,
  FakeAccountService service,
) async {
  await tester.pumpWidget(MaterialApp(home: AccountPage(service: service)));
  await tester.pumpAndSettle();
}

Future<void> press(WidgetTester tester, String label) async {
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text(label),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle();
}

Future<void> fill(WidgetTester tester, String key, String value) async {
  final finder = find.byKey(ValueKey(key));
  await tester.scrollUntilVisible(
    finder,
    180,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.enterText(finder, value);
  await tester.pumpAndSettle();
}

void main() {
  test('Monthly tiers and final CLP formatting', () {
    expect(clp(50000), r'$50.000');
    for (var count = 0; count <= 2; count++) {
      final summary = AccountSummary.fromJson(
        summaryJson(users: [for (var i = 0; i < count; i++) secondary(i)]),
      );
      expect(summary.selectedPlan!.price, 50000 + count * 10000);
      expect(summary.canAdd, count < 2);
    }
  });

  testWidgets(
    'Management shortcut is hidden unless server explicitly allows it',
    (tester) async {
      for (final profile in <Map<String, dynamic>?>[
        null,
        {},
        {'puede_gestionar_cuenta': false},
        {'es_usuario_asociado': true, 'rol': 'admin'},
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AccountShortcut(profile: profile)),
          ),
        );
        expect(find.text('Usuarios y suscripción'), findsNothing);
      }
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccountShortcut(profile: {'puede_gestionar_cuenta': true}),
          ),
        ),
      );
      expect(find.text('Usuarios y suscripción'), findsOneWidget);
    },
  );

  testWidgets('Shows reference amount and makes clear no charge is made', (
    tester,
  ) async {
    await showAccount(tester, FakeAccountService());
    expect(find.text(r'$50.000 CLP / mes'), findsOneWidget);
    expect(find.textContaining('No se realizan cobros'), findsOneWidget);
    expect(find.text('0 de 2 secundarios activos'), findsOneWidget);
  });

  testWidgets(
    'Create and reactivate disabled at capacity; no source data deleted',
    (tester) async {
      final service = FakeAccountService()
        ..users = [secondary(1), secondary(2), secondary(3, active: false)];
      await showAccount(tester, service);
      await tester.scrollUntilVisible(
        find.text('Agregar secundario'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final add = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Agregar secundario'),
          matching: find.byWidgetPredicate((widget) => widget is FilledButton),
        ),
      );
      expect(add.onPressed, isNull);
      await tester.scrollUntilVisible(
        find.text('Reactivar'),
        -150,
        scrollable: find.byType(Scrollable).first,
      );
      final reactivate = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('Reactivar'),
          matching: find.byWidgetPredicate((widget) => widget is TextButton),
        ),
      );
      expect(reactivate.onPressed, isNull);
      expect(service.users.length, 3);
      expect(service.saveCalls, 0);
    },
  );

  testWidgets('Creation warns about full additional price and shared expiry', (
    tester,
  ) async {
    final service = FakeAccountService();
    await showAccount(tester, service);
    await press(tester, 'Agregar secundario');
    expect(find.textContaining(r'$10.000 completo'), findsOneWidget);
    expect(find.textContaining('sin prorrateo'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(service.saveCalls, 0);
    expect(find.byType(SecondaryFormPage), findsNothing);
  });

  testWidgets('Create validates fields then sends only permitted values', (
    tester,
  ) async {
    final service = FakeAccountService();
    await showAccount(tester, service);
    await press(tester, 'Agregar secundario');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await press(tester, 'Guardar usuario');
    expect(service.saveCalls, 0);
    // Start at top again after the validation attempt.
    await tester.drag(find.byType(ListView), const Offset(0, 2000));
    await tester.pumpAndSettle();
    await fill(tester, 'username', 'nuevo_operador');
    await fill(tester, 'email', 'nuevo@example.test');
    await fill(tester, 'password', 'Local-only!9458');
    await press(tester, 'Guardar usuario');
    expect(service.saveCalls, 1);
    expect(service.saved!['username'], 'nuevo_operador');
    expect(service.saved!['password'], 'Local-only!9458');
    expect(service.saved!.containsKey('titular'), isFalse);
    expect(service.saved!.containsKey('rol'), isFalse);
    expect(find.byType(SecondaryFormPage), findsNothing);
    expect(service.loadCalls, 2);
  });

  testWidgets('Deactivation requires confirmation and refreshes list', (
    tester,
  ) async {
    final service = FakeAccountService()..users = [secondary(1)];
    await showAccount(tester, service);
    await press(tester, 'Desactivar');
    expect(
      find.textContaining('Su cuenta y su historial se conservarán'),
      findsOneWidget,
    );
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(service.saved, {'activo': false});
    expect(service.users.single['activo'], false);
    expect(service.loadCalls, 2);
  });

  testWidgets(
    'Access failure does not expose management actions and supports retry',
    (tester) async {
      final service = FakeAccountService()..failLoad = true;
      await showAccount(tester, service);
      expect(find.textContaining('Solo el principal'), findsOneWidget);
      expect(find.text('Agregar secundario'), findsNothing);
      service.failLoad = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Principal: principal'), findsOneWidget);
    },
  );

  testWidgets(
    'Server validation keeps edits on screen and username stays locked',
    (tester) async {
      final service = FakeAccountService()..failSave = true;
      await tester.pumpWidget(
        MaterialApp(
          home: SecondaryFormPage(
            service: service,
            user: SecondaryUser.fromJson(secondary(1)),
          ),
        ),
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('username')))
            .enabled,
        false,
      );
      expect(find.byKey(const ValueKey('password')), findsNothing);
      await fill(tester, 'first_name', 'Nombre corregido');
      await press(tester, 'Guardar usuario');
      expect(find.byType(SecondaryFormPage), findsOneWidget);
      expect(find.text('No se pudo guardar.'), findsOneWidget);
      expect(service.saved!['first_name'], 'Nombre corregido');
      expect(service.saved!.containsKey('username'), isFalse);
      expect(service.saved!.containsKey('password'), isFalse);
    },
  );
}
