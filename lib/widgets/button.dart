import 'package:flutter/material.dart';
import '../utils/colors.dart';

class RoundedButton extends StatefulWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final bool isOutlined;
  final bool isFullWidth;
  final bool useGradient;
  final EdgeInsets padding;
  final double borderRadius;
  final double iconSize;
  final double elevation;

  const RoundedButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.height = 50,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.useGradient = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.borderRadius = 25,
    this.iconSize = 22,
    this.elevation = 2,
  });

  @override
  State<RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.backgroundColor ??
        (widget.isOutlined ? Colors.transparent : AppColors.secondary);

    final Color txtColor = widget.textColor ??
        (widget.isOutlined ? AppColors.primary : AppColors.primary);

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          height: widget.height,
          width: widget.isFullWidth ? double.infinity : null,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.useGradient ? null : bgColor,
            gradient: widget.useGradient
                ? LinearGradient(
              colors: AppColors.secondaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.isOutlined
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
            boxShadow: widget.isOutlined
                ? null
                : [
              BoxShadow(
                color: (widget.backgroundColor ?? AppColors.secondary).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: widget.elevation * 2,
                offset: Offset(0, widget.elevation),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: txtColor,
                  size: widget.iconSize,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.title,
                style: TextStyle(
                  color: txtColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}