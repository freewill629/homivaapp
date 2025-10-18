import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceCapabilities {
  const DeviceCapabilities({
    this.autoControl = false,
    this.qualitySensor = false,
    this.leakSensor = false,
    this.solar = false,
    this.purification = false,
    this.hardWaterConv = false,
    this.rainHarvest = false,
  });

  final bool autoControl;
  final bool qualitySensor;
  final bool leakSensor;
  final bool solar;
  final bool purification;
  final bool hardWaterConv;
  final bool rainHarvest;

  factory DeviceCapabilities.fromMap(Map<String, dynamic>? data) {
    final map = data ?? <String, dynamic>{};
    return DeviceCapabilities(
      autoControl: map['autoControl'] as bool? ?? false,
      qualitySensor: map['qualitySensor'] as bool? ?? false,
      leakSensor: map['leakSensor'] as bool? ?? false,
      solar: map['solar'] as bool? ?? false,
      purification: map['purification'] as bool? ?? false,
      hardWaterConv: map['hardWaterConv'] as bool? ?? false,
      rainHarvest: map['rainHarvest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'autoControl': autoControl,
      'qualitySensor': qualitySensor,
      'leakSensor': leakSensor,
      'solar': solar,
      'purification': purification,
      'hardWaterConv': hardWaterConv,
      'rainHarvest': rainHarvest,
    };
  }
}

class Device {
  const Device({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.status,
    required this.lastSeenAt,
    required this.location,
    required this.capabilities,
  });

  final String id;
  final String name;
  final String ownerId;
  final String status;
  final DateTime? lastSeenAt;
  final DeviceLocation? location;
  final DeviceCapabilities capabilities;

  bool get isOnline => status == 'online';

  factory Device.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final locationMap = data['location'] as Map<String, dynamic>?;
    return Device(
      id: snapshot.id,
      name: data['name'] as String? ?? 'Homiva Tank',
      ownerId: data['ownerId'] as String? ?? '',
      status: data['status'] as String? ?? 'offline',
      lastSeenAt: (data['lastSeenAt'] as Timestamp?)?.toDate(),
      location: locationMap != null ? DeviceLocation.fromMap(locationMap) : null,
      capabilities: DeviceCapabilities.fromMap(data['capabilities'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'ownerId': ownerId,
      'status': status,
      'lastSeenAt': lastSeenAt != null ? Timestamp.fromDate(lastSeenAt!) : null,
      'location': location?.toMap(),
      'capabilities': capabilities.toMap(),
    };
  }
}

class DeviceLocation {
  const DeviceLocation({this.lat, this.lng, this.address});

  final double? lat;
  final double? lng;
  final String? address;

  factory DeviceLocation.fromMap(Map<String, dynamic> map) {
    return DeviceLocation(
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      address: map['address'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }
}
