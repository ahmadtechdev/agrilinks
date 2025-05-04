import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'newsfeed_model.dart';

class NewsFeedController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final Rx<List<NewsFeedModel>> _newsFeedList = Rx<List<NewsFeedModel>>([]);
  final Rx<List<NewsFeedModel>> _myNewsFeedList = Rx<List<NewsFeedModel>>([]);
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedImagePath = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  // Change to RxList for better reactivity
  final RxList<NewsFeedModel> newsFeedList = <NewsFeedModel>[].obs;
  final RxList<NewsFeedModel> myNewsFeedList = <NewsFeedModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchAllNewsFeed();
    _fetchMyNewsFeed();
  }

  Future<void> _fetchAllNewsFeed() async {
    isLoading.value = true;
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection("newsFeed")
          .orderBy("createdAt", descending: true)
          .get();

      // Assign directly to the RxList
      newsFeedList.assignAll(
          snapshot.docs.map((doc) => NewsFeedModel.fromFirestore(doc)).toList()
      );

      debugPrint("Fetched ${newsFeedList.length} community posts");
    } catch (e) {
      errorMessage.value = 'Error fetching news feed: $e';
      debugPrint(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchMyNewsFeed() async {
    if (auth.currentUser == null) return;

    isLoading.value = true;
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection("newsFeed")
          .where("userId", isEqualTo: auth.currentUser!.uid)
          .orderBy("createdAt", descending: true)
          .get();

      // Assign directly to the RxList
      myNewsFeedList.assignAll(
          snapshot.docs.map((doc) => NewsFeedModel.fromFirestore(doc)).toList()
      );

      debugPrint("Fetched ${myNewsFeedList.length} personal posts");
    } catch (e) {
      errorMessage.value = 'Error fetching your news feed: $e';
      debugPrint(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> refreshNewsFeed() async {
    await Future.wait([
      _fetchAllNewsFeed(),
      _fetchMyNewsFeed(),
    ]);
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      errorMessage.value = 'Error picking image: $e';
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<void> removeSelectedImage() async {
    selectedImage.value = null;
    selectedImagePath.value = '';
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final Reference storageRef = _storage.ref().child('newsfeed_images/$fileName');
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      errorMessage.value = 'Error uploading image: $e';
      debugPrint(errorMessage.value);
      return null;
    }
  }

  Future<bool> createPost({
    required String title,
    required String content,
  }) async {
    if (auth.currentUser == null) {
      Get.snackbar('Error', 'You must be logged in to create a post');
      return false;
    }

    isSubmitting.value = true;
    try {
      final String userId = auth.currentUser!.uid;
      String? imageUrl;

      if (selectedImage.value != null) {
        imageUrl = await _uploadImage(selectedImage.value!);
        if (imageUrl == null) {
          Get.snackbar('Error', 'Failed to upload image');
          return false;
        }
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      await _firestore.collection("newsFeed").add({
        'userId': userId,
        'postTitle': title,
        'post': content,
        'likes': 0,
        'likedBy': [],
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
        'username': userData?['userName'] ?? 'Anonymous',
        'userPhotoUrl': userData?['photoURL'] ?? userData?['profilePic'],
      });

      await refreshNewsFeed();
      return true;
    } catch (e) {
      errorMessage.value = 'Error creating post: $e';
      debugPrint(errorMessage.value);
      Get.snackbar('Error', 'Failed to create post');
      return false;
    } finally {
      isSubmitting.value = false;
      selectedImage.value = null;
      selectedImagePath.value = '';
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      final doc = await _firestore.collection("newsFeed").doc(postId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;

      // Delete image if exists
      if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) {
        try {
          await _storage.refFromURL(data['imageUrl']).delete();
        } catch (e) {
          debugPrint('Error deleting image: $e');
        }
      }

      await _firestore.collection("newsFeed").doc(postId).delete();
      await refreshNewsFeed();
      return true;
    } catch (e) {
      errorMessage.value = 'Error deleting post: $e';
      debugPrint(errorMessage.value);
      return false;
    }
  }

  Future<void> likePost(String postId, bool isLiked) async {
    if (auth.currentUser == null) {
      Get.snackbar('Error', 'You must be logged in to like posts');
      return;
    }

    try {
      final String userId = auth.currentUser!.uid;
      final postRef = _firestore.collection("newsFeed").doc(postId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(postRef);
        if (!doc.exists) return;

        final data = doc.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(data['likedBy'] ?? []);

        if (isLiked) {
          likedBy.remove(userId);
        } else if (!likedBy.contains(userId)) {
          likedBy.add(userId);
        }

        transaction.update(postRef, {
          'likes': likedBy.length,
          'likedBy': likedBy,
        });
      });

      await refreshNewsFeed();
    } catch (e) {
      errorMessage.value = 'Error liking post: $e';
      Get.snackbar('Error', 'Failed to update like status');
    }
  }
}