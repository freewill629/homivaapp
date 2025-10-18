import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/providers/auth_providers.dart';
import '../../widgets/primary_scaffold.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const routeName = 'profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);

    return PrimaryScaffold(
      title: 'Profile',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user?.displayName ?? 'Homiva member', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(user?.phoneNumber ?? user?.email ?? ''),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
