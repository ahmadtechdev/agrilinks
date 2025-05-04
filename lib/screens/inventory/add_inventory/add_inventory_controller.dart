import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../inventory_screen/inventory_screen.dart';



class AddInventoryController extends GetxController {
  final qtyController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final User? userId = FirebaseAuth.instance.currentUser;

  // Observables
  final RxString selectedType = "Received".obs;
  final RxString selectedProduct = "".obs;
  final RxList<String> products = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  // @override
  // void onClose() {
  //   qtyController.dispose();
  //   super.onClose();
  // }



  Future<void> fetchProducts() async {
    try {
      isLoading(true);

      if (userId == null) {
        errorMessage.value = "No user is currently logged in.";
        return;
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('inventoryProducts')
          .where('userId', isEqualTo: userId?.uid)
          .get();

      products.value = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['productTitle'] as String? ?? '')
          .toList();

      if (products.isNotEmpty) {
        selectedProduct.value = products[0];
      }
    } catch (e) {
      errorMessage.value = "Failed to load products: $e";
    } finally {
      isLoading(false);
    }
  }




  Future<bool> saveInventory() async {
    if (!formKey.currentState!.validate()) return false;

    isLoading(true);
    errorMessage.value = "";

    try {
      final qty = qtyController.text.trim();
      final title = selectedProduct.value;
      final type = selectedType.value;

      // Get current product quantity
      final documentSnapshot = await FirebaseFirestore.instance
          .collection("inventoryProducts")
          .doc(title)
          .get();

      var currentQty = documentSnapshot.data()?['qty'] ?? 0;
      var newQty = type == "Send"
          ? currentQty - int.parse(qty)
          : currentQty + int.parse(qty);

      // Check if enough quantity available for sending
      if (newQty < 0 && type == "Send") {
        errorMessage.value = "Not enough quantity available, current stock is $currentQty";
        return false;
      }

      // Create transaction record
      await FirebaseFirestore.instance
          .collection("productTransaction")
          .doc()
          .set({
        "createdAT": DateTime.now(),
        "userId": userId?.uid,
        "title": title,
        "qty": qty,
        "type": type,
      });

      // Update product quantity
      await FirebaseFirestore.instance
          .collection("inventoryProducts")
          .doc(title)
          .update({
        'qty': newQty,
      });

      Get.off(() => InventoryScreen());
      return true;
    } catch (e) {
      errorMessage.value = "Error saving inventory: $e";
      return false;
    } finally {
      isLoading(false);
    }
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a quantity";
    }

    try {
      int qty = int.parse(value);
      if (qty <= 0) {
        return "Quantity must be greater than 0";
      }
    } catch (e) {
      return "Please enter a valid number";
    }

    return null;
  }
}