import 'package:agrlinks_app/screens/inventory/product_info/product_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../utils/colors.dart';
import '../add_product/add_product_screen.dart';
import 'product_controller.dart';
import 'product_model.dart';
import 'product_screen_widgets.dart';
import '../product_transaction/product_transaction.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with TickerProviderStateMixin {
  late final ProductController _productController;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _productController = Get.put(ProductController());
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.backgroundColor,
      body: _buildProductList(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      title: const Text(
        "Inventory Products",
        style: TextStyle(
          color: wColor,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
      foregroundColor: AppColors.whiteColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      toolbarHeight: MediaQuery.of(context).size.height / 9,
    );
  }

  Widget _buildProductList() {
    return GetBuilder<ProductController>(
        builder: (controller) {
          return StreamBuilder<QuerySnapshot>(
            stream: controller.getProducts(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return _buildErrorState("Something went wrong!");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget();
              }

              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return const EmptyStateWidget(
                  message: "No products found",
                  icon: Icons.inventory_2_outlined,
                );
              }

              return AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeController.value,
                    child: _buildProductGrid(snapshot),
                  );
                },
              );
            },
          );
        }
    );
  }

  Widget _buildProductGrid(AsyncSnapshot<QuerySnapshot> snapshot) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          // Convert Firestore document to Product model
          final product = Product.fromSnapshot(snapshot.data!.docs[index]);

          return _buildProductCard(product, index)
              .animate(delay: Duration(milliseconds: 50 * index))
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, int index) {
    return Hero(
      tag: 'product-${product.id}',
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
        shadowColor: AppColors.shadowColor,
        child: InkWell(
          onTap: () => _navigateToProductDetails(product),
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.subtleGold,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.cardGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Section
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.subtleGold.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/parcel.png',
                      height: 70,
                      width: 70,
                    ),
                  ),
                ),

                // Product Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Text(
                          product.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Date
                        Text(
                          _formatDate(product.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Price and Quantity
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price
                            Text(
                              "RS ${product.price}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),

                            // Quantity Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                product.quantity.toString(),
                                style: const TextStyle(
                                  color: wColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: AppColors.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Get.to(() => const AddProductScreen()),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.whiteColor,
      elevation: 4,
      icon: const Icon(Icons.add),
      label: const Text('Add Product'),
    )
        .animate()
        .scale(
        duration: 300.ms,
        curve: Curves.easeOut
    )
        .fadeIn();
  }

  void _navigateToProductDetails(Product product) {
    Get.to(
          () => const ProductInfo(),
      arguments: {
        'date': _formatDate(product.createdAt),
        'title': product.title,
        'price': product.price,
        'qty': product.quantity,
        'detail': product.detail,
        'docId': product.id,
      },
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  String _formatDate(DateTime dateTime) {
    String weekday = _getWeekday(dateTime);
    String day = dateTime.day.toString();
    String month = _getMonth(dateTime);
    String year = (dateTime.year % 100).toString();
    String time = _formatHour(dateTime);

    return '$weekday, $day $month $year · $time';
  }

  // Helper functions for date formatting
  String _getWeekday(DateTime dateTime) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[dateTime.weekday - 1];
  }

  String _getMonth(DateTime dateTime) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[dateTime.month - 1];
  }

  String _formatHour(DateTime dateTime) {
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

