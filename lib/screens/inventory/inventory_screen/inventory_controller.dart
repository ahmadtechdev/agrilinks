import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final TextEditingController searchController = TextEditingController();

  // Animation controllers
  late RxList<Map<String, dynamic>> inventoryProducts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInventoryProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Fetch inventory products from Firestore
  Stream<QuerySnapshot> getInventoryProductsStream() {
    return _firestore
        .collection("inventoryProducts")
        .where("userId", isEqualTo: currentUserId)
        .snapshots();
  }

  // Fetch and update products list
  void fetchInventoryProducts() {
    isLoading.value = true;
    getInventoryProductsStream().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final products = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            ...data,
            'id': doc.id,
          };
        }).toList();
        inventoryProducts.value = products;
      } else {
        inventoryProducts.clear();
      }
      isLoading.value = false;
    }, onError: (error) {
      print("Error fetching inventory products: $error");
      isLoading.value = false;
    });
  }

  // Filter products based on search query
  List<Map<String, dynamic>> getFilteredProducts() {
    if (searchQuery.value.isEmpty) {
      return inventoryProducts;
    }

    return inventoryProducts.where((product) {
      final title = product['productTitle'].toString().toLowerCase();
      return title.contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // Delete product from Firestore
  Future<void> deleteProduct(String docId) async {
    try {
      await _firestore.collection("inventoryProducts").doc(docId).delete();
      Get.snackbar(
        'Success',
        'Product deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  // Format date utilities
  String formatDate(DateTime timestamp) {
    final weekday = getWeekday(timestamp);
    final month = getMonth(timestamp);
    final formattedHour = formatHour(timestamp);

    return '$weekday, ${timestamp.day} $month ${timestamp.year % 100} · $formattedHour';
  }

  String getWeekday(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  String getMonth(DateTime dateTime) {
    switch (dateTime.month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }

  String formatHour(DateTime dateTime) {
    String period = 'am';
    int hour = dateTime.hour;

    if (hour >= 12) {
      period = 'pm';
      if (hour > 12) {
        hour -= 12;
      }
    }

    if (hour == 0) {
      hour = 12;
    }

    String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}