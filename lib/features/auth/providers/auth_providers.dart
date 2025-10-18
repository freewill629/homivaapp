import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/firebase_service_registry.dart';
import '../repositories/auth_repository.dart';
import '../state/phone_auth_controller.dart';

final firebaseServiceRegistryProvider = Provider<FirebaseServiceRegistry>((ref) {
  return FirebaseServiceRegistry();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final registry = ref.watch(firebaseServiceRegistryProvider);
  return AuthRepository(registry: registry);
});

final authStateChangesProvider = StreamProvider.autoDispose((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final authUserProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});

final phoneAuthControllerProvider = StateNotifierProvider<PhoneAuthController, PhoneAuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return PhoneAuthController(authRepository: authRepository);
});
