import 'package:flutter/material.dart';
import 'features/auth/data/auth_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AuthApi.login(
    username: 'gerson2',
    password: '123456',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Probando login...'),
        ),
      ),
    );
  }
}
