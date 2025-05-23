// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mentalsustainability/theme/app_colors.dart'; // Add theme import
// import 'sa_chat_page.dart';
// import 'community_page.dart'; 

// class SALibraryPage extends StatelessWidget {
//   const SALibraryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Students Anonymous Library'),
//         backgroundColor: AppColors.primary, // Use theme color
//         foregroundColor: AppColors.white, // Use theme color
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Header section
//           const SizedBox(height:15),
//           Container(
//             padding: const EdgeInsets.all(20),
//             color: AppColors.primary.withOpacity(0.1), // Use theme color with opacity
//             //add a padding to the above of this container

//             child: Column(
//               children: [
//                 Text(
//                   'The Human Library',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primary, // Use theme color
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Our peers act as a human library, helping with mental health by listening and providing support to everyone on campus.',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: AppColors.textPrimary, // Use theme color
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Click on a book to connect with a peer supporter',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontStyle: FontStyle.italic,
//                     color: AppColors.textSecondary, // Use theme color
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
          
//           // Enhanced Bookshelf with better roof and connected columns/rows
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
//               decoration: BoxDecoration(
//                 color: Colors.brown.shade100.withOpacity(0.3),
//                 image: DecorationImage(
//                   image: const AssetImage('assets/images/wood_texture.png'),
//                   fit: BoxFit.cover,
//                   opacity: 0.1,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // Prominent 3D Roof with peak
//                   Stack(
//                     clipBehavior: Clip.none, // Allow elements to extend outside stack
//                     alignment: Alignment.center,
//                     children: [
//                       // Main triangular roof
//                       Container(
//                         height: 70,
//                         margin: const EdgeInsets.only(bottom: 0),
//                         child: CustomPaint(
//                           size: Size(MediaQuery.of(context).size.width, 70),
//                           painter: TriangularRoofPainter(),
//                         ),
//                       ),
                      
//                       // Bottom border of roof that connects with bookshelf
//                       Positioned(
//                         bottom: 0,
//                         left: 0,
//                         right: 0,
//                         child: Container(
//                           height: 15,
//                           color: Colors.brown.shade900,
//                         ),
//                       ),
                      
//                       // Library sign in the center of roof
//                       Positioned(
//                         bottom: 20,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: Colors.brown.shade700,
//                             borderRadius: BorderRadius.circular(6),
//                             border: Border.all(color: Colors.brown.shade900, width: 2),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.4),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: const Text(
//                             'HUMAN LIBRARY',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               letterSpacing: 2,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
                  
//                   // Bookshelf structure with connected borders
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.brown.shade300,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           // Top border connecting with roof
//                           Container(
//                             height: 8,
//                             color: Colors.brown.shade900,
//                           ),
                          
//                           // First row with books
//                           _buildShelfRow(_saTeamMembers.sublist(0, 3)),
                          
//                           // Shelf divider (connecting with vertical columns)
//                           _buildShelfDivider(isConnected: true),
                          
//                           // Second row with books
//                           _buildShelfRow(_saTeamMembers.sublist(3, 6)),
                          
//                           // Shelf divider (connecting with vertical columns)
//                           _buildShelfDivider(isConnected: true),
                          
//                           // Third row with books
//                           _buildShelfRow(_saTeamMembers.sublist(6, 9)),
                          
//                           // Bottom border
//                           Container(
//                             height: 8,
//                             color: Colors.brown.shade900,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Build a row of books on the shelf with connected columns
//   Widget _buildShelfRow(List<SATeamMember> rowMembers) {
//     return Expanded(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Left vertical column (no margin to allow connection)
//           Container(
//             width: 12,
//             color: Colors.brown.shade900,
//           ),
          
//           // Books
//           Expanded(
//             child: Container(
//               color: Colors.brown.shade200,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: rowMembers.map((member) => _buildBookItem(Get.context!, member)).toList(),
//               ),
//             ),
//           ),
          
//           // Right vertical column (no margin to allow connection)
//           Container(
//             width: 12,
//             color: Colors.brown.shade900,
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build horizontal shelf divider that connects with columns
//   Widget _buildShelfDivider({required bool isConnected}) {
//     return Row(
//       children: [
//         // Left connection point (matches column width)
//         Container(
//           width: 12,
//           height: 15,
//           color: Colors.brown.shade900,
//         ),
        
//         // Middle shelf part
//         Expanded(
//           child: Container(
//             height: 15,
//             color: Colors.brown.shade900,
//             child: Center(
//               child: Container(
//                 height: 3,
//                 margin: const EdgeInsets.symmetric(horizontal: 20),
//                 decoration: BoxDecoration(
//                   color: Colors.brown.shade600,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 2,
//                       offset: const Offset(0, 1),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
        
//         // Right connection point (matches column width)
//         Container(
//           width: 12,
//           height: 15,
//           color: Colors.brown.shade900,
//         ),
//       ],
//     );
//   }

//   // Enhanced book items
//   Widget _buildBookItem(BuildContext context, SATeamMember member) {
//     return GestureDetector(
//       onTap: () {
//         // Navigate to chat with this team member
//         Get.to(() => SAChatPage(teamMember: member));
//       },
//       child: Container(
//         // Using a fixed positive width to prevent negative constraint calculations
//         width: 70, 
//         // Don't set constraints that might become negative during layout
//         // height: double.infinity, // This could be causing issues
//         constraints: const BoxConstraints(minWidth: 60, maxWidth: 80),
//         margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//         decoration: BoxDecoration(
//           color: member.bookColor,
//           borderRadius: BorderRadius.circular(3),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 3,
//               offset: const Offset(2, 2),
//             ),
//           ],
//           border: Border.all(
//             color: Colors.black.withOpacity(0.4),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Book spine decoration
//             Container(
//               height: 5,
//               margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
            
//             // Book title
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
//               color: Colors.black38,
//               width: double.infinity,
//               child: Text(
//                 member.name,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
            
//             // Book spine decoration
//             Container(
//               height: 5,
//               margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Custom triangular roof painter for more prominent roof
// class TriangularRoofPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.brown.shade800
//       ..style = PaintingStyle.fill;

//     final path = Path();
//     // Start from left bottom corner
//     path.moveTo(0, size.height);
//     // Draw line to the top center point (roof peak)
//     path.lineTo(size.width / 2, 0);
//     // Draw line to the right bottom corner
//     path.lineTo(size.width, size.height);
//     // Close the path (connects back to start)
//     path.close();
    
//     // Fill the path
//     canvas.drawPath(path, paint);
    
//     // Draw roof texture
//     final texturePaint = Paint()
//       ..color = Colors.brown.shade900
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;
    
//     // Horizontal roof boards
//     for (double y = size.height * 0.2; y < size.height; y += size.height * 0.2) {
//       // Calculate x position at this y level based on triangular shape
//       final ratio = y / size.height;
//       final startX = size.width * ratio / 2;
//       final endX = size.width - startX;
      
//       canvas.drawLine(
//         Offset(startX, y),
//         Offset(endX, y),
//         texturePaint,
//       );
//     }
    
//     // Draw border outline to make the roof more defined
//     final borderPaint = Paint()
//       ..color = Colors.brown.shade900
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3;
    
//     canvas.drawPath(path, borderPaint);
//   }

//   @override
//   bool shouldRepaint(TriangularRoofPainter oldDelegate) => false;
// }

// // Use the team members from community_page.dart
// final List<SATeamMember> _saTeamMembers = [
//   // Same definitions as in community_page.dart
//   SATeamMember(
//     id: 'sa1',
//     name: 'Alisa',
//     specialty: 'Anxiety & Stress',
//     bio: 'Peer supporter with experience helping fellow students manage anxiety and stress.',
//     bookColor: AppColors.primary, // Use theme color
//     presetMessages: [
//       "Hi there! I'm Alisa. How can I support you today?",
//       "Remember that feeling anxious is a normal response to stress. Let's talk about it.",
//       "Would you like to learn some breathing techniques that can help in moments of stress?",
//     ],
//   ),
//   SATeamMember(
//     id: 'sa2',
//     name: 'Rohan',
//     specialty: 'Peer Support',
//     bio: 'Student who has personal experience with overcoming depression and wants to help others.',
//     bookColor: AppColors.success, // Use theme color instead of Colors.teal
//     presetMessages: [
//       "Hey! I'm Rohan. I'm here to listen without judgment.",
//       "As someone who's been through similar struggles, I understand how overwhelming things can get.",
//       "Would you like to share what's been on your mind lately?",
//     ],
//   ),
//   const SATeamMember(
//     id: 'sa3',
//     name: 'Misha',
//     specialty: 'Academic Pressure',
//     bio: 'Student mentor specializing in helping peers navigate academic stress and expectations.',
//     bookColor: Colors.indigo,
//     presetMessages: [
//       "Hi, I'm Misha. Feeling overwhelmed with coursework?",
//       "Let's discuss some strategies to balance your academic responsibilities.",
//       "Remember that your worth isn't determined by your grades or achievements.",
//     ],
//   ),
//   SATeamMember(
//     id: 'sa4',
//     name: 'Jorge',
//     specialty: 'Grief & Loss',
//     bio: 'Peer supporter trained to help individuals process grief and navigate significant life changes.',
//     bookColor: Colors.amber.shade800,
//     presetMessages: [
//       "Hello, I'm Jorge. I create a safe space for discussing difficult emotions.",
//       "Grief can come in many forms. How has your experience been?",
//       "It's okay to not be okay. I'm here to support you through this process.",
//     ],
//   ),
//   SATeamMember(
//     id: 'sa5',
//     name: 'Neela',
//     specialty: 'Cultural Adaptation',
//     bio: 'International student who helps peers navigate cultural transitions and identity challenges.',
//     bookColor: Colors.pink.shade700,
//     presetMessages: [
//       "Hi, I'm Neela. Adjusting to a new environment can be challenging.",
//       "I'd love to hear about your experiences and how you've been coping.",
//       "What aspects of the transition have been most difficult for you?",
//     ],
//   ),
//   SATeamMember(
//     id: 'sa6',
//     name: 'Danny',
//     specialty: 'LGBTQ+ Support',
//     bio: 'Student advocate for LGBTQ+ peers, focusing on identity, acceptance, and community building.',
//     bookColor: Colors.blue.shade800,
//     presetMessages: [
//       "Hello! I'm Danny. This is a judgment-free zone where you can be yourself.",
//       "How have you been feeling about your identity and place in the community?",
//       "Would you like to discuss resources or support groups available on campus?",
//     ],
//   ),
//   SATeamMember(
//     id: 'sa7',
//     name: 'Layla',
//     specialty: 'Relationship Issues',
//     bio: 'Peer supporter trained in interpersonal relationships, communication skills, and boundary setting.',
//     bookColor: Colors.red.shade700,
//     presetMessages: [
//       "Hi, I'm Layla. Navigating relationships can be complex.",
//       "How have your connections with others been affecting your well-being?",
//       "Let's talk about healthy boundaries and communication strategies.",
//     ],
//   ),
//   SATeamMember(
//     id: 'sa8',
//     name: 'Kevin',
//     specialty: 'Substance Use',
//     bio: 'Student who provides non-judgmental support for peers dealing with substance use concerns.',
//     bookColor: Colors.green.shade800,
//     presetMessages: [
//       "Hey there, I'm Kevin. I'm here to listen and support, not to judge.",
//       "Would you like to talk about how substance use has been impacting your life?",
//       "There are many paths to wellness. Let's explore what might work for you.",
//     ],
//   ),
//   SATeamMember(
//     id: 'sa9',
//     name: 'Sonia',
//     specialty: 'Self-Esteem',
//     bio: 'Peer mentor focused on building self-worth, resilience, and personal strengths.',
//     bookColor: Colors.purple.shade800,
//     presetMessages: [
//       "Hello! I'm Sonia. I believe in your inherent worth and potential.",
//       "How has your relationship with yourself been lately?",
//       "Let's explore the unique strengths you possess that you might not fully recognize yet.",
//     ],
//   ),
// ];
