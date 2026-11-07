import 'package:flutter/material.dart';
import 'sahaayi_button.dart';

class SahaayiErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const SahaayiErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            SahaayiButton(
              label: 'വീണ്ടും ശ്രമിക്കുക (Retry)',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
