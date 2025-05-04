import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/colors.dart';
import '../authentication/signin_screen.dart';
import 'auth_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  // Using AuthController for better state management
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  // Additional controllers for signup fields
  final TextEditingController _phoneController = TextEditingController();

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Show error snackbar
  void _showSnackbar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.redColor : AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Handle sign up
  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _authController.signupEmailController.text.trim(),
          password: _authController.signupPasswordController.text.trim(),
        );

        if (userCredential.user != null) {
          // Store additional user info in Firestore
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userCredential.user!.uid)
              .set({
            'userName': _authController.signupNameController.text.trim(),
            'userPhone': _phoneController.text.trim(),
            'userEmail': _authController.signupEmailController.text.trim(),
            'createdAt': DateTime.now(),
            'userId': userCredential.user!.uid,
          });

          // Sign out and navigate to sign in screen
          await FirebaseAuth.instance.signOut();
          _showSnackbar("Account created successfully! Please sign in.", false);

          // Navigate with animation to sign in
          Get.offAll(
                () => const SignInScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Failed to create account";

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = "This email is already in use";
            break;
          case 'weak-password':
            errorMessage = "The password is too weak";
            break;
          case 'invalid-email':
            errorMessage = "The email address is invalid";
            break;
          default:
            errorMessage = e.message ?? "An error occurred during sign up";
        }

        _showSnackbar(errorMessage, true);
      } catch (e) {
        _showSnackbar("An error occurred. Please try again.", true);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.primaryGradient,
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.p1Color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: AppColors.whiteColor,
                            ),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Logo section with animation
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.p1Color,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowColorDark,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset(
                              'assets/logo1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Create account text
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Sign up to get started",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.whiteColor.withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Signup form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Name field
                            TextFormField(
                              controller: _authController.signupNameController,
                              style: TextStyle(color: AppColors.whiteColor),
                              cursorColor: AppColors.secondary,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                fillColor: AppColors.p1Color,
                                filled: true,
                                hintText: 'Full Name',
                                hintStyle: TextStyle(color: AppColors.whiteColor.withOpacity(0.5)),
                                prefixIcon: Icon(Icons.person_outline, color: AppColors.secondary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.p1Color),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.secondary, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.redColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Name is required";
                                } else if (value.length < 3) {
                                  return "Name must be at least 3 characters";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Phone field
                            TextFormField(
                              controller: _phoneController,
                              style: TextStyle(color: AppColors.whiteColor),
                              keyboardType: TextInputType.phone,
                              cursorColor: AppColors.secondary,
                              decoration: InputDecoration(
                                fillColor: AppColors.p1Color,
                                filled: true,
                                hintText: 'Phone Number',
                                hintStyle: TextStyle(color: AppColors.whiteColor.withOpacity(0.5)),
                                prefixIcon: Icon(Icons.phone_outlined, color: AppColors.secondary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.p1Color),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.secondary, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.redColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Phone number is required";
                                }

                                String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                                RegExp regExp = RegExp(pattern);

                                if (value.length < 10) {
                                  return 'Phone number must be at least 10 digits';
                                } else if (!regExp.hasMatch(value)) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Email field
                            TextFormField(
                              controller: _authController.signupEmailController,
                              style: TextStyle(color: AppColors.whiteColor),
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: AppColors.secondary,
                              decoration: InputDecoration(
                                fillColor: AppColors.p1Color,
                                filled: true,
                                hintText: 'Email Address',
                                hintStyle: TextStyle(color: AppColors.whiteColor.withOpacity(0.5)),
                                prefixIcon: Icon(Icons.email_outlined, color: AppColors.secondary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.p1Color),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.secondary, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.redColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email is required";
                                } else if (!GetUtils.isEmail(value)) {
                                  return "Please enter a valid email";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Password field
                            TextFormField(
                              controller: _authController.signupPasswordController,
                              obscureText: !_isPasswordVisible,
                              style: TextStyle(color: AppColors.whiteColor),
                              cursorColor: AppColors.secondary,
                              decoration: InputDecoration(
                                fillColor: AppColors.p1Color,
                                filled: true,
                                hintText: 'Password',
                                hintStyle: TextStyle(color: AppColors.whiteColor.withOpacity(0.5)),
                                prefixIcon: Icon(Icons.lock_outline, color: AppColors.secondary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: AppColors.secondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.p1Color),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.secondary, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: AppColors.redColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password is required";
                                } else if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Terms and conditions text
                      Text(
                        "By signing up, you agree to our Terms of Service and Privacy Policy",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.whiteColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Sign up button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            colors: AppColors.buttonGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: _isLoading ? null : _handleSignUp,
                            splashColor: AppColors.whiteColor.withOpacity(0.1),
                            child: Center(
                              child: _isLoading
                                  ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.whiteColor,
                                  strokeWidth: 3,
                                ),
                              )
                                  : Text(
                                "CREATE ACCOUNT",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sign in section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: AppColors.whiteColor.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.offAll(
                                    () => const SignInScreen(),
                                transition: Transition.leftToRight,
                                duration: const Duration(milliseconds: 400),
                              );
                            },
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}