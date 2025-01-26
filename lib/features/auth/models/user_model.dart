import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { customer, gp }

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final UserType userType;
  final String? phoneNumber;
  final DateTime createdAt;
  final bool isVerified;
  final bool hasSubmittedId;
  final bool isIdVerified;
  final String? idSubmissionDate;
  final bool hasSeenWelcome;
  final DateTime? welcomeScreenSeenAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.userType,
    this.phoneNumber,
    DateTime? createdAt,
    this.isVerified = false,
    this.hasSubmittedId = false,
    this.isIdVerified = false,
    this.idSubmissionDate,
    this.hasSeenWelcome = false,
    this.welcomeScreenSeenAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'userType': userType == UserType.gp ? 'gp' : 'customer',
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt), // Store as Timestamp
      'isVerified': isVerified,
      'hasSubmittedId': hasSubmittedId,
      'isIdVerified': isIdVerified,
      'idSubmissionDate': idSubmissionDate,
      'hasSeenWelcome': hasSeenWelcome,
      'welcomeScreenSeenAt': welcomeScreenSeenAt != null ?
      Timestamp.fromDate(welcomeScreenSeenAt!) : null, // Store as Timestamp
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    // Handle Timestamp conversion properly
    DateTime? getDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      userType: map['userType'] == 'gp' ? UserType.gp : UserType.customer,
      phoneNumber: map['phoneNumber'],
      createdAt: getDateTime(map['createdAt']) ?? DateTime.now(),
      isVerified: map['isVerified'] ?? false,
      hasSubmittedId: map['hasSubmittedId'] ?? false,
      isIdVerified: map['isIdVerified'] ?? false,
      idSubmissionDate: map['idSubmissionDate'],
      hasSeenWelcome: map['hasSeenWelcome'] ?? false,
      welcomeScreenSeenAt: getDateTime(map['welcomeScreenSeenAt']),
    );
  }

  // Add method to create a copy with modifications
  UserModel copyWith({
    String? fullName,
    String? phoneNumber,
    bool? isVerified,
    bool? hasSubmittedId,
    bool? isIdVerified,
    String? idSubmissionDate,
    bool? hasSeenWelcome,
    DateTime? welcomeScreenSeenAt,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      userType: userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt,
      isVerified: isVerified ?? this.isVerified,
      hasSubmittedId: hasSubmittedId ?? this.hasSubmittedId,
      isIdVerified: isIdVerified ?? this.isIdVerified,
      idSubmissionDate: idSubmissionDate ?? this.idSubmissionDate,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
      welcomeScreenSeenAt: welcomeScreenSeenAt ?? this.welcomeScreenSeenAt,
    );
  }
}