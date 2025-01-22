enum UserType { customer, gp }

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final UserType userType;
  final String? phoneNumber;
  final DateTime createdAt;
  final bool isVerified;
  // New GP-specific fields
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
      'userType': userType.toString().split('.').last,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isVerified': isVerified,
      'hasSubmittedId': hasSubmittedId,
      'isIdVerified': isIdVerified,
      'idSubmissionDate': idSubmissionDate,
      'hasSeenWelcome': hasSeenWelcome,
      'welcomeScreenSeenAt': welcomeScreenSeenAt?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      userType: map['userType'] != null
          ? UserType.values.firstWhere(
            (type) => type.toString().split('.').last == map['userType'],
        orElse: () => UserType.customer,
      )
          : UserType.customer,
      phoneNumber: map['phoneNumber'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      isVerified: map['isVerified'] ?? false,
      hasSubmittedId: map['hasSubmittedId'] ?? false,
      isIdVerified: map['isIdVerified'] ?? false,
      idSubmissionDate: map['idSubmissionDate'],
      hasSeenWelcome: map['hasSeenWelcome'] ?? false,
      welcomeScreenSeenAt: map['welcomeScreenSeenAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['welcomeScreenSeenAt'])
          : null,
    );
  }
}