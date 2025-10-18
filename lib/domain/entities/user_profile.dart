import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.email,
    required this.fcmTokens,
    required this.createdAt,
  });

  final String id;
  final String? displayName;
  final String? phone;
  final String? email;
  final List<String> fcmTokens;
  final DateTime? createdAt;

  factory UserProfile.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return UserProfile(
      id: snapshot.id,
      displayName: data['displayName'] as String?,
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      fcmTokens: (data['fcmTokens'] as List<dynamic>? ?? []).cast<String>(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayName': displayName,
      'phone': phone,
      'email': email,
      'fcmTokens': fcmTokens,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

class UserDeviceLink {
  const UserDeviceLink({
    required this.deviceId,
    required this.role,
    required this.addedAt,
  });

  final String deviceId;
  final String role;
  final DateTime? addedAt;

  factory UserDeviceLink.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return UserDeviceLink(
      deviceId: snapshot.id,
      role: data['role'] as String? ?? 'member',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class Invite {
  const Invite({
    required this.id,
    required this.deviceId,
    required this.invitedPhoneOrEmail,
    required this.status,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String deviceId;
  final String invitedPhoneOrEmail;
  final String status;
  final String role;
  final DateTime? createdAt;

  factory Invite.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return Invite(
      id: snapshot.id,
      deviceId: data['deviceId'] as String? ?? '',
      invitedPhoneOrEmail: data['invitedPhoneOrEmail'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      role: data['role'] as String? ?? 'member',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
