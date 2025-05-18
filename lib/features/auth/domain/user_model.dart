import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email; // Added email, can be optional

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
  });

  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return UserModel(
      uid: data?['uid'] ?? '',
      firstName: data?['firstName'] ?? '',
      lastName: data?['lastName'] ?? '',
      phone: data?['phone'] ?? '',
      email: data?['email'], // email might not always be in 'users' collection
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      if (email != null) 'email': email,
    };
  }
}
