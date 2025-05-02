import 'package:flutter/material.dart';

import 'utils/colors.dart';

class RoundButton extends StatelessWidget {

  final String title;
  final VoidCallback onTap;
  const RoundButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(10)

        ),
        child: Center(child: Text(title, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),)),
      ),
    );
  }
}
