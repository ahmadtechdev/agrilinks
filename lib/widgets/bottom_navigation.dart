// bottom_navigation.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/inventory/inventory_screen/inventory_screen.dart';
import '../screens/market/market_screen.dart';
import '../screens/newsfeed/newsfeed_screen.dart';
import '../utils/colors.dart';


class CustomBottomNavigationBar extends StatelessWidget {
  // Optional parameter - only pass when on a bottom nav page
  final int? selectedIndex;

  const CustomBottomNavigationBar({
    super.key,
    this.selectedIndex,
  });

  void _handleNavigation(BuildContext context, int index) {
    // Navigate based on index
    switch (index) {
      case 0:
        // Get.to(() => HomeScreen());
        break;
      case 1:
        Get.to(() => InventoryScreen());
        break;
      case 2:
        Get.to(() => NewsFeedScreen());

        break;
      case 3:

        Get.to(() => MarketScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      child: Theme(
        // Override the theme to show unselected items when no index is provided
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme:
              BottomNavigationBarTheme.of(context).copyWith(
            selectedItemColor:
                selectedIndex != null ? AppColors.secondary : AppColors.whiteColor,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primary,
          unselectedItemColor: AppColors.whiteColor,
          currentIndex: selectedIndex ??
              0, // Use 0 as default but style all items as unselected when null
          onTap: (index) => _handleNavigation(context, index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper),
              label: 'NewsFeed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Market',
            ),
          ],
        ),
      ),
    );
  }
}
