import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../services/firebase_service_registry.dart';

class AuthRepository {
  AuthRepository({required FirebaseServiceRegistry registry})
      : _auth = registry.firebaseAuth,
        _messaging = registry.firebaseMessaging,
        _firestore = registry.firestore;

  final FirebaseAuth _auth;
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String> sendOtp({required String phoneNumber}) async {
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        await _syncFcmToken();
        completer.complete('');
      },
      verificationFailed: (exception) {
        completer.completeError(exception);
      },
      codeSent: (verificationId, _) {
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  Future<bool> verifyOtp({required String verificationId, required String smsCode}) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    await _syncFcmToken();
    final user = result.user;
    return result.additionalUserInfo?.isNewUser ?? user?.displayName == null;
  }

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No user is signed in');
    }
    await user.updateDisplayName(name);
    await user.reload();
    await _syncFcmToken();
  }

  Future<void> signInWithEmail({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _syncFcmToken();
  }

  Future<void> createAccountWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    await _syncFcmToken();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _syncFcmToken() async {
    final token = await _messaging.getToken();
    if (token == null) {
      return;
    }
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    final userDoc = _firestore.collection('users').doc(user.uid);
    await userDoc.set({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'displayName': user.displayName,
      'phone': user.phoneNumber,
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
