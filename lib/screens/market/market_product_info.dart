import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../../utils/colors.dart';
import '../../widgets/app_bar.dart';

class MarketProductController extends GetxController {
  // Product data
  final productData = Get.arguments;

  // For animations
  final animationDuration = const Duration(milliseconds: 300);
  final animationCurve = Curves.easeInOut;

  // Launch phone dialer
  Future<void> launchPhoneDialer() async {
    final phoneNumber = productData['contact'].toString();
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar(
          'Error',
          'Cannot launch phone dialer',
          backgroundColor: AppColors.redColor,
          colorText: AppColors.whiteColor,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to launch phone dialer: $e',
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteColor,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Launch WhatsApp
  Future<void> launchWhatsApp() async {
    final phoneNumber = productData['contact'].toString().replaceAll(' ', '');
    final Uri uri = Uri.parse('https://wa.me/$phoneNumber');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'WhatsApp is not installed',
          backgroundColor: AppColors.redColor,
          colorText: AppColors.whiteColor,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to launch WhatsApp: $e',
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteColor,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class MarketProduct extends StatefulWidget {
  const MarketProduct({super.key});

  @override
  State<MarketProduct> createState() => _MarketProductState();
}

class _MarketProductState extends State<MarketProduct> with TickerProviderStateMixin {
  // Controller
  late final MarketProductController controller;

  // Animation controllers
  late final AnimationController _fadeController;
  late final AnimationController _slideController;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    controller = Get.put(MarketProductController());

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create animations
    final fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      Get.arguments['product'].toString(),
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Product image with gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.primaryGradient,
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Hero(
                            tag: Get.arguments['image'].toString(),
                            child: Image.network(
                              Get.arguments['image'].toString(),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // Gradient overlay for better text visibility
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 80,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.8),
                                  AppColors.primary.withOpacity(0),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: wColor),
                    onPressed: () => Get.back(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share, color: wColor),
                      onPressed: () {
                        // Share functionality can be added here
                        HapticFeedback.mediumImpact();
                        Get.snackbar(
                          'Share',
                          'Share functionality will be implemented here',
                          backgroundColor: AppColors.infoColor,
                          colorText: AppColors.whiteColor,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ],
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location
                        _buildInfoCard(
                          icon: Icons.location_on,
                          content: Get.arguments['location'].toString(),
                          iconColor: AppColors.secondary,
                        ),

                        const SizedBox(height: 16),

                        // Contact Section with Phone and WhatsApp buttons
                        _buildSectionTitle('Contact'),
                        _buildContactButtons(),

                        const SizedBox(height: 16),

                        // Product Details
                        _buildSectionTitle('Product Details'),

                        // Product Quantity
                        _buildDetailCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Quantity',
                          value: Get.arguments['qty'].toString(),
                        ),

                        const SizedBox(height: 12),

                        // Product Price
                        _buildDetailCard(
                          icon: Icons.attach_money,
                          label: 'Price',
                          value: Get.arguments['price'].toString(),
                          isHighlighted: true,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        _buildSectionTitle('Description'),
                        _buildDescriptionCard(Get.arguments['description'].toString()),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String content,
    Color? iconColor,
  }) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.phone,
            label: 'Call',
            color: AppColors.successColor,
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.launchPhoneDialer();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.message,
            label: 'WhatsApp',
            color: const Color(0xFF25D366), // WhatsApp color
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.launchWhatsApp();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isHighlighted
              ? LinearGradient(
            colors: AppColors.secondaryGradient,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          )
              : LinearGradient(
            colors: [
              AppColors.subtleBackground,
              AppColors.cardBackground,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isHighlighted ? Colors.white : AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: isHighlighted ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isHighlighted ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.cardBackground,
        ),
        child: Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}