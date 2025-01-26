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
  final String arrivalCountry;
  final String arrivalCity;
  final String arrivalAirport;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int capacity;
  final bool hasFlightTicket;
  final MissionStatus status;
  final DateTime createdAt;
  final double? completionPercentage;

  MissionModel({
    required this.id,
    required this.gpId,
    this.customerId,
    this.customerName,
    required this.departureCountry,
    required this.departureCity,
    required this.departureAirport,
    required this.arrivalCountry,
    required this.arrivalCity,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.capacity,
    required this.hasFlightTicket,
    required this.status,
    required this.createdAt,
    this.completionPercentage,
  });

  Map<String, dynamic> toMap() => {
    'gpId': gpId,
    'customerId': customerId,
    'customerName': customerName,
    'departureCountry': departureCountry,
    'departureCity': departureCity,
    'departureAirport': departureAirport,
    'arrivalCountry': arrivalCountry,
    'arrivalCity': arrivalCity,
    'arrivalAirport': arrivalAirport,
    'departureTime': departureTime.toIso8601String(),
    'arrivalTime': arrivalTime.toIso8601String(),
    'capacity': capacity,
    'hasFlightTicket': hasFlightTicket,
    'status': status.name,
    'createdAt': createdAt,
    'completionPercentage': completionPercentage,
  };

  factory MissionModel.fromMap(Map<String, dynamic> map, String id) => MissionModel(
    id: id,
    gpId: map['gpId'],
    customerId: map['customerId'],
    customerName: map['customerName'],
    departureCountry: map['departureCountry'],
    departureCity: map['departureCity'],
    departureAirport: map['departureAirport'],
    arrivalCountry: map['arrivalCountry'],
    arrivalCity: map['arrivalCity'],
    arrivalAirport: map['arrivalAirport'],
    departureTime: DateTime.parse(map['departureTime']),
    arrivalTime: DateTime.parse(map['arrivalTime']),
    capacity: map['capacity'],
    hasFlightTicket: map['hasFlightTicket'],
    status: MissionStatus.values.firstWhere(
          (e) => e.name == map['status'],
      orElse: () => MissionStatus.pending,
    ),
    createdAt: (map['createdAt'] as Timestamp).toDate(),
    completionPercentage: map['completionPercentage']?.toDouble(),
  );
}