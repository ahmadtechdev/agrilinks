import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../utils/colors.dart';
import '../inventory/inventory_screen/inventory_screen.dart';
import '../market/market_screen.dart';
import 'newsfeed_controller.dart';
import 'newsfeed_screen.dart';
import 'newsfeed_widget.dart';

class AddNewsFeedScreen extends StatefulWidget {
  @override
  State<AddNewsFeedScreen> createState() => _AddNewsFeedScreenState();
}

class _AddNewsFeedScreenState extends State<AddNewsFeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _postController = TextEditingController();
  final NewsFeedController _controller = Get.find<NewsFeedController>();

  @override
  void dispose() {
    _titleController.dispose();
    _postController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      final success = await _controller.createPost(
        title: _titleController.text.trim(),
        content: _postController.text.trim(),
      );

      if (success) {
        Get.offAll(() => NewsFeedScreen());
        Get.snackbar(
          'Success',
          'Your post has been published',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primary,
        title: const Text(
          "Create Post",
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: AppColors.textLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        elevation: 4,
        shadowColor: AppColors.shadow,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Obx(() {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Share something with the community",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title Field
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'Enter a catchy title',
                        icon: Icons.title,
                        maxLength: 100,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Content Field
                      _buildTextField(
                        controller: _postController,
                        label: 'Content',
                        hint: 'Share your thoughts...',
                        maxLines: 10,
                        minLines: 5,
                        maxLength: 500,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter some content';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Image Upload Section
                      _buildImageUploadSection(),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          icon: _controller.isSubmitting.value
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.textLight,
                              strokeWidth: 3,
                            ),
                          )
                              : const Icon(Icons.send_rounded),
                          label: Text(
                            _controller.isSubmitting.value ? "Posting..." : "Post",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textLight,
                            elevation: 4,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _controller.isSubmitting.value ? null : _submitPost,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    int? maxLines = 1,
    int? minLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          alignLabelWithHint: maxLines! > 1,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(20),
          prefixIcon: icon != null
              ? Icon(
            icon,
            color: AppColors.primary,
          )
              : null,
        ),
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
          return Container(
            padding: const EdgeInsets.only(right: 16),
            alignment: Alignment.centerRight,
            child: Text(
              '$currentLength/$maxLength',
              style: TextStyle(
                fontSize: 12,
                color: currentLength >= maxLength!
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
          );
        },
        validator: validator,
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controller.selectedImagePath.value.isNotEmpty)
            ImagePreviewWidget(
              imagePath: _controller.selectedImagePath.value,
              onRemove: _controller.removeSelectedImage,
            ),
          if (_controller.selectedImagePath.value.isEmpty)
            InkWell(
              onTap: _controller.pickImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Add an image",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tap to browse",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}