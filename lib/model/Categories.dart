import 'package:cloud_firestore/cloud_firestore.dart';

class Categories {
  final int id;
  final String name;
  final String description;
  final Timestamp? updatedAt;
  final Timestamp createdAt;

  Categories({
    required this.id,
    required this.description,
    required this.name,
    required this.createdAt,
    this.updatedAt
  });

  factory Categories.fromMap(Map<String, dynamic> data) {
    return Categories(
        id: data['id'],
        description: data['description'],
        name: data['name'],
        createdAt: data['createdAt'],
        updatedAt: data['updatedAt'] as Timestamp?);
  }
}