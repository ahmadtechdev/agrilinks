import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../inventory_screen/inventory_controller.dart';
import '../../../utils/colors.dart';
import '../../../widgets/navbar.dart';
import '../../../widgets/bottom_navigation.dart';
import '../product_info/product_info.dart';
import '../add_inventory/add_inventory_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  final InventoryController _controller = Get.put(InventoryController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
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
      drawer: NavBar(),
      appBar: _buildAppBar(context),
      backgroundColor: AppColors.backgroundColor,
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 1),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: AppColors.primary,
      title: Image.asset(
        'assets/logo1.png',
        scale: 3,
      ),
      foregroundColor: AppColors.whiteColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      toolbarHeight: MediaQuery.of(context).size.height / 8,
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildSearchBar(),
          _buildInventoryList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _controller.searchController,
        onChanged: (value) {
          _controller.searchQuery.value = value;
        },
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(color: AppColors.placeholder),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    return Expanded(
      child: StreamBuilder(
        stream: _controller.getInventoryProductsStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return _buildErrorMessage("Something went wrong!");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          }

          if (snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          List<QueryDocumentSnapshot> filteredDocs = snapshot.data!.docs.where((doc) {
            var title = doc['productTitle'].toString().toLowerCase();
            return title.contains(_controller.searchQuery.value.toLowerCase());
          }).toList();

          return _buildAnimatedListView(filteredDocs);
        },
      ),
    );
  }

  Widget _buildAnimatedListView(List<QueryDocumentSnapshot> docs) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 80),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildProductCard(docs[index], index),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(QueryDocumentSnapshot document, int index) {
    var timestampString = document['createdAT'];
    DateTime timestamp = DateTime.parse(timestampString.toDate().toString());
    var formattedDate = _controller.formatDate(timestamp);

    var title = document['productTitle'];
    var price = document['productPrice'];
    var qty = document['qty'];
    var detail = document['detail'];
    var docId = document.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Get.to(() => ProductInfo(), arguments: {
            'date': formattedDate,
            'title': title,
            'price': price,
            'qty': qty,
            'detail': detail,
            'docId': docId,
          });
        },
        child: Dismissible(
          key: Key(docId),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.redColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.delete,
              color: AppColors.whiteColor,
              size: 30,
            ),
          ),
          onDismissed: (direction) async {
            await _controller.deleteProduct(docId);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Hero(
                    tag: 'product_$docId',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.subtleAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/parcel.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.secondaryText
                        ),
                        SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, color: AppColors.dividerColor),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs. $price",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 16,
                                color: AppColors.whiteColor
                            ),
                            SizedBox(width: 4),
                            Text(
                              qty.toString(),
                              style: TextStyle(
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.redColor,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.secondaryText.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            "Your inventory is empty",
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Add products to get started",
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.buttonGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {
          Get.to(() => const AddInventoryScreen(),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 500),
          );
        },
        child: Icon(
          Icons.add,
          color: AppColors.whiteColor,
          size: 28,
        ),
      ),
    );
  }
}