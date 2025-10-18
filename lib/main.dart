import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'features/auth/providers/auth_providers.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: HomivaApp()));
}

class HomivaApp extends ConsumerStatefulWidget {
  const HomivaApp({super.key});

  @override
  ConsumerState<HomivaApp> createState() => _HomivaAppState();
}

class _HomivaAppState extends ConsumerState<HomivaApp> {
  bool _notificationsInitialized = false;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final authState = ref.watch(authStateChangesProvider);
    final notificationService = ref.watch(notificationServiceProvider);

    if (!_notificationsInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notificationService.initialize(context: context, router: router);
      });
      _notificationsInitialized = true;
    }

    return MaterialApp.router(
      title: 'Homiva',
      theme: buildHomivaTheme(),
      routerConfig: router,
      builder: (context, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: authState.when(
            data: (_) => child,
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Failed to initialize app: \n$error'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
