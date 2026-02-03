import 'package:flutter/material.dart';
import '../data/token_storage.dart';
import 'login_page.dart';

class ProtectedPage extends StatefulWidget {
  final Widget child;

  const ProtectedPage({super.key, required this.child});

  @override
  State<ProtectedPage> createState() => _ProtectedPageState();
}

class _ProtectedPageState extends State<ProtectedPage> {
  bool _loading = true;
  bool _authorized = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await TokenStorage.getAccessToken();
    if (!mounted) return;

    setState(() {
      _authorized = token != null;
      _loading = false;
    });

    if (!_authorized) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _authorized ? widget.child : const SizedBox.shrink();
  }
}
