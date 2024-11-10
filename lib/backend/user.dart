import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String userId;
  final String email;

  UserModel({required this.userId, required this.email});

  // Factory constructor to create a UserModel instance from a Firebase User object
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      userId: user.uid,
      email: user.email ?? '',
    );
  }

  // Method to convert UserModel to JSON format
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
    };
  }

  // Factory method to create UserModel instance from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      email: json['email'],
    );
  }
}
