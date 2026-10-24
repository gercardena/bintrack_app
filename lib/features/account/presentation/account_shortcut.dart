import 'package:flutter/material.dart';
import 'account_page.dart';

class AccountShortcut extends StatelessWidget {
  const AccountShortcut({super.key, required this.profile});
  final Map<String, dynamic>? profile;

  @override
  Widget build(BuildContext context) {
    if (profile?['puede_gestionar_cuenta'] != true) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(foregroundColor: Colors.cyanAccent),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AccountPage()),
        ),
        icon: const Icon(Icons.manage_accounts_outlined),
        label: const Text('Usuarios y suscripción'),
      ),
    );
  }
}
