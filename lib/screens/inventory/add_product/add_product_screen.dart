import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../../widgets/animated_gradient_button.dart';
import 'add_product_controller.dart';
import '../../../utils/colors.dart';

import '../../../widgets/round_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> with SingleTickerProviderStateMixin {
  late AddProductController controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AddProductController());

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      title: const Text(
        "Add Product",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      toolbarHeight: MediaQuery.of(context).size.height / 10,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderText(),
                  const SizedBox(height: 24),
                  _buildProductForm(),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                  const SizedBox(height: 16),
                  _buildErrorMessage(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create New Product",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add a new product to your inventory",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            RoundTitleTextfield(
              title: "Product Title",
              hintText: "Enter product name",
              controller: controller.titleController,
              keyboardType: TextInputType.text,
              bgColor: AppColors.subtleBackground,
              left: Icon(Icons.inventory_2_outlined, color: AppColors.secondary),
              validator: controller.validateTitle,
            ),
            const SizedBox(height: 20),
            RoundTitleTextfield(
              title: "Price",
              hintText: "Enter product price",
              controller: controller.priceController,
              keyboardType: TextInputType.number,
              bgColor: AppColors.subtleBackground,
              left: Icon(Icons.attach_money, color: AppColors.secondary),
              validator: controller.validatePrice,
            ),
            const SizedBox(height: 20),
            RoundTitleTextfield(
              title: "Product Details",
              hintText: "Enter product description",
              controller: controller.detailController,
              keyboardType: TextInputType.multiline,
              bgColor: AppColors.subtleBackground,
              maxLines: 5,
              height: 150,
              left: Icon(Icons.description_outlined, color: AppColors.secondary),
              validator: controller.validateDetail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => AnimatedGradientButton(
      title: "Save Product",
      icon: Icons.save_outlined,
      isLoading: controller.isLoading.value,
      onTap: controller.saveProduct,
    ));
  }

  Widget _buildErrorMessage() {
    return Obx(() => controller.errorMessage.value.isNotEmpty
        ? Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.redColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.redColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.redColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: AppColors.redColor),
            ),
          ),
        ],
      ),
    )
        : const SizedBox.shrink());
  }
}