import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { individual, lawyer }

class UserModel {
  UserModel({
    required this.uid,
    required this.email,
    required this.userType,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.baroRegistrationNumber,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      userType: UserType.values.firstWhere(
        (e) => e.name == data['userType'],
        orElse: () => UserType.individual,
      ),
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      baroRegistrationNumber: data['baroRegistrationNumber'] as String?,
    );
  }

  final String uid;
  final String email;
  final UserType userType;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final String? baroRegistrationNumber;

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'userType': userType.name,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'baroRegistrationNumber': baroRegistrationNumber,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    UserType? userType,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    String? baroRegistrationNumber,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      baroRegistrationNumber: baroRegistrationNumber ?? this.baroRegistrationNumber,
    );
  }
}
