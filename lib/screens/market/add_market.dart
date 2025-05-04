import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/colors.dart';
import '../../widgets/button.dart';
import '../../widgets/animated_gradient_button.dart';
import '../../widgets/round_text_field.dart';
import '../market/my_market_adds.dart';

class AddMarketScreen extends StatefulWidget {
  const AddMarketScreen({Key? key}) : super(key: key);

  @override
  State<AddMarketScreen> createState() => _AddMarketScreenState();
}

class _AddMarketScreenState extends State<AddMarketScreen> with SingleTickerProviderStateMixin {
  // Form and controllers
  final _formKey = GlobalKey<FormState>();
  final contactController = TextEditingController();
  final qtyController = TextEditingController();
  final locationController = TextEditingController();
  final descController = TextEditingController();

  // User and Firebase references
  final User? userId = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Product selection
  String? _selectedProduct;
  List<String> _products = [];

  // Image handling
  File? _selectedImage;
  String imageUrl = '';
  bool _isUploading = false;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    contactController.dispose();
    qtyController.dispose();
    locationController.dispose();
    descController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Fetch available products from Firestore
  Future<void> _fetchProducts() async {
    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showErrorSnackbar('User not logged in.');
        return;
      }

      QuerySnapshot snapshot = await _firestore
          .collection('inventoryProducts')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        _products = snapshot.docs
            .map((doc) => (doc.data() as Map<String, dynamic>)['productTitle'] as String? ?? '')
            .where((title) => title.isNotEmpty)
            .toList();

        _selectedProduct = _products.isNotEmpty ? _products[0] : null;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorSnackbar('Failed to fetch products: $e');
    }
  }

  // Pick image from gallery with proper permission handling
  Future<void> _pickImage() async {
    // Check current permission status
    var status = await Permission.photos.status;

    if (status.isDenied) {
      // Request permission explicitly
      status = await Permission.photos.request();
    }

    // If permission still denied after request
    if (status.isDenied) {
      _showPermissionDialog();
      return;
    }

    // If permission permanently denied, open settings
    if (status.isPermanentlyDenied) {
      _showSettingsDialog();
      return;
    }

    // Permission granted, proceed with image picking
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optimize image quality
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackbar('Error picking image: $e');
    }
  }

  // Show dialog explaining why permission is needed
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Photo Permission Required'),
        content: const Text(
            'We need access to your photos to upload a product image. Please grant permission to continue.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context); // close the dialog if any
              var status = await Permission.photos.request();

              if (status.isGranted) {
                _pickImage();
              } else if (status.isPermanentlyDenied || status.isDenied) {
                // If permission is denied forever, open settings
                await openAppSettings();
              }
            },
            child: const Text('Request Permission'),
          )

        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // Show dialog to open app settings when permission is permanently denied
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Photo access permission was permanently denied. Please enable it in app settings to upload product images.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImageToFirebase() async {
    if (_selectedImage == null) return null;

    setState(() => _isUploading = true);

    try {
      // Create a unique filename
      String uniqueFilename = '${userId?.uid}_${DateTime.now().millisecondsSinceEpoch}';
      Reference storageRef = _storage.ref().child('market_images/$uniqueFilename');

      // Upload file
      await storageRef.putFile(_selectedImage!);

      // Get download URL
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() => _isUploading = false);
      return downloadUrl;
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorSnackbar('Failed to upload image: $e');
      return null;
    }
  }

  // Validate and submit the form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      _showImageSelectionDialog();
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Get form values
      final product = _selectedProduct;
      final qty = int.parse(qtyController.text.trim());
      final location = locationController.text.trim();
      final contact = contactController.text.trim();
      final description = descController.text.trim();

      // Check if product exists and has enough quantity
      final DocumentSnapshot productDoc = await _firestore
          .collection("inventoryProducts")
          .doc(product)
          .get();

      if (!productDoc.exists) {
        _showErrorSnackbar('Selected product does not exist');
        setState(() => _isUploading = false);
        return;
      }

      final productData = productDoc.data() as Map<String, dynamic>;
      final int currentQty = productData['qty'] ?? 0;
      final price = productData['productPrice'] ?? '';

      // Check if enough quantity is available
      if (qty > currentQty) {
        _showErrorSnackbar('Not enough quantity available. Currently in stock: $currentQty');
        setState(() => _isUploading = false);
        return;
      }

      // Upload image
      final uploadedImageUrl = await _uploadImageToFirebase();
      if (uploadedImageUrl == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Calculate new quantity
      final int newQty = currentQty - qty;

      // Use transaction to ensure atomic operations
      await _firestore.runTransaction((transaction) async {
        // Update inventory product quantity
        transaction.update(
            _firestore.collection("inventoryProducts").doc(product),
            {'qty': newQty}
        );

        // Add to marketplace
        DocumentReference newDocRef = _firestore.collection("marketPlace").doc();
        transaction.set(newDocRef, {
          "createdAT": DateTime.now(),
          "userId": userId?.uid,
          "product": product,
          "qty": qty,
          "price": price,
          "location": location,
          "contact": contact,
          "image": uploadedImageUrl,
          "description": description,
          "sold": "No",
        });
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product posted successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      // Navigate to My Market Adds screen
      Get.off(() => MyMarketAdds());
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorSnackbar('Error posting product: $e');
    }
  }

  // Show dialog prompting user to select an image
  void _showImageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Image Required'),
        content: const Text(
            'Please select an image for your product. Products with images get more attention!'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _pickImage();
            },
            child: const Text('Select Image'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: const Text(
        "Add Product",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      foregroundColor: Colors.white,
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildProductDropdown(),
              const SizedBox(height: 16),
              _buildQuantityField(),
              const SizedBox(height: 16),
              _buildLocationField(),
              const SizedBox(height: 16),
              _buildContactField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: _selectedImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_rounded,
              size: 50,
              color: AppColors.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              "Tap to add product image",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.category_rounded,
            color: AppColors.primary.withOpacity(0.7),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Select Product',
          hintStyle: TextStyle(color: AppColors.textLight),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        value: _selectedProduct,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        dropdownColor: Colors.white,
        items: _products.map((product) {
          return DropdownMenuItem<String>(
            value: product,
            child: Text(product),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedProduct = newValue!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a product';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildQuantityField() {
    return RoundTitleTextfield(
      controller: qtyController,
      title: 'Quantity',
      hintText: 'Enter quantity',
      left: Icon(Icons.production_quantity_limits_rounded),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter quantity';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        if (int.parse(value) <= 0) {
          return 'Quantity must be greater than 0';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return RoundTitleTextfield(
      controller: locationController,
      title: 'Location',
      hintText: 'Enter your location',
      left: Icon(Icons.location_on_rounded),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a location';
        }
        return null;
      },
    );
  }

  Widget _buildContactField() {
    return RoundTitleTextfield(
      controller: contactController,
      title: 'Contact',
      hintText: 'Enter your contact number',
      left: Icon(Icons.phone_rounded),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a contact number';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return RoundTitleTextfield(
      controller: descController,
      title: 'Description',
      hintText: 'Enter product description',
      left: Icon(Icons.description_rounded),
      maxLines: 4,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: AnimatedGradientButton(
        title: "Post Product",
        icon: Icons.post_add_rounded,
        onTap: _isUploading ? () {} : _submitForm,
        isLoading: _isUploading,
        height: 55,
        width: double.infinity,
      ),
    );
  }
}