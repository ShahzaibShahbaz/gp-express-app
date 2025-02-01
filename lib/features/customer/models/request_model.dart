// lib/features/customer/models/request_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String customerId;
  final String? gpId;
  final String packageType;
  final double weight;
  final String departureCountry;
  final String departureCity;
  final String arrivalCountry;
  final String arrivalCity;
  final DateTime earliestDepartureTime;
  final DateTime latestArrivalTime;
  final bool isFragile;
  final String status;
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.customerId,
    this.gpId,
    required this.packageType,
    required this.weight,
    required this.departureCountry,
    required this.departureCity,
    required this.arrivalCountry,
    required this.arrivalCity,
    required this.earliestDepartureTime,
    required this.latestArrivalTime,
    required this.isFragile,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'gpId': gpId,
      'packageType': packageType,
      'weight': weight,
      'departureCountry': departureCountry,
      'departureCity': departureCity,
      'arrivalCountry': arrivalCountry,
      'arrivalCity': arrivalCity,
      'earliestDepartureTime': Timestamp.fromDate(earliestDepartureTime),
      'latestArrivalTime': Timestamp.fromDate(latestArrivalTime),
      'isFragile': isFragile,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime getDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      throw 'Invalid date format';
    }

    return RequestModel(
      id: id,
      customerId: map['customerId'],
      packageType: map['packageType'],
      weight: (map['weight'] as num).toDouble(),
      departureCountry: map['departureCountry'],
      departureCity: map['departureCity'],
      arrivalCountry: map['arrivalCountry'],
      arrivalCity: map['arrivalCity'],
      earliestDepartureTime: getDateTime(map['earliestDepartureTime']),
      latestArrivalTime: getDateTime(map['latestArrivalTime']),
      isFragile: map['isFragile'],
      status: map['status'] ?? 'pending',
      createdAt: getDateTime(map['createdAt']),
    );
  }

  RequestModel copyWith({
    String? customerId,
    String? gpId,
    String? packageType,
    double? weight,
    String? departureCountry,
    String? departureCity,
    String? arrivalCountry,
    String? arrivalCity,
    DateTime? earliestDepartureTime,
    DateTime? latestArrivalTime,
    bool? isFragile,
    String? status,
  }) {
    return RequestModel(
      id: id,
      customerId: customerId ?? this.customerId,
      gpId: gpId ?? this.gpId,
      packageType: packageType ?? this.packageType,
      weight: weight ?? this.weight,
      departureCountry: departureCountry ?? this.departureCountry,
      departureCity: departureCity ?? this.departureCity,
      arrivalCountry: arrivalCountry ?? this.arrivalCountry,
      arrivalCity: arrivalCity ?? this.arrivalCity,
      earliestDepartureTime: earliestDepartureTime ?? this.earliestDepartureTime,
      latestArrivalTime: latestArrivalTime ?? this.latestArrivalTime,
      isFragile: isFragile ?? this.isFragile,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}