import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/providers/auth_providers.dart';
import '../../../../features/auth/state/phone_auth_controller.dart';

class PhoneSignInForm extends ConsumerStatefulWidget {
  const PhoneSignInForm({required this.state, super.key});

  final PhoneAuthState state;

  @override
  ConsumerState<PhoneSignInForm> createState() => _PhoneSignInFormState();
}

class _PhoneSignInFormState extends ConsumerState<PhoneSignInForm> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneState = widget.state;
    final controller = ref.read(phoneAuthControllerProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign in with phone', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
            if (phoneState.step == PhoneAuthStep.verifyOtp) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'OTP code'),
              ),
            ],
            if (phoneState.step == PhoneAuthStep.profileName) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Display name'),
                onSubmitted: (value) => controller.updateDisplayName(value),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: phoneState.isLoading
                  ? null
                  : () {
                      switch (phoneState.step) {
                        case PhoneAuthStep.enterPhone:
                          controller.sendOtp(phoneNumber: _phoneController.text);
                          break;
                        case PhoneAuthStep.verifyOtp:
                          controller.verifyOtp(smsCode: _otpController.text);
                          break;
                        case PhoneAuthStep.profileName:
                          controller.updateDisplayName(_nameController.text);
                          break;
                      }
                    },
              child: phoneState.isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      phoneState.step == PhoneAuthStep.enterPhone
                          ? 'Send OTP'
                          : phoneState.step == PhoneAuthStep.verifyOtp
                              ? 'Verify'
                              : 'Save Name',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
