import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'models/community_models.dart';

class CommunityThreadsTab extends StatelessWidget {
  final TextEditingController postController;
  final Map<String, bool> likedPosts;
  final Map<String, bool> savedPosts;
  final List<CommunityPost> posts;
  final String currentUser;
  final Set<String> bannedUsers;
  final bool isModerator;
  final Function(String) handleLike;
  final Function(String) toggleSavePost;
  final Function(CommunityPost) openPostThread;
  final Function(CommunityPost) deletePost;
  final Function(CommunityPost) deletePostAsModerator;
  final Function(String) banUser;
  final Function(String) unbanUser;
  final Function(CommunityPost) reportPost;
  final Function(String) handlePost; // Add function to handle new posts
  
  const CommunityThreadsTab({
    Key? key,
    required this.postController,
    required this.likedPosts,
    required this.savedPosts,
    required this.posts,
    required this.currentUser,
    required this.bannedUsers,
    required this.isModerator,
    required this.handleLike,
    required this.toggleSavePost,
    required this.openPostThread,
    required this.deletePost,
    required this.deletePostAsModerator,
    required this.banUser,
    required this.unbanUser,
    required this.reportPost,
    required this.handlePost, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content - Post list
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Post creation card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share with the community',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: postController,
                      decoration: InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Use the handlePost callback instead of modifying posts directly
                          if (postController.text.isNotEmpty) {
                            handlePost(postController.text); // Call the parent's handlePost function
                            // Note: clearing should now be handled by the parent
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Post'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Community posts
            ...posts.map((post) => _buildPostCard(post, context)),
            
            // Bottom padding
            const SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildPostCard(CommunityPost post, BuildContext context) {
    final bool isLiked = likedPosts[post.id] ?? false;
    final bool isSaved = savedPosts[post.id] ?? false;
    final bool isOwnPost = post.username == currentUser;
    final bool isUserBanned = bannedUsers.contains(post.username);
    
    return GestureDetector(
      onTap: () => openPostThread(post),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 1,
        color: isUserBanned ? AppColors.cardBackground : AppColors.white,
        child: Stack(
          children: [
            // Banned overlay if user is banned
            if (isUserBanned && isModerator)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Text(
                        'USER BANNED',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post header with three-dots menu
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Text(
                          post.username.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUserBanned ? "${post.username} (banned)" : post.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isUserBanned ? AppColors.textSecondary : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              post.timeAgo,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Three-dot menu for post actions
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                        onSelected: (value) {
                          if (value == 'report') {
                            reportPost(post);
                          } else if (value == 'delete') {
                            deletePost(post);
                          } else if (value == 'mod_delete') {
                            deletePostAsModerator(post);
                          } else if (value == 'ban_user') {
                            banUser(post.username);
                          } else if (value == 'unban_user') {
                            unbanUser(post.username);
                          }
                        },
                        itemBuilder: (context) {
                          List<PopupMenuItem<String>> items = [];
                          
                          // Delete option for own posts
                          if (isOwnPost) {
                            items.add(
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                    const SizedBox(width: 8),
                                    const Text('Delete my post'),
                                  ],
                                ),
                              ),
                            );
                          } 
                          
                          // Additional moderator actions
                          if (isModerator) {
                            // Only add mod delete if it's not the user's own post
                            if (!isOwnPost) {
                              items.add(
                                PopupMenuItem<String>(
                                  value: 'mod_delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.no_accounts, color: AppColors.warning, size: 20),
                                      const SizedBox(width: 8),
                                      const Text('Delete as moderator'),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            // Ban/Unban user option
                            if (!isOwnPost) {
                              if (isUserBanned) {
                                items.add(
                                  PopupMenuItem<String>(
                                    value: 'unban_user',
                                    child: Row(
                                      children: [
                                        Icon(Icons.person_add, color: AppColors.success, size: 20),
                                        const SizedBox(width: 8),
                                        const Text('Unban user'),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                items.add(
                                  PopupMenuItem<String>(
                                    value: 'ban_user',
                                    child: Row(
                                      children: [
                                        Icon(Icons.block, color: AppColors.error, size: 20),
                                        const SizedBox(width: 8),
                                        const Text('Ban user'),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                          
                          // Report option (for posts that aren't yours)
                          if (!isOwnPost) {
                            items.add(
                              const PopupMenuItem<String>(
                                value: 'report',
                                child: Row(
                                  children: [
                                    Icon(Icons.flag_outlined, color: Colors.orange, size: 20),
                                    SizedBox(width: 8),
                                    Text('Report post'),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          return items;
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Post content
                  Text(
                    isUserBanned ? "[Content removed]" : post.content,
                    style: TextStyle(
                      color: isUserBanned ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  
                  // Post image (if available)
                  if (post.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          post.imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  
                  // Post actions with hearts and save
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Heart/Like button
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => handleLike(post.id),
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : AppColors.textSecondary,
                            ),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                          ),
                          const SizedBox(width: 4),
                          Text('${post.likesCount}'),
                        ],
                      ),
                      
                      // Comments
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => openPostThread(post),
                            icon: Icon(
                              Icons.comment_outlined,
                              color: AppColors.info,
                            ),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                          ),
                          const SizedBox(width: 4),
                          Text('${post.commentsCount}'),
                        ],
                      ),
                      
                      // Share
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.share_outlined,
                          color: AppColors.textSecondary,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                      ),
                      
                      // Save post
                      IconButton(
                        onPressed: () => toggleSavePost(post.id),
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? AppColors.primary : AppColors.textSecondary,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(String reason, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // Close dialog
        
        // Show confirmation
        Get.snackbar(
          'Report submitted',
          'Thank you for helping keep our community safe. We\'ll review this post.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.info.withOpacity(0.1),
          colorText: AppColors.info,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.radio_button_unchecked, size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(reason),
          ],
        ),
      ),
    );
  }
}
