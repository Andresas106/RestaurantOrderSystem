import 'package:cloud_firestore/cloud_firestore.dart';

class Dishes {
  final int id;
  final int categoryId;
  final String description;
  final String imageUrl;
  final String name;
  final int prepTime;
  final double price;
  final int totalTime;
  final Timestamp? updatedAt;
  final Timestamp createdAt;

  Dishes({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.prepTime,
    required this.price,
    required this.totalTime,
    required this.createdAt,
    this.updatedAt
  });

  factory Dishes.fromMap(Map<String, dynamic> data) {
    return Dishes(
        id: data['id'],
        categoryId: data['categoryId'],
        description: data['description'],
        imageUrl: data['imageUrl'],
        name: data['name'],
        prepTime: data['prepTime'],
        price: data['price'],
        totalTime: data['totalTime'],
        createdAt: data['createdAt'],
        updatedAt: data['updatedAt'] as Timestamp?);
  }


}