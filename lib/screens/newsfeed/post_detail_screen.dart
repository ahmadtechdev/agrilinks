import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../utils/colors.dart';
import 'newsfeed_controller.dart';
import 'newsfeed_model.dart';


class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> with SingleTickerProviderStateMixin {
  final NewsFeedController _controller = Get.find<NewsFeedController>();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('newsFeed')
            .doc(widget.postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              color: AppColors.primary,
            ));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Post not found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This post may have been deleted',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Go Back"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            );
          }

          final post = NewsFeedModel.fromFirestore(snapshot.data!);
          final isLiked = post.likedBy.contains(_currentUser?.uid);
          final isOwner = post.userId == _currentUser?.uid;

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: post.imageUrl != null ? 300 : 60,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    post.postTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                      fontSize: 16,
                    ),
                  ),
                  background: post.imageUrl != null
                      ? Hero(
                    tag: 'post_image_${post.id}',
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.background,
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: AppColors.textSecondary,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  )
                      : Container(
                    color: AppColors.primary,
                  ),
                ),
                actions: [
                  if (isOwner)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.textLight),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmation(context, post.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete post'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.accent,
                              backgroundImage: post.userPhotoUrl != null && post.userPhotoUrl!.isNotEmpty
                                  ? NetworkImage(post.userPhotoUrl!)
                                  : null,
                              child: post.userPhotoUrl == null || post.userPhotoUrl!.isEmpty
                                  ? Text(
                                post.username != null && post.username!.isNotEmpty
                                    ? post.username![0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.username ?? 'Anonymous',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    timeago.format(post.createdAt),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Like button
                            LikeButton(
                              isLiked: isLiked,
                              likesCount: post.likes,
                              onPressed: () => _controller.likePost(post.id, isLiked),
                            ),
                          ],
                        ),

                        const Divider(height: 32),

                        // Post content
                        if (post.post.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.post,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Post stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              icon: Icons.favorite,
                              count: post.likes,
                              label: 'Likes',
                              color: isLiked ? Colors.red : AppColors.textSecondary,
                            ),
                            // Add more stats here if needed, such as comments or shares
                          ],
                        ),

                        const SizedBox(height: 100), // Extra space at bottom
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String postId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Delete Post",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this post? This action cannot be undone.",
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColors.textLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _controller.deletePost(postId).then((success) {
                  if (success) {
                    Get.back(); // Return to previous screen
                    Get.snackbar(
                      'Success',
                      'Post deleted successfully',
                      backgroundColor: Colors.green.withOpacity(0.7),
                      colorText: AppColors.textLight,
                      margin: const EdgeInsets.all(10),
                      borderRadius: 10,
                      duration: const Duration(seconds: 2),
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      'Failed to delete post',
                      backgroundColor: Colors.red.withOpacity(0.7),
                      colorText: AppColors.textLight,
                      margin: const EdgeInsets.all(10),
                      borderRadius: 10,
                      duration: const Duration(seconds: 2),
                    );
                  }
                });
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final int likesCount;
  final VoidCallback onPressed;

  const LikeButton({
    Key? key,
    required this.isLiked,
    required this.likesCount,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        splashColor: Colors.red.withOpacity(0.3),
        highlightColor: Colors.red.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: isLiked ? 0.5 : 1.0,
                  end: isLiked ? 1.0 : 0.5,
                ),
                curve: Curves.elasticOut,
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : AppColors.textSecondary,
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              Text(
                likesCount.toString(),
                style: TextStyle(
                  color: isLiked ? Colors.red : AppColors.textSecondary,
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