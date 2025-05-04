import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../product_screen/product_screen.dart';

class AddProductController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final detailController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onClose() {
    titleController.dispose();
    priceController.dispose();
    detailController.dispose();
    super.onClose();
  }

  // Validation methods
  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a Product Title";
    } else if (value.length < 3) {
      return 'Name must be more than 2 characters';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an Amount";
    } else if (double.tryParse(value) == null) {
      return "Please enter a valid number";
    }
    return null;
  }

  String? validateDetail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please Add Detail";
    }
    return null;
  }

  // Save product to Firestore
  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final User? userId = FirebaseAuth.instance.currentUser;
      final title = titleController.text.trim();
      final price = priceController.text.trim();
      final detail = detailController.text.trim();

      await FirebaseFirestore.instance
          .collection("inventoryProducts")
          .doc(title)
          .set({
        "createdAT": DateTime.now(),
        "userId": userId?.uid,
        "productTitle": title,
        "productPrice": price,
        "qty": 0,
        "detail": detail,
      });

      Get.off(() => const ProductScreen());
    } catch (e) {
      errorMessage.value = "Error: $e";
      print("Error $e");
    } finally {
      isLoading.value = false;
    }
  }
}