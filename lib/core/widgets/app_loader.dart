import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AppLoader extends StatelessWidget {

  final double size;

  const AppLoader({
    super.key,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: size,
      height: size,

      child: CircularProgressIndicator(

        strokeWidth: 3,

        color: AppColors.primary,
      ),
    );
  }
}

class FullScreenLoader extends StatelessWidget {

  const FullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(

      body: Center(
        child: AppLoader(size: 42),
      ),
    );
  }
}