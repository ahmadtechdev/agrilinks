// market_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../utils/colors.dart';
import '../../widgets/navbar.dart';
import '../../widgets/bottom_navigation.dart';
import 'market_controller.dart';
import 'market_widgets.dart';
import 'my_market_adds.dart';
import 'market_product_info.dart';


class MarketScreen extends StatefulWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  // GetX Controller
  final MarketController _controller = Get.put(MarketController());
  final TextEditingController _searchController = TextEditingController();

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: _buildAppBar(),
      backgroundColor: AppColors.subtleBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Bar
            AnimatedSearchBar(
              controller: _searchController,
              onChanged: (value) {
                _controller.updateSearchQuery(value);
              },
            ),

            // Market Products List
            Expanded(
              child: _buildProductsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 3),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        "Market Place",
        style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      foregroundColor: AppColors.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _controller.fetchMarketProducts(),
          tooltip: 'Refresh',
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(15),
        child: Container(height: 15),
      ),
    );
  }

  Widget _buildProductsList() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return  Center(
          child: CupertinoActivityIndicator(
            radius: 15,
            color: AppColors.secondary,
          ),
        );
      }

      final filteredProducts = _controller.filteredProducts;

      if (filteredProducts.isEmpty) {
        return _buildEmptyState();
      }

      return AnimationLimiter(
        child: RefreshIndicator(
          color: AppColors.secondary,
          backgroundColor: AppColors.whiteColor,
          onRefresh: _controller.fetchMarketProducts,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),  // Space for FAB
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: ProductCard(
                      product: product,
                      onTap: () => _navigateToProductDetails(product),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: AppColors.secondaryText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _controller.searchQuery.isNotEmpty
                ? "No products matching '${_controller.searchQuery}'"
                : "No products available",
            style: TextStyle(
              fontSize: 18,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (_controller.searchQuery.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text("Clear Search"),
              onPressed: () {
                _searchController.clear();
                _controller.updateSearchQuery('');
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.whiteColor,
      elevation: 5,
      onPressed: () {
        Get.to(() => MyMarketAdds());
      },
      icon: const Icon(Icons.add_business),
      label: const Text("My Listings"),
    );
  }

  void _navigateToProductDetails(MarketProductModel product) {
    Get.to(
          () => MarketProduct(),
      arguments: {
        'product': product.product,
        'price': product.price,
        'qty': product.qty,
        'location': product.location,
        'description': product.description,
        'image': product.image,
        'contact': product.contact,
        'docId': product.docId,
      },
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}