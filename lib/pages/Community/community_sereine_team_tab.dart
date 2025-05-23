import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'sa_chat_page.dart';
import 'models/community_models.dart';

class CommunitySeireineTeamTab extends StatelessWidget {
  final List<SATeamMember> saTeamMembers;
  
  const CommunitySeireineTeamTab({
    Key? key,
    required this.saTeamMembers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Enhanced header section with modern design
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.15),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Icon with circular background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Title with enhanced typography
              Text(
                'The Human Library',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Description with improved styling
              Text(
                'A conversation can change everything.\nConnect with the SA team and have confidential conversations\nReal people. Real stories. Real support.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 14),
              
              // Instruction with subtle accent
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap a book to connect',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bookshelf with background and columns
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Container(
              decoration: BoxDecoration(
                // Bookshelf background
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: const AssetImage('assets/images/wood_texture.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.brown.shade700.withOpacity(0.8), 
                    BlendMode.multiply
                  ),
                ),
                // Add a rounded roof to the bookshelf
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.shade900.withOpacity(0.6),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Bookshelf roof
                  Container(
                    height: 20,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade900,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  
                  // Row 1 of bookshelf
                  _buildBookshelfRow(
                    [saTeamMembers[0], saTeamMembers[1], saTeamMembers[2]],
                    Colors.brown.shade800,
                  ),
                  
                  // Row 2 of bookshelf
                  _buildBookshelfRow(
                    [saTeamMembers[3], saTeamMembers[4], saTeamMembers[5]],
                    Colors.brown.shade700,
                  ),
                  
                  // Row 3 of bookshelf
                  _buildBookshelfRow(
                    [saTeamMembers[6], saTeamMembers[7], saTeamMembers[8]],
                    Colors.brown.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Helper method to build a row of the bookshelf
  Widget _buildBookshelfRow(List<SATeamMember> rowMembers, Color shelfColor) {
    return Expanded(
      child: Column(
        children: [
          // Books container
          Expanded(
            flex: 5,
            child: Row(
              children: [
                // Left decorative column - narrower
                _buildBookshelfColumn(15),
                
                // Books section with proper spacing
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: rowMembers.map((member) => _buildBook(member)).toList(),
                    ),
                  ),
                ),
                
                // Right decorative column - narrower
                _buildBookshelfColumn(15),
              ],
            ),
          ),
          
          // Shelf
          Container(
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: shelfColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          
          // Space below shelf
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  // Helper method to build decorative column with customizable width
  Widget _buildBookshelfColumn(double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.brown.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build an individual book with horizontal text
  Widget _buildBook(SATeamMember member) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: GestureDetector(
        onTap: () {
          // Navigate to chat with this team member
          Get.to(() => SAChatPage(teamMember: member));
        },
        child: Container(
          width: 68, // Slightly increased from 65 for better proportions
          height: double.infinity, // Use maximum available height
          decoration: BoxDecoration(
            color: member.bookColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(6),
              bottomLeft: Radius.circular(2),
              bottomRight: Radius.circular(2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(2, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Book spine decoration (horizontal lines)
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Positioned(
                bottom: 45,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              
              // Book title - positioned at bottom with better styling
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  color: Colors.black45,
                  child: Text(
                    member.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
