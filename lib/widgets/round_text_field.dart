import 'package:flutter/material.dart';

import '../utils/colors.dart';


class RoundTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Color? bgColor;
  final Widget? left;
  final Widget? right; // Optional right-side icon or widget
  final Function(String)? onChanged;

  const RoundTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.bgColor,
    this.left,
    this.right,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: bgColor ?? AppColors.textField,
          borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          if (left != null)
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: left!,
            ),
          Expanded(
            child: TextField(
              autocorrect: false,
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                    color: AppColors.placeholder,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          if (right != null)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: right!,
            ),
        ],
      ),
    );
  }
}

class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String> onChange;

  const SearchTextField({
    super.key,
    required this.hintText,
    this.controller,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: controller,
        onChanged: onChange,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.placeholder),
          prefixIcon: Icon(Icons.search, color: AppColors.secondary),
          filled: true,
          fillColor: AppColors.textField,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.secondary),
          ),
        ),
      ),
    );
  }
}

class RoundTitleTextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String title;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final Color? bgColor;
  final Widget? left;
  final Widget? right;
  final Function(String)? onChanged;
  final String? initialValue;
  final VoidCallback? onEditingComplete;
  final Color? textClr;
  final int? maxLines; // Added maxLines parameter
  final double? height; // Added optional height parameter

  const RoundTitleTextfield({
    super.key,
    required this.title,
    this.hintText = "",
    this.controller,
    this.keyboardType,
    this.bgColor,
    this.left,
    this.right,
    this.onChanged,
    this.initialValue,
    this.obscureText = false,
    this.readOnly = false,
    this.onEditingComplete,
    this.textClr,
    this.maxLines = 1, // Default to 1 line
    this.height, // Optional height override
  });

  @override
  Widget build(BuildContext context) {
    final effectiveController = controller ?? TextEditingController();

    if (initialValue != null && effectiveController.text.isEmpty) {
      effectiveController.text = initialValue!;
    }

    // Calculate dynamic height based on maxLines
    final containerHeight = height ?? (maxLines == 1 ? 55.0 : (maxLines ?? 1) * 24.0 + 35.0);

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
          color: bgColor ?? AppColors.textField,
          borderRadius: BorderRadius.circular(25)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top for multiline
        children: [
          if (left != null)
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 15),
              child: left!,
            ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: containerHeight,
                  margin: const EdgeInsets.only(top: 8),
                  alignment: Alignment.topLeft,
                  child: TextField(
                    style: TextStyle(color: textClr ?? AppColors.primaryText),
                    autocorrect: false,
                    controller: effectiveController,
                    obscureText: obscureText,
                    keyboardType: keyboardType,
                    readOnly: readOnly,
                    onChanged: onChanged,
                    onEditingComplete: onEditingComplete,
                    maxLines: maxLines, // Use the maxLines parameter
                    minLines: 1, // Allow collapsing to single line
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: maxLines == 1 ? 0 : 15, // Adjust vertical padding for multiline
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: hintText,
                      hintStyle: TextStyle(
                          color: AppColors.placeholder,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Container(
                  height: 20,
                  margin: const EdgeInsets.only(top: 10, left: 20),
                  alignment: Alignment.topLeft,
                  child: Text(
                    title,
                    style: TextStyle(color: AppColors.placeholder, fontSize: 11),
                  ),
                )
              ],
            ),
          ),
          if (right != null)
            Padding(
              padding: const EdgeInsets.only(right: 0, top: 15),
              child: right!,
            ),
        ],
      ),
    );
  }
}
