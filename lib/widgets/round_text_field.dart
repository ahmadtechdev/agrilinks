import 'package:flutter/material.dart';

import '../utils/colors.dart';

class RoundTitleTextfield extends StatefulWidget {
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
  final int? maxLines;
  final double? height;
  final FormFieldValidator<String>? validator;

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
    this.maxLines = 1,
    this.height,
    this.validator,
  });

  @override
  State<RoundTitleTextfield> createState() => _RoundTitleTextfieldState();
}

class _RoundTitleTextfieldState extends State<RoundTitleTextfield> {
  late TextEditingController effectiveController;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    effectiveController = widget.controller ?? TextEditingController();
    if (widget.initialValue != null && effectiveController.text.isEmpty) {
      effectiveController.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      effectiveController.dispose();
    }
    super.dispose();
  }

  bool get _hasText => effectiveController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bool shouldFloat = _isFocused || _hasText;
    final containerHeight = widget.height ??
        (widget.maxLines == 1 ? 60.0 : (widget.maxLines ?? 1) * 24.0 + 40.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: containerHeight,
          decoration: BoxDecoration(
            color: widget.readOnly
                ? AppColors.readOnlyTextField
                : widget.bgColor ?? AppColors.textField,
            borderRadius: BorderRadius.circular(25),
            border: _isFocused
                ? Border.all(color: AppColors.secondary, width: 1.5)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.left != null)
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: widget.left!,
                ),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutQuad,
                      left: 20,
                      top: shouldFloat ? -8 : (containerHeight / 2) - 10,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        color: shouldFloat
                            ? widget.readOnly
                            ? AppColors.readOnlyTextField
                            : widget.bgColor ?? AppColors.textField
                            : Colors.transparent,
                        child: AnimatedDefaultTextStyle(
                          style: TextStyle(
                            fontSize: shouldFloat ? 12 : 14,
                            color: shouldFloat
                                ? AppColors.secondary
                                : AppColors.placeholder,
                            fontWeight: shouldFloat ? FontWeight.w500 : FontWeight.normal,
                          ),
                          duration: const Duration(milliseconds: 200),
                          child: Text(widget.title),
                        ),
                      ),
                    ),
                    Container(
                      height: containerHeight,
                      alignment: Alignment.center,
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          setState(() {
                            _isFocused = hasFocus;
                          });
                        },
                        child: TextFormField(
                          style: TextStyle(
                            color: widget.readOnly
                                ? AppColors.readOnlyText
                                : widget.textClr ?? AppColors.primaryText,
                            fontSize: 15,
                          ),
                          autocorrect: false,
                          controller: effectiveController,
                          obscureText: widget.obscureText,
                          keyboardType: widget.keyboardType,
                          readOnly: widget.readOnly,
                          onChanged: (value) {
                            setState(() {
                              // Clear error when typing
                              if (_errorText != null) {
                                _errorText = null;
                              }
                            });
                            if (widget.onChanged != null) {
                              widget.onChanged!(value);
                            }
                          },
                          onEditingComplete: widget.onEditingComplete,
                          maxLines: widget.maxLines,
                          minLines: 1,
                          validator: (value) {
                            if (widget.validator != null) {
                              final error = widget.validator!(value);
                              setState(() {
                                _errorText = error;
                              });
                              return error;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: shouldFloat ? 12 : 0,
                              bottom: widget.maxLines == 1 ? 0 : 12,
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            hintText: shouldFloat ? widget.hintText : "",
                            errorStyle: const TextStyle(height: 0, color: Colors.transparent),
                            hintStyle: TextStyle(
                              color: AppColors.placeholder,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.right != null)
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: widget.right!,
                ),
            ],
          ),
        ),
        // Error message
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 6),
            child: Text(
              _errorText!,
              style: TextStyle(
                color: AppColors.redColor,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}