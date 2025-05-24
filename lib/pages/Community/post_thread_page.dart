import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'models/community_models.dart'; // Replace import of community_page.dart with models

class PostThreadPage extends StatefulWidget {
  final CommunityPost post;
  
  const PostThreadPage({super.key, required this.post});

  @override
  State<PostThreadPage> createState() => _PostThreadPageState();
}

class _PostThreadPageState extends State<PostThreadPage> {
  final TextEditingController _commentController = TextEditingController();
  late CommunityPost _post;
  bool _isLiked = false;
  bool _isSaved = false;
  
  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  void _handleLike() {
    setState(() {
      if (_isLiked) {
        _post = _post.copyWith(likesCount: _post.likesCount - 1);
      } else {
        _post = _post.copyWith(likesCount: _post.likesCount + 1);
      }
      _isLiked = !_isLiked;
    });
  }
  
  void _toggleSavePost() {
    setState(() {
      _isSaved = !_isSaved;
    });
    
    Get.snackbar(
      _isSaved ? 'Post Saved' : 'Post Unsaved',
      _isSaved 
        ? 'You can find this post in your saved collection.'
        : 'This post has been removed from your saved collection.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _isSaved ? AppColors.info.withOpacity(0.1) : Colors.grey[200], // Use theme color
      colorText: _isSaved ? AppColors.info : Colors.grey[800], // Use theme color
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }
  
  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        final newComments = [
          ..._post.comments,
          Comment(
            username: 'You',
            content: _commentController.text,
            timeAgo: 'Just now',
          ),
        ];
        
        _post = _post.copyWith(
          commentsCount: _post.commentsCount + 1,
          comments: newComments,
        );
        
        _commentController.clear();
      });
      
      // Hide keyboard
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Thread'),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? AppColors.primary : null, // Use theme color
            ),
            onPressed: _toggleSavePost,
          ),
        ],
      ),
      body: Column(
        children: [
          // Original post
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Original post
                  _buildOriginalPost(),
                  
                  // Divider
                  const Divider(height: 1),
                  
                  // Comments section header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${_post.commentsCount})',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Comments list
                  ..._post.comments.map((comment) => _buildCommentItem(comment)),
                  
                  // Bottom padding
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }
  
  Widget _buildOriginalPost() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepPurple.withOpacity(0.2),
                child: Text(
                  _post.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.deepPurple,
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
                      _post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _post.timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Post content
          Text(
            _post.content,
            style: const TextStyle(fontSize: 16),
          ),
          
          // Post image (if available)
          if (_post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  _post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Post stats
          Row(
            children: [
              // Likes
              Row(
                children: [
                  IconButton(
                    onPressed: _handleLike,
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : null,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                  ),
                  const SizedBox(width: 4),
                  Text('${_post.likesCount}'),
                ],
              ),
              const SizedBox(width: 16),
              
              // Comments
              Row(
                children: [
                  const Icon(Icons.comment_outlined, size: 20, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('${_post.commentsCount}'),
                ],
              ),
              const SizedBox(width: 16),
              
              // Share
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.share_outlined, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.deepPurple.withOpacity(0.1),
            child: Text(
              comment.username.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                
                // Comment actions
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Like',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white, // Use theme color
        boxShadow: [
          BoxShadow(
            color: Colors.white, // Use theme color
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, 
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _addComment,
            icon: const Icon(Icons.send),
            color: AppColors.primary, // Use theme color
          ),
        ],
      ),
    );
  }
}
