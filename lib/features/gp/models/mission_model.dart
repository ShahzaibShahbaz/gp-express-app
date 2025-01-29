// lib/features/auth/models/mission_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum MissionStatus { pending, approved, inProgress, completed }

class MissionModel {
  final String id;
  final String gpId;
  final String? customerId;
  final String? customerName;
  final String departureCountry;
  final String departureCity;
  final String departureAirport;
  final double departureLatitude;
  final double departureLongitude;
  final String arrivalCountry;
  final String arrivalCity;
  final String arrivalAirport;
  final double arrivalLatitude;
  final double arrivalLongitude;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int capacity;
  final bool hasFlightTicket;
  final MissionStatus status;
  final DateTime createdAt;
  final double? completionPercentage;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? lastLocationUpdate;

  MissionModel({
    required this.id,
    required this.gpId,
    this.customerId,
    this.customerName,
    required this.departureCountry,
    required this.departureCity,
    required this.departureAirport,
    required this.departureLatitude,
    required this.departureLongitude,
    required this.arrivalCountry,
    required this.arrivalCity,
    required this.arrivalAirport,
    required this.arrivalLatitude,
    required this.arrivalLongitude,
    required this.departureTime,
    required this.arrivalTime,
    required this.capacity,
    required this.hasFlightTicket,
    required this.status,
    required this.createdAt,
    this.completionPercentage,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationUpdate,
  });

  Map<String, dynamic> toMap() => {
    'gpId': gpId,
    'customerId': customerId,
    'customerName': customerName,
    'departureCountry': departureCountry,
    'departureCity': departureCity,
    'departureAirport': departureAirport,
    'departureLatitude': departureLatitude,
    'departureLongitude': departureLongitude,
    'arrivalCountry': arrivalCountry,
    'arrivalCity': arrivalCity,
    'arrivalAirport': arrivalAirport,
    'arrivalLatitude': arrivalLatitude,
    'arrivalLongitude': arrivalLongitude,
    'departureTime': departureTime.toIso8601String(),
    'arrivalTime': arrivalTime.toIso8601String(),
    'capacity': capacity,
    'hasFlightTicket': hasFlightTicket,
    'status': status.name,
    'createdAt': createdAt,
    'completionPercentage': completionPercentage,
    'currentLatitude': currentLatitude,
    'currentLongitude': currentLongitude,
    'lastLocationUpdate': lastLocationUpdate?.toIso8601String(),
  };

  factory MissionModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      }
      throw Exception('Invalid datetime format');
    }

    return MissionModel(
      id: id,
      gpId: map['gpId'] ?? '',
      customerId: map['customerId'],
      customerName: map['customerName'],
      departureCountry: map['departureCountry'] ?? '',
      departureCity: map['departureCity'] ?? '',
      departureAirport: map['departureAirport'] ?? '',
      departureLatitude: (map['departureLatitude'] ?? 0.0).toDouble(),
      departureLongitude: (map['departureLongitude'] ?? 0.0).toDouble(),
      arrivalCountry: map['arrivalCountry'] ?? '',
      arrivalCity: map['arrivalCity'] ?? '',
      arrivalAirport: map['arrivalAirport'] ?? '',
      arrivalLatitude: (map['arrivalLatitude'] ?? 0.0).toDouble(),
      arrivalLongitude: (map['arrivalLongitude'] ?? 0.0).toDouble(),
      departureTime: parseDateTime(map['departureTime']),
      arrivalTime: parseDateTime(map['arrivalTime']),
      capacity: map['capacity'] ?? 0,
      hasFlightTicket: map['hasFlightTicket'] ?? false,
      status: MissionStatus.values.firstWhere(
            (e) => e.name == (map['status'] ?? 'pending'),
        orElse: () => MissionStatus.pending,
      ),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      completionPercentage: map['completionPercentage']?.toDouble(),
      currentLatitude: map['currentLatitude']?.toDouble(),
      currentLongitude: map['currentLongitude']?.toDouble(),
      lastLocationUpdate: map['lastLocationUpdate'] != null
          ? parseDateTime(map['lastLocationUpdate'])
          : null,
    );
  }

  MissionModel copyWith({
    String? id,
    String? gpId,
    String? customerId,
    String? customerName,
    String? departureCountry,
    String? departureCity,
    String? departureAirport,
    double? departureLatitude,
    double? departureLongitude,
    String? arrivalCountry,
    String? arrivalCity,
    String? arrivalAirport,
    double? arrivalLatitude,
    double? arrivalLongitude,
    DateTime? departureTime,
    DateTime? arrivalTime,
    int? capacity,
    bool? hasFlightTicket,
    MissionStatus? status,
    DateTime? createdAt,
    double? completionPercentage,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastLocationUpdate,
  }) {
    return MissionModel(
      id: id ?? this.id,
      gpId: gpId ?? this.gpId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      departureCountry: departureCountry ?? this.departureCountry,
      departureCity: departureCity ?? this.departureCity,
      departureAirport: departureAirport ?? this.departureAirport,
      departureLatitude: departureLatitude ?? this.departureLatitude,
      departureLongitude: departureLongitude ?? this.departureLongitude,
      arrivalCountry: arrivalCountry ?? this.arrivalCountry,
      arrivalCity: arrivalCity ?? this.arrivalCity,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      arrivalLatitude: arrivalLatitude ?? this.arrivalLatitude,
      arrivalLongitude: arrivalLongitude ?? this.arrivalLongitude,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      capacity: capacity ?? this.capacity,
      hasFlightTicket: hasFlightTicket ?? this.hasFlightTicket,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    );
  }
}