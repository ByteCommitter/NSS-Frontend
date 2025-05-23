// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:get/get.dart';

// class DebugService {
//   // Singleton pattern
//   static final DebugService _instance = DebugService._internal();
//   factory DebugService() => _instance;
//   DebugService._internal();
  
//   // Check Firebase connection
//   Future<void> checkFirebaseConnection() async {
//     try {
//       print('Checking Firebase connection...');
//       final apps = Firebase.apps;
//       print('Firebase apps initialized: ${apps.length}');
      
//       if (apps.isEmpty) {
//         print('No Firebase apps initialized!');
//       } else {
//         for (var app in apps) {
//           print('App name: ${app.name}, options: ${app.options.projectId}');
//         }
//       }
      
//       // Check auth
//       try {
//         final auth = FirebaseAuth.instance;
//         print('Auth instance created successfully.');
//         print('Current user: ${auth.currentUser?.uid ?? "No user signed in"}');
//       } catch (authError) {
//         print('Error accessing FirebaseAuth: $authError');
//       }
      
//       print('Firebase connection check complete.');
//     } catch (e) {
//       print('Error checking Firebase connection: $e');
//     }
//   }
  
//   // Force navigation to onboarding for testing
//   void forceNavigateToOnboarding() {
//     print('DEBUG: Forcing navigation to onboarding screen');
//     Get.offAllNamed('/onboarding');
//   }
// }
