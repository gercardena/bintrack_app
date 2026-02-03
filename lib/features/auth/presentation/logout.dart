import 'package:flutter/material.dart';
import '../data/token_storage.dart';
import 'login_page.dart';

Future<void> logout(BuildContext context) async {
  await TokenStorage.clearTokens();

  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}
