import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/colors.dart';
import '../../widgets/app_bar.dart';
import '../market/my_market_adds.dart';

class MyProductInfo extends StatefulWidget {
  const MyProductInfo({super.key});

  @override
  State<MyProductInfo> createState() => _MyProductInfoState();
}

class _MyProductInfoState extends State<MyProductInfo> {
  // Product data controller
  late final Map<String, dynamic> productData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    productData = Get.arguments;
  }

  // Extract commonly used strings to avoid repetition
  String get productName => productData['product'].toString();
  String get productImage => productData['image'].toString();
  String get productLocation => productData['location'].toString();
  String get productDescription => productData['description'].toString();
  String get productContact => productData['contact'].toString();
  String get productDocId => productData['docId'].toString();
  int get productQuantity => productData['qty'];
  String get productPrice => productData['price'].toString();

  // Methods to handle product actions
  Future<void> _markAsSold() async {
    _setLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('marketPlace')
          .doc(productDocId)
          .delete();
      _navigateToMarketAdds();
    } catch (e) {
      _showErrorSnackbar('Error marking product as sold');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _deleteProduct() async {
    _setLoading(true);
    try {
      // Get the current quantity from inventory
      var documentSnapshot = await FirebaseFirestore.instance
          .collection("inventoryProducts")
          .doc(productName)
          .get();

      // Calculate new quantity (adding back the market product quantity)
      var currentQty = documentSnapshot.data()?['qty'] ?? 0;
      int newQty = currentQty + productQuantity;

      // Update inventory quantity and delete from market
      await FirebaseFirestore.instance
          .collection("inventoryProducts")
          .doc(productName)
          .update({'qty': newQty});

      await FirebaseFirestore.instance
          .collection('marketPlace')
          .doc(productDocId)
          .delete();

      _navigateToMarketAdds();
    } catch (e) {
      _showErrorSnackbar('Error deleting product');
    } finally {
      _setLoading(false);
    }
  }

  void _navigateToMarketAdds() {
    Get.off(() => const MyMarketAdds());
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.errorRed.withOpacity(0.8),
      colorText: AppColors.whiteColor,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingView()
          : _buildProductView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.secondary,
      ),
    );
  }

  Widget _buildProductView() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildProductImageHeader(),
            const SizedBox(height: 15),
            _buildProductTitle(),
            _buildProductLocation(),
            const SizedBox(height: 20),
            ..._buildInfoSections(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return CustomAppBar(
      title: "Market Product",
      backButton: true,
      signOutIcon: false,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.whiteColor,
    );
  }

  Widget _buildProductImageHeader() {
    return Hero(
      tag: productDocId,
      child: Container(
        height: 220.0,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Image.network(
          productImage,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.secondary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.error_outline,
                color: AppColors.errorRed,
                size: 40,
              ),
            );
          },
        ),
      ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
    );
  }

  Widget _buildProductTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        productName,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ).animate().slideX(begin: -0.2, end: 0, duration: const Duration(milliseconds: 400)),
    );
  }

  Widget _buildProductLocation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.secondary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            productLocation,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
    );
  }

  List<Widget> _buildInfoSections() {
    return [
      _buildInfoSection(
        title: "Product Quantity",
        icon: Icons.countertops,
        content: productQuantity.toString(),
        delay: 100,
      ),
      _buildInfoSection(
        title: "Product Price",
        icon: Icons.price_change_rounded,
        content: productPrice,
        delay: 200,
      ),
      _buildInfoSection(
        title: "Contact",
        icon: Icons.contact_page,
        content: productContact,
        delay: 300,
      ),
      _buildDescriptionSection(delay: 400),
    ];
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required String content,
    required int delay,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primary,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {}, // Optional interaction
              splashColor: AppColors.secondary.withOpacity(0.3),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: AppColors.whiteColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        content,
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.2, end: 0);
  }

  Widget _buildDescriptionSection({required int delay}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Product Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primary,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              productDescription,
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.2, end: 0);
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            label: "Mark as Sold",
            icon: MdiIcons.sale,
            color: AppColors.success,
            onPressed: _markAsSold,
            delay: 500,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            label: "Delete",
            icon: MdiIcons.delete,
            color: AppColors.errorRed,
            onPressed: _deleteProduct,
            delay: 600,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required int delay,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.whiteColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay)).scale(delay: Duration(milliseconds: delay), duration: const Duration(milliseconds: 300)),
    );
  }
}