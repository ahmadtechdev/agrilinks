import 'package:agrlinks_app/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../utils/colors.dart';
import '../inventory/inventory_screen/inventory_screen.dart';
import '../market/market_screen.dart';
import 'add_newsfeed.dart';
import 'newsfeed_controller.dart';
import 'newsfeed_model.dart';
import 'newsfeed_widget.dart';
import 'post_detail_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NewsFeedController _controller = Get.put(NewsFeedController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // rebuild to reflect FAB changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToAddPost() {
    Get.to(
          () => AddNewsFeedScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _navigateToPostDetail(NewsFeedModel post) {
    Get.to(
          () => PostDetailScreen(postId: post.id),
      transition: Transition.cupertino,
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              centerTitle: true,
              backgroundColor: AppColors.primary,
              title: const Text(
                "Community Feed",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              foregroundColor: AppColors.textLight,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              floating: true,
              pinned: true,
              snap: true,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accent,
                indicatorWeight: 3,
                labelColor: AppColors.textLight,
                unselectedLabelColor: AppColors.textLight.withOpacity(0.7),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "Community"),
                  Tab(text: "My Posts"),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(_controller.newsFeedList, showCreateButton: false),
            _buildPostsTab(_controller.myNewsFeedList, showCreateButton: true),
          ],
        ),
      ),

      // ✅ Conditionally show the FAB
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 4,
        onPressed: _navigateToAddPost,
        icon: const Icon(Icons.add),
        label: const Text("New Post"),
      )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 2),
    );
  }

  Widget _buildPostsTab(RxList<NewsFeedModel> postsList, {bool showCreateButton = false}) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _controller.refreshNewsFeed,
      child: Obx(() {
        // Access the actual list value with postsList.value
        final currentPosts = postsList.value;

        if (_controller.isLoading.value && currentPosts.isEmpty) {
          return const NewsFeedShimmer();
        }

        if (currentPosts.isEmpty) {
          return _buildEmptyState(
            icon: showCreateButton ? Icons.person_outline : Icons.newspaper,
            title: showCreateButton
                ? "You haven't posted anything yet"
                : "No posts yet",
            subtitle: showCreateButton
                ? "Share your first post with the community!"
                : "Be the first to share something!",
            showActionButton: showCreateButton,
          );
        }

        return AnimationLimiter(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: currentPosts.length,
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemBuilder: (context, index) {
              final post = currentPosts[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: GestureDetector(
                      onTap: () => _navigateToPostDetail(post),
                      child: NewsFeedCard(
                        post: post,
                        isLiked: post.likedBy.contains(_controller.auth.currentUser?.uid),
                        onLike: _controller.likePost,
                        showDeleteOption: post.userId == _controller.auth.currentUser?.uid,
                        onDelete: _showDeleteConfirmation,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showActionButton = false,
  }) {
    return Center(
      child: AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 500),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 80,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (showActionButton) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Create Post"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _navigateToAddPost,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _showDeleteConfirmation(String postId) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
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
            onPressed: () => Get.back(result: false),
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
            onPressed: () => Get.back(result: true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _controller.deletePost(postId);
      if (success) {
        Get.snackbar(
          'Success',
          'Post deleted successfully',
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: AppColors.textLight,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }
}