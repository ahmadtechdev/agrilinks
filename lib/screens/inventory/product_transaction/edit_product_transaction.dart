import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utils/colors.dart';
import '../../../widgets/animated_gradient_button.dart';
import '../../../widgets/round_text_field.dart';
import 'product_transaction.dart';

class EditTransaction extends StatefulWidget {
  const EditTransaction({super.key});

  @override
  State<EditTransaction> createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> with SingleTickerProviderStateMixin {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // User data
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Transaction data from arguments
  late final String _qty;
  late final String _title;
  late final String _docId;
  late String _selectedType;

  // Controllers
  final TextEditingController _qtyController = TextEditingController();

  // UI state
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize transaction data from arguments
    _qty = Get.arguments['qty'].toString();
    _title = Get.arguments['title'].toString();
    _docId = Get.arguments['docId'].toString();
    _selectedType = Get.arguments['type'].toString();

    // Set initial controller values
    _qtyController.text = _qty;

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Update transaction in Firestore
  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _isUpdating = true;
        _errorMessage = null;
      });

      final newQty = _qtyController.text.trim();

      // Get current transaction data
      final transactionSnapshot = await FirebaseFirestore.instance
          .collection("productTransaction")
          .doc(_docId)
          .get();

      final int oldQty = transactionSnapshot.data()?['qty'];
      final String oldType = transactionSnapshot.data()?['type'];

      // Get current inventory data
      final inventorySnapshot = await FirebaseFirestore.instance
          .collection("inventoryProducts")
          .doc(_title)
          .get();

      int currentInventoryQty = inventorySnapshot.data()?['qty'] ?? 0;

      // Calculate the inventory before this transaction was applied
      int inventoryBeforeTransaction;
      if (oldType == "Send") {
        // If it was a send, add it back to get original
        inventoryBeforeTransaction = currentInventoryQty + oldQty;
      } else {
        // If it was a receive, subtract it to get original
        inventoryBeforeTransaction = currentInventoryQty - oldQty;
      }

      // Calculate new inventory after applying updated transaction
      int newInventoryQty;
      if (_selectedType == "Send") {
        // Sending reduces inventory
        newInventoryQty = inventoryBeforeTransaction - int.parse(newQty);

        // Check if we have enough to send
        if (newInventoryQty < 0) {
          setState(() {
            _isLoading = false;
            _isUpdating = false;
            _errorMessage = "Not enough quantity available in inventory";
          });

          _showErrorSnackbar("Not enough quantity available in inventory. Available: $inventoryBeforeTransaction");
          return;
        }
      } else {
        // Receiving increases inventory
        newInventoryQty = inventoryBeforeTransaction + int.parse(newQty);
      }

      // Update transaction record
      await FirebaseFirestore.instance
          .collection("productTransaction")
          .doc(_docId)
          .update({
        'qty': int.parse(newQty),
        'type': _selectedType,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update inventory quantity
      await FirebaseFirestore.instance
          .collection("inventoryProducts")
          .doc(_title)
          .update({
        'qty': newInventoryQty,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Show success message
      _showSuccessSnackbar("Transaction updated successfully");

      // Navigate back with slight delay for better UX
      Future.delayed(const Duration(milliseconds: 800), () {
        Get.off(
              () => const TransactionHistory(),
          arguments: {'title': _title},
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 400),
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isUpdating = false;
        _errorMessage = "Failed to update: $e";
      });

      _showErrorSnackbar("Error updating transaction: $e");
    }
  }

  // Show success snackbar
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      backgroundColor: AppColors.backgroundColor,
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: const Text(
        "Edit Transaction",
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
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTransactionDetailsCard(),
                  const SizedBox(height: 32),
                  _buildEditForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Edit Transaction",
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Update details for $_title transaction",
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Transaction ID: ${_docId.substring(0, 8)}...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white30),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTransactionDetailItem(
                label: "Current Quantity",
                value: _qty,
                icon: Icons.production_quantity_limits,
              ),
              _buildTransactionDetailItem(
                label: "Current Type",
                value: Get.arguments['type'].toString(),
                icon: Icons.swap_horiz,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update Information",
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Quantity field
            RoundTitleTextfield(
              title: "Quantity",
              hintText: "Enter new quantity",
              controller: _qtyController,
              keyboardType: TextInputType.number,
              left: Icon(
                Icons.production_quantity_limits,
                color: AppColors.primary.withOpacity(0.6),
                size: 20,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a quantity";
                }

                final intValue = int.tryParse(value);
                if (intValue == null) {
                  return "Please enter a valid number";
                }

                if (intValue <= 0) {
                  return "Quantity must be greater than 0";
                }

                return null;
              },
            ),
            const SizedBox(height: 24),

            // Transaction type dropdown
            _buildTransactionTypeSelector(),
            const SizedBox(height: 32),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.errorRed.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.errorRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.errorRed,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Update button
            AnimatedGradientButton(
              title: "Update Transaction",
              icon: Icons.update,
              isLoading: _isUpdating,
              onTap: _updateTransaction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            "Transaction Type",
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textField,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _buildTypeOption("Received", Icons.arrow_downward),
              _buildTypeOption("Send", Icons.arrow_upward),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(String type, IconData icon) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primaryText,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primaryText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}