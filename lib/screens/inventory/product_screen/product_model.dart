import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String detail;
  final DateTime createdAt;
  final String userId;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.detail,
    required this.createdAt,
    required this.userId,
  });

  // Create Product from Firestore document
  factory Product.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    // Handle Firestore timestamp conversion
    Timestamp timestamp = data['createdAT'];
    DateTime dateTime = timestamp.toDate();

    return Product(
      id: snapshot.id,
      title: data['productTitle'] ?? '',
      price: double.tryParse(data['productPrice']?.toString() ?? '0') ?? 0.0,
      quantity: data['qty'] ?? 0,
      detail: data['detail'] ?? '',
      createdAt: dateTime,
      userId: data['userId'] ?? '',
    );
  }

  // Convert Product to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productTitle': title,
      'productPrice': price,
      'qty': quantity,
      'detail': detail,
      'createdAT': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  // Create a copy of Product with updated fields
  Product copyWith({
    String? title,
    double? price,
    int? quantity,
    String? detail,
  }) {
    return Product(
      id: id,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      detail: detail ?? this.detail,
      createdAt: createdAt,
      userId: userId,
    );
  }
}