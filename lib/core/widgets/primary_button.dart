import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {

  final String text;

  final VoidCallback? onPressed;

  final bool loading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: double.infinity,

      height: 52,

      child: ElevatedButton(

        onPressed:
            loading ? null : onPressed,

        child: loading

            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )

            : Text(text),
      ),
    );
  }
}