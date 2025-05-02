// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../utils/colors.dart';
import 'signin_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo1.png',
              scale: 1,
            ),
            SizedBox(height: 60),
            GestureDetector(
              onTap: () {
                Get.to(() => SignInScreen());
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    )),
                child: Text(
                  "LET'S GO",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
