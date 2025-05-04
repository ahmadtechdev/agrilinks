import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'product_model.dart';


class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of products for the current user
  Stream<QuerySnapshot> getProducts() {
    if (currentUser == null) {
      return Stream.empty();
    }

    return _firestore
        .collection("inventoryProducts")
        .where("userId", isEqualTo: currentUser!.uid)
        .orderBy("createdAT", descending: true)
        .snapshots();
  }

  // Get a single product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore
          .collection("inventoryProducts")
          .doc(productId)
          .get();

      if (doc.exists) {
        return Product.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print("Error fetching product: $e");
      return null;
    }
  }

  // Add a new product
  Future<bool> addProduct(Product product) async {
    try {
      await _firestore
          .collection("inventoryProducts")
          .add(product.toMap());
      return true;
    } catch (e) {
      print("Error adding product: $e");
      return false;
    }
  }

  // Update an existing product
  Future<bool> updateProduct(Product product) async {
    try {
      await _firestore
          .collection("inventoryProducts")
          .doc(product.id)
          .update(product.toMap());
      return true;
    } catch (e) {
      print("Error updating product: $e");
      return false;
    }
  }

  // Delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection("inventoryProducts")
          .doc(productId)
          .delete();
      return true;
    } catch (e) {
      print("Error deleting product: $e");
      return false;
    }
  }

  // Update product quantity
  Future<bool> updateQuantity(String productId, int newQuantity) async {
    try {
      await _firestore
          .collection("inventoryProducts")
          .doc(productId)
          .update({"qty": newQuantity});
      return true;
    } catch (e) {
      print("Error updating quantity: $e");
      return false;
    }
  }

  // Log a transaction for a product
  Future<bool> logTransaction(String productId, String productTitle,
      int quantity, String transactionType, String note) async {
    try {
      await _firestore.collection("productTransactions").add({
        "productId": productId,
        "productTitle": productTitle,
        "quantity": quantity,
        "transactionType": transactionType,
        "note": note,
        "timestamp": Timestamp.now(),
        "userId": currentUser?.uid,
      });
      return true;
    } catch (e) {
      print("Error logging transaction: $e");
      return false;
    }
  }
}