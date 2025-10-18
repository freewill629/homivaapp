import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';

class PhoneAuthState {
  const PhoneAuthState({
    this.isLoading = false,
    this.verificationId,
    this.errorMessage,
    this.step = PhoneAuthStep.enterPhone,
  });

  final bool isLoading;
  final String? verificationId;
  final String? errorMessage;
  final PhoneAuthStep step;

  PhoneAuthState copyWith({
    bool? isLoading,
    String? verificationId,
    String? errorMessage,
    PhoneAuthStep? step,
  }) {
    return PhoneAuthState(
      isLoading: isLoading ?? this.isLoading,
      verificationId: verificationId ?? this.verificationId,
      errorMessage: errorMessage,
      step: step ?? this.step,
    );
  }
}

enum PhoneAuthStep { enterPhone, verifyOtp, profileName }

class PhoneAuthController extends StateNotifier<PhoneAuthState> {
  PhoneAuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const PhoneAuthState());

  final AuthRepository _authRepository;

  Future<void> sendOtp({required String phoneNumber}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final verificationId = await _authRepository.sendOtp(phoneNumber: phoneNumber);
      state = state.copyWith(
        verificationId: verificationId,
        step: PhoneAuthStep.verifyOtp,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> verifyOtp({required String smsCode}) async {
    final verificationId = state.verificationId;
    if (verificationId == null) {
      state = state.copyWith(errorMessage: 'Missing verification ID');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final isNewUser = await _authRepository.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      state = state.copyWith(
        step: isNewUser ? PhoneAuthStep.profileName : PhoneAuthStep.enterPhone,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> updateDisplayName(String name) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepository.updateDisplayName(name);
      state = const PhoneAuthState();
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}
