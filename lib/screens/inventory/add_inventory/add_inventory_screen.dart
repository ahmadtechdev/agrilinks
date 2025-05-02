import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../utils/colors.dart';
import '../../../widgets/bottom_navigation.dart';
import '../../../widgets/button.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/round_text_field.dart';
import '../add_product_screen.dart';
import 'add_invevtory_controller.dart';

class AddInventoryScreen extends StatelessWidget {
  const AddInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller with Get.put to make it available for this view
    final controller = Get.put(AddInventoryController());

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context, controller),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 1),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      title: Text(
        "Add Inventory",
        style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      foregroundColor: AppColors.whiteColor,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      toolbarHeight: MediaQuery.of(context).size.height / 10,
    );
  }

  Widget _buildBody(BuildContext context, AddInventoryController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAnimationHeader(),
            _buildHeaderText(),
            const SizedBox(height: 15),
            _buildForm(context, controller),
            const SizedBox(height: 25),
            _buildSaveButton(context, controller),
            const SizedBox(height: 20),
            if (controller.errorMessage.isNotEmpty)
              _buildErrorMessage(controller.errorMessage.value),
          ],
        )),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add stock or record outgoing products with ease",
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationHeader() {
    return Container(
      alignment: Alignment.center,
      height: 180.0,
      child: Hero(
        tag: 'inventory_animation',
        child: Lottie.asset(
          "assets/Animation - inventory.json",
          animate: true,
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AddInventoryController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        );
      }

      return Card(
        elevation: 8,
        shadowColor: AppColors.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProductDropdown(controller),
                const SizedBox(height: 15),
                _buildQuantityField(controller),
                const SizedBox(height: 20),
                _buildTransactionTypeDropdown(controller),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProductDropdown(AddInventoryController controller) {
    // Create a map of product id to product name
    // Since we're using the product name itself as both key and value in this case
    Map<String, String> productMap = {};
    for (var product in controller.products) {
      productMap[product] = product;
    }

    return CustomDropdown(
      hint: 'Select Product',
      items: productMap,
      selectedItemId: controller.selectedProduct.value.isEmpty ? null : controller.selectedProduct.value,
      onChanged: (String? newValue) {
        if (newValue != null) {
          controller.selectedProduct.value = newValue;
        }
      },
      showSearch: true,
    );
  }

  Widget _buildQuantityField(AddInventoryController controller) {
    return RoundTitleTextfield(
      title: 'Quantity',
      hintText: 'Enter quantity',
      controller: controller.qtyController,
      keyboardType: TextInputType.number,
      left: Icon(Icons.production_quantity_limits, color: AppColors.secondary),
      onChanged: (value) {
        // Validation will happen in the controller
      },
    );
  }

  Widget _buildTransactionTypeDropdown(AddInventoryController controller) {
    // Create a map for transaction types
    Map<String, String> transactionTypes = {
      "Received": "Received",
      "Send": "Send"
    };

    return CustomDropdown(
      hint: 'Transaction Type',
      items: transactionTypes,
      selectedItemId: controller.selectedType.value,
      onChanged: (String? newValue) {
        if (newValue != null) {
          controller.selectedType.value = newValue;
        }
      },
      showSearch: false,
    );
  }

  Widget _buildSaveButton(BuildContext context, AddInventoryController controller) {
    return Obx(() => controller.isLoading.value
        ? Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
      ),
    )
        : RoundedButton(
      title: "Save Inventory",
      icon: Icons.save_rounded,
      useGradient: true,
      textColor: AppColors.whiteColor,
      elevation: 4,
      height: 55,
      onTap: () async {
        // Dismiss keyboard
        FocusScope.of(context).unfocus();

        await controller.saveInventory();

        if (controller.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.whiteColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(controller.errorMessage.value),
                  ),
                ],
              ),
              backgroundColor: AppColors.redColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(
                  bottom: 20,
                  right: 20,
                  left: 20
              ),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'DISMISS',
                textColor: AppColors.whiteColor,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      },
    ));
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.redColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.redColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: AppColors.redColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Error",
                  style: TextStyle(
                    color: AppColors.redColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(color: AppColors.redColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Get.to(() => const AddProductScreen(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 300),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  "Product",
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}