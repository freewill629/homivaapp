import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/primary_scaffold.dart';

class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key});

  static const routeName = 'onboarding-complete';

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'All set!',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 96),
            const SizedBox(height: 24),
            Text('Device linked successfully.', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            const Text('You can now monitor water levels and receive alerts.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
