import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupNameController = TextEditingController();

  // Observable user state
  Rx<User?> user = Rx<User?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      this.user.value = user;
    });
  }

  // @override
  // void onClose() {
  //   loginEmailController.dispose();
  //   loginPasswordController.dispose();
  //   signupEmailController.dispose();
  //   signupPasswordController.dispose();
  //   signupNameController.dispose();
  //   super.onClose();
  // }

  // Sign in with email and password
  Future<User?> signIn() async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getAuthErrorMessage(e.code),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign up with email and password
  Future<User?> signUp({required String phoneNumber}) async {
    try {
      isLoading.value = true;

      // Create the user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: signupEmailController.text.trim(),
        password: signupPasswordController.text.trim(),
      );

      // Update display name
      await userCredential.user?.updateDisplayName(signupNameController.text.trim());

      // Store additional user data in Firestore
      if (userCredential.user != null) {
        await _firestore.collection("users").doc(userCredential.user!.uid).set({
          'userName': signupNameController.text.trim(),
          'userPhone': phoneNumber,
          'userEmail': signupEmailController.text.trim(),
          'createdAt': DateTime.now(),
          'userId': userCredential.user!.uid,
        });
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      throw Exception("An unexpected error occurred. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _auth.signOut();
      loginEmailController.clear();
      loginPasswordController.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getAuthErrorMessage(e.code),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (_auth.currentUser != null) {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();

        if (docSnapshot.exists) {
          return docSnapshot.data();
        }
      }
      return null;
    } catch (e) {
      throw Exception("Failed to get user profile: $e");
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      if (_auth.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update(data);

        // Update display name if included
        if (data.containsKey('userName')) {
          await _auth.currentUser!.updateDisplayName(data['userName']);
        }

        // Update email if included
        if (data.containsKey('userEmail')) {
          await _auth.currentUser!.updateEmail(data['userEmail']);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'The email address is already in use';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'invalid-credential':
        return 'The credentials provided are invalid';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address';
      case 'requires-recent-login':
        return 'Please sign in again to complete this operation';
      default:
        return 'An error occurred. Please try again';
    }
  }
}