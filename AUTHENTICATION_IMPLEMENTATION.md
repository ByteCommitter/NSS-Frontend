# NSS Authentication Flow Implementation

## Overview
This document outlines the new OTP-based authentication system implemented for the NSS Frontend application. The new flow replaces the simple Google Sign-in with a comprehensive email verification system.

## New Authentication Flow

### 1. Registration Flow
**Steps:**
1. User enters University ID, Username, and Password on Registration Screen
2. System sends OTP to university email (`universityId@hyderabad.bits-pilani.ac.in`)
3. User receives email and enters 6-digit OTP on Verification Screen
4. System verifies OTP and creates user account
5. User is redirected to Onboarding Screen

**Files Created:**
- `lib/pages/auth/registration_screen.dart` - Registration form with validation
- `lib/pages/auth/otp_verification_screen.dart` - OTP input and verification

### 2. Login Flow
**Steps:**
1. User enters University ID and Password on Login Screen
2. System validates credentials
3. If valid, user is logged in and redirected to app

**Files Modified:**
- `lib/pages/login_screen.dart` - Updated with proper form validation and new UI

### 3. Forgot Password Flow
**Steps:**
1. User clicks "Forgot Password" on Login Screen
2. User enters University ID on Forgot Password Screen
3. System sends reset OTP to university email
4. User enters OTP and new password on Reset Password Screen
5. System verifies OTP and updates password
6. User is redirected back to Login Screen

**Files Created:**
- `lib/pages/auth/forgot_password_screen.dart` - University ID input for password reset
- `lib/pages/auth/reset_password_screen.dart` - OTP + new password form

## API Endpoints Integration

### Updated API Service Methods
- `registerWithOTP()` - POST /auth/register
- `resendOTP()` - POST /auth/resendOTP  
- `verifyUser()` - POST /auth/verifyUser
- `forgotPassword()` - POST /auth/forgotPassword
- `resetPassword()` - POST /auth/resetPassword

### Updated Auth Service Methods
- `registerWithOTP()` - Initiate registration with OTP
- `resendOTP()` - Resend OTP for verification
- `verifyUserOTP()` - Complete registration by verifying OTP
- `forgotPassword()` - Send password reset OTP
- `resetPassword()` - Reset password with OTP verification

## Security Features

### Email Verification
- All registrations require email verification via OTP
- Prevents fake registrations with invalid university IDs
- OTP sent to official university email addresses

### Password Reset Security
- Reset codes are valid for 10 minutes only
- OTP required for password changes
- Secure token-based verification via Redis

### Input Validation
- University ID format validation (f20XXXXX pattern)
- Password strength requirements (minimum 6 characters)
- Real-time form validation with error messages

## User Experience Features

### OTP Verification Screen
- 6-digit OTP input with auto-focus progression
- Resend OTP functionality with 60-second cooldown
- Clear instructions and email confirmation
- Error handling for invalid/expired OTPs

### Visual Design
- Consistent Material Design UI across all screens
- Loading states for async operations
- Success/error snackbar notifications
- Proper keyboard handling and input types

### Navigation Flow
- Seamless transitions between authentication screens
- Proper back navigation and route management
- Auto-redirect after successful operations

## Configuration

### Base URL
- Updated to use production URL: `https://nssapp.duckdns.org/`
- Can be easily switched for development/testing

### Route Management
- Added new routes in `app_routes.dart`
- Centralized navigation management

## Testing Recommendations

### Manual Testing
1. **Registration Flow:**
   - Test with valid university ID format
   - Verify email is received with OTP
   - Test OTP verification and account creation
   - Test resend OTP functionality

2. **Login Flow:**
   - Test with valid/invalid credentials
   - Verify proper error messages
   - Test authentication state management

3. **Password Reset Flow:**
   - Test forgot password email sending
   - Verify reset OTP functionality
   - Test password update and login with new password

### Edge Cases
- Network connectivity issues
- Expired OTPs
- Invalid email addresses
- Malformed university IDs
- Password confirmation mismatches

## Future Enhancements

### Potential Improvements
1. **Email Templates:** Custom branded email templates for OTPs
2. **Rate Limiting:** Implement rate limiting for OTP requests
3. **Biometric Auth:** Add fingerprint/face ID for returning users
4. **Account Recovery:** Additional recovery options for locked accounts
5. **Two-Factor Authentication:** Optional 2FA for enhanced security

### Monitoring
- Track registration completion rates
- Monitor OTP delivery success rates
- Log authentication failures for security analysis

## Deployment Notes

### Environment Variables
- Ensure backend API URL is properly configured
- Verify email service configuration
- Test email delivery in production environment

### Database Considerations
- User verification status tracking
- OTP storage and expiration in Redis
- Proper indexing on university_id fields

## Support Information

### Common Issues
1. **Email Not Received:** Check spam folder, verify email service
2. **Invalid OTP:** Ensure 6-digit numeric code, check expiration
3. **University ID Format:** Must follow f20XXXXX pattern exactly
4. **Password Reset:** Codes expire after 10 minutes

### Contact Information
- Technical issues: Check server logs and API responses
- User issues: Guide users through email verification process
- Email delivery issues: Verify email service configuration

---

*This implementation provides a secure, user-friendly authentication system that prevents fraud while maintaining a smooth user experience.*
