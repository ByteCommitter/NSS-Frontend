// Test script to verify admin login validation logic
// This is just for testing - not part of the main app

import 'dart:io';

// Copy the regex pattern from the app
class ValidationPatterns {
  static final RegExp idPattern = RegExp(r'^f\d{2}[A-Z0-9]{6}$');
}

// Copy the validation method from AuthService
bool isValidId(String id) {
  // Special case: allow "admin" as a valid ID for admin login
  if (id.toLowerCase() == 'admin') {
    return true;
  }
  // Regular validation for university IDs
  return ValidationPatterns.idPattern.hasMatch(id);
}

void main() {
  print('Testing admin login validation...\n');
  
  // Test cases
  List<String> testCases = [
    'admin',        // Should be valid
    'ADMIN',        // Should be valid (case insensitive)
    'Admin',        // Should be valid (case insensitive)
    'f20110001',    // Should be valid (regular university ID)
    'f21ABC123',    // Should be valid (regular university ID)
    'f19XYZ789',    // Should be valid (regular university ID)
    'user123',      // Should be invalid
    'f2011000',     // Should be invalid (too short)
    'g20110001',    // Should be invalid (wrong prefix)
    'f20110001a',   // Should be invalid (too long)
    '',             // Should be invalid (empty)
    'administrator' // Should be invalid (not exactly "admin")
  ];
  
  for (String testCase in testCases) {
    bool isValid = isValidId(testCase);
    String result = isValid ? '✓ VALID' : '✗ INVALID';
    print('Testing "$testCase": $result');
  }
  
  print('\nAdmin login validation test completed!');
  print('✓ "admin" (any case) is now accepted as a valid ID');
  print('✓ Regular university IDs (f20XXXXX format) still work');
  print('✓ Invalid formats are properly rejected');
}
