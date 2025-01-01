
import 'package:flutter/material.dart';

import '../colors.dart';

class RoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon;
  const RoundedButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Container(
          height: 50,
          width: 200,
          decoration: BoxDecoration(
            color: pColor, // Example color, you can customize
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: wColor, // Example color, you can customize
              ),
              SizedBox(width: 8), // Adjust the spacing between icon and text
              Text(
                title,
                style: TextStyle(
                  color: wColor, // Example color, you can customize
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
