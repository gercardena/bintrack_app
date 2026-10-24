import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:bintrack_app/core/auth/subscription_access.dart';
import 'package:bintrack_app/core/auth/user_controller.dart';
import 'package:bintrack_app/core/api/subscription_response.dart';
import 'package:bintrack_app/core/widgets/subscription_status_card.dart';

Map<String, dynamic> profile(String state, {bool owner = true}) => {
  'puede_gestionar_cuenta': owner,
  'suscripcion_acceso': {
    'estado': state,
    'puede_operar': state == 'activa' || state == 'en_gracia',
    'fecha_fin': '2026-10-20T15:00:00Z',
    'gracia_hasta': '2026-10-23T15:00:00Z',
  },
};

void main() {
  tearDown(() => UserController().clear());

  test(
    'An in-flight profile refresh cannot restore a logged-out session',
    () async {
      final controller = UserController();
      final pending = Completer<Map<String, dynamic>>();
      final loading = controller.loadUser(loader: () => pending.future);
      controller.clear();
      pending.complete(profile('activa'));
      await loading;
      expect(controller.user, isNull);
    },
  );

  test(
    'Read-only denial updates the profile without logging out or permitting a stale refresh',
    () async {
      final controller = UserController();
      await controller.loadUser(loader: () async => profile('en_gracia'));
      final pending = Completer<Map<String, dynamic>>();
      final loading = controller.loadUser(loader: () => pending.future);
      expect(
        () => checkSubscriptionResponse(
          http.Response(
            jsonEncode({'code': 'subscription_read_only', 'estado': 'vencida'}),
            403,
          ),
        ),
        throwsA(isA<SubscriptionReadOnlyException>()),
      );
      pending.complete(profile('activa'));
      await loading;
      expect(controller.isLogged, isTrue);
      expect(
        SubscriptionAccess.fromProfile(controller.user).canOperate,
        isFalse,
      );
      await controller.loadUser(loader: () async => profile('activa'));
      expect(
        SubscriptionAccess.fromProfile(controller.user).canOperate,
        isTrue,
      );
    },
  );
  test('Access follows server capability, not the old subscription flag', () {
    for (final state in [
      'activa',
      'en_gracia',
      'vencida',
      'inactiva',
      'sin_suscripcion',
      'pendiente',
    ]) {
      final data = {...profile(state), 'suscripcion_activa': true};
      final access = SubscriptionAccess.fromProfile(data);
      expect(access.canOperate, state == 'activa' || state == 'en_gracia');
    }
    expect(SubscriptionAccess.fromProfile(null).canOperate, isFalse);
  });

  test('Older server response remains readable', () {
    final access = SubscriptionAccess.fromProfile({
      'suscripcion_activa': true,
      'suscripcion_estado': 'activa',
    });
    expect(access.canOperate, isTrue);
    expect(access.title, 'Suscripción activa');
  });

  test(
    'Known read-only response has a clear message and is not an auth failure',
    () {
      final response = http.Response(
        jsonEncode({'code': 'subscription_read_only', 'estado': 'vencida'}),
        403,
      );
      expect(
        () => checkSubscriptionResponse(response),
        throwsA(isA<SubscriptionReadOnlyException>()),
      );
      expect(
        SubscriptionReadOnlyException().toString(),
        contains('consultar tus datos'),
      );
    },
  );

  test(
    'Unrelated permission errors and malformed bodies keep original handling',
    () {
      for (final response in [
        http.Response('{}', 403),
        http.Response('<html>Error</html>', 403),
        http.Response('{}', 401),
        http.Response('[]', 200),
      ]) {
        expect(checkSubscriptionResponse(response), same(response));
      }
    },
  );

  testWidgets('Active account displays its due date', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionStatusCard(profile: profile('activa')),
        ),
      ),
    );
    expect(find.text('Suscripción activa'), findsOneWidget);
    expect(find.textContaining('Vencimiento:'), findsOneWidget);
    expect(find.textContaining('Fin de la gracia:'), findsNothing);
  });

  testWidgets('Grace explains complete access and the precise end of grace', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionStatusCard(profile: profile('en_gracia')),
        ),
      ),
    );
    expect(find.text('Suscripción en período de gracia'), findsOneWidget);
    expect(find.textContaining('Tienes acceso completo'), findsOneWidget);
    expect(find.textContaining('Fin de la gracia:'), findsOneWidget);
    expect(find.textContaining('Usuarios y suscripción'), findsOneWidget);
  });

  testWidgets(
    'Expired secondary sees read-only and principal guidance on a phone',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SubscriptionStatusCard(
                profile: profile('vencida', owner: false),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Modo solo lectura'), findsOneWidget);
      expect(find.textContaining('Contacta al principal'), findsOneWidget);
      expect(find.textContaining('Usuarios y suscripción'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Absent and inactive subscriptions cannot claim a grace period', (
    tester,
  ) async {
    for (final state in ['sin_suscripcion', 'inactiva', 'pendiente']) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SubscriptionStatusCard(profile: profile(state))),
        ),
      );
      expect(find.text('Modo solo lectura'), findsOneWidget);
      expect(find.textContaining('Fin de la gracia:'), findsNothing);
    }
  });

  testWidgets(
    'Missing profile requests refresh instead of claiming the subscription expired',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SubscriptionStatusCard(profile: null)),
        ),
      );
      expect(find.text('No se pudo verificar la suscripción'), findsOneWidget);
      expect(find.textContaining('revisa la conexión'), findsOneWidget);
    },
  );
}
