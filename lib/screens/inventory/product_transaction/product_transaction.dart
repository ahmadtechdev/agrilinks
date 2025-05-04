import 'package:agrlinks_app/screens/inventory/add_inventory/add_inventory_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utils/colors.dart';
import '../../../widgets/button.dart';
import 'edit_product_transaction.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> with SingleTickerProviderStateMixin {
  // Core data
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late final String _title;

  // Controllers
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _animation;

  // State variables
  String _selectedType = "Received";
  List<String> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = Get.arguments['title'].toString();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _dateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Fetch transactions stream
  Stream<QuerySnapshot> _getTransactions() {
    return FirebaseFirestore.instance
        .collection("productTransaction")
        .where("userId", isEqualTo: _currentUser?.uid)
        .where("title", isEqualTo: _title)
        .orderBy("createdAT", descending: true)
        .snapshots();
  }

  // Delete transaction
  Future<void> _deleteTransaction(String docId) async {
    try {
      setState(() => _isLoading = true);
      await FirebaseFirestore.instance
          .collection("productTransaction")
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaction deleted successfully'),
          backgroundColor: AppColors.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting transaction: $e'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Navigate to edit screen
  void _navigateToEdit(String docId, String type, int qty) {
    Get.to(
            () => const EditTransaction(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
        arguments: {
          'qty': qty,
          'title': _title,
          'docId': docId,
          'type': type,
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      backgroundColor: AppColors.backgroundColor,
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: const Text(
        "Product Transaction",
        style: TextStyle(
          color: wColor,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: wColor),
        onPressed: () => Get.back(),
      ),
      foregroundColor: wColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      toolbarHeight: MediaQuery.of(context).size.height / 10,
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _animation,
      child: StreamBuilder<QuerySnapshot>(
        stream: _getTransactions(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return const Center(
              child: CupertinoActivityIndicator(
                color: primaryColor,
                radius: 15,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorWidget("Something went wrong!");
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return _buildEmptyWidget();
          }

          return _buildTransactionList(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: AppColors.errorRed),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/empty-box.png",
            height: 120,
            width: 120,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            "No transactions found",
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first transaction to get started",
            style: TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(QuerySnapshot data) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: data.docs.length,
      itemBuilder: (context, index) {
        var doc = data.docs[index];
        var timestampString = doc['createdAT'];
        DateTime timestamp = DateTime.parse(timestampString.toDate().toString());

        var titleProduct = doc['title'];
        var type = doc['type'];
        var qty = doc['qty'];
        var docId = doc.id;

        return _buildTransactionCard(
          docId: docId,
          title: titleProduct,
          timestamp: timestamp,
          type: type,
          qty: int.parse(qty),
          index: index,
        );
      },
    );
  }

  Widget _buildTransactionCard({
    required String docId,
    required String title,
    required DateTime timestamp,
    required String type,
    required int qty,
    required int index,
  }) {
    // Staggered animation
    Future.delayed(Duration(milliseconds: 50 * index), () {
      if (_animationController.status != AnimationStatus.forward) {
        _animationController.reset();
        _animationController.forward();
      }
    });

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.4, 1.0, curve: Curves.easeOut),
      )),
      child: Dismissible(
        key: Key(docId),
        direction: DismissDirection.startToEnd,
        background: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppColors.errorRed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Icon(
              Icons.delete_outline_rounded,
              color: wColor,
              size: 28,
            ),
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Confirm Delete"),
              content: const Text("Are you sure you want to delete this transaction?"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Delete",
                    style: TextStyle(color: AppColors.errorRed),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) => _deleteTransaction(docId),
        child: GestureDetector(
          onTap: () => _navigateToEdit(docId, type, qty),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.subtleAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/parcel.png",
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatDateTime(timestamp),
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
              trailing: _buildTransactionBadge(type, qty),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionBadge(String type, int qty) {
    Color badgeColor = type == "Send"
        ? AppColors.errorRed
        : type == "Received"
        ? AppColors.primary
        : AppColors.warningColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$qty qty",
            style: const TextStyle(
              color: wColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            type,
            style: const TextStyle(
              color: wColor,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Add functionality to create new transaction
        // This could navigate to a creation form
        Get.to(()=> AddInventoryScreen());
      },
      backgroundColor: AppColors.secondary,
      elevation: 4,
      child: const Icon(Icons.add, color: wColor),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('E, d MMM yy • h:mm a');
    return formatter.format(dateTime);
  }
}