import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseServiceRegistry {
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseDatabase get realtimeDatabase => FirebaseDatabase.instance;
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
  FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
}
