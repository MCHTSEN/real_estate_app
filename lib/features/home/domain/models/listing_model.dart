import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String userId;
  final String userPhone;
  final String userName;
  final String type; // 'sell' or 'rent'
  final String title;
  final String description;
  final int price;
  final String location; // City/District
  final String neighborhood;
  final int squareMeters;
  final int roomCount;
  final List<String> imageUrls;
  final DateTime createdAt;

  ListingModel({
    required this.id,
    required this.userId,
    required this.userPhone,
    required this.userName,
    required this.type,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.neighborhood,
    required this.squareMeters,
    required this.roomCount,
    required this.imageUrls,
    required this.createdAt,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userPhone: json['userPhone'] as String,
      userName: json['userName'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      location: json['location'] as String,
      neighborhood: json['neighborhood'] as String,
      squareMeters: json['squareMeters'] as int,
      roomCount: json['roomCount'] as int,
      imageUrls: List<String>.from(json['imageUrls']),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userPhone': userPhone,
      'userName': userName,
      'type': type,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'neighborhood': neighborhood,
      'squareMeters': squareMeters,
      'roomCount': roomCount,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
    };
  }
}
