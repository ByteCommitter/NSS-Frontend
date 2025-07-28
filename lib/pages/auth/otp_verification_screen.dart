import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/services/onboarding_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String universityId;
  final String? username;
  final bool isForRegistration;
  final String? newPassword; // For password reset flow

  const OTPVerificationScreen({
    super.key,
    required this.universityId,
    this.username,
    this.isForRegistration = true,
    this.newPassword,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  final AuthService _authService = Get.find<AuthService>();
  bool _isLoading = false;
  bool _isResending = false;
  
  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  void _onOTPChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOTP();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOTPCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOTP() async {
    final otpCode = _getOTPCode();
    if (otpCode.length != 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the complete 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final otpValue = int.parse(otpCode);
      
      if (widget.isForRegistration) {
        // Registration verification
        final response = await _authService.verifyUserOTP(widget.universityId, otpValue);
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        if (response != null && response['success'] == true) {
          Get.snackbar(
            'Registration Successful',
            'Your account has been created successfully! Welcome to NSS.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success.withOpacity(0.1),
            colorText: AppColors.success,
            duration: const Duration(seconds: 3),
          );

          // Navigate to onboarding
          Get.offAll(() => const OnboardingScreen());
        } else {
          String errorMessage = 'Invalid OTP. Please try again.';
          if (response != null && response['message'] != null) {
            errorMessage = response['message'];
          }
          
          Get.snackbar(
            'Verification Failed',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withOpacity(0.1),
            colorText: AppColors.error,
          );
          
          _clearOTP();
        }
      } else {
        // Password reset verification
        if (widget.newPassword == null) {
          Get.snackbar(
            'Error',
            'New password is required for password reset',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withOpacity(0.1),
            colorText: AppColors.error,
          );
          return;
        }

        final response = await _authService.resetPassword(
          widget.universityId, 
          otpValue, 
          widget.newPassword!
        );
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        if (response != null && response['success'] == true) {
          Get.snackbar(
            'Password Reset Successful',
            'Your password has been updated successfully. You can now login with your new password.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success.withOpacity(0.1),
            colorText: AppColors.success,
            duration: const Duration(seconds: 4),
          );

          // Navigate back to login screen
          Get.offAllNamed('/');
        } else {
          String errorMessage = 'Invalid OTP. Please try again.';
          if (response != null && response['message'] != null) {
            errorMessage = response['message'];
          }
          
          Get.snackbar(
            'Password Reset Failed',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withOpacity(0.1),
            colorText: AppColors.error,
          );
          
          _clearOTP();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      print('OTP verification error: $e');
      Get.snackbar(
        'Error',
        'An error occurred during verification. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
      
      _clearOTP();
    }
  }

  void _clearOTP() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
    });

    try {
      final response = await _authService.resendOTP(widget.universityId);
      
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }

      if (response != null && response['success'] == true) {
        Get.snackbar(
          'OTP Resent',
          'A new OTP has been sent to your university email address.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
        );
        
        _startResendTimer();
        _clearOTP();
      } else {
        String errorMessage = 'Failed to resend OTP. Please try again.';
        if (response != null && response['message'] != null) {
          errorMessage = response['message'];
        }
        
        Get.snackbar(
          'Resend Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }

      print('Resend OTP error: $e');
      Get.snackbar(
        'Error',
        'An error occurred while resending OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(widget.isForRegistration ? 'Verify Email' : 'Reset Password'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                widget.isForRegistration 
                    ? 'Verify Your Email' 
                    : 'Verify OTP',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'We have sent a 6-digit verification code to your university email address (${widget.universityId}@hyderabad.bits-pilani.ac.in)',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.divider),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (value) => _onOTPChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.isForRegistration ? 'Verify & Complete Registration' : 'Reset Password',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Resend OTP section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  if (_canResend)
                    TextButton(
                      onPressed: _isResending ? null : _resendOTP,
                      child: _isResending
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Resend',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )
                  else
                    Text(
                      'Resend in ${_resendCountdown}s',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Additional instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check your email',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please check your spam/junk folder if you don\'t see the email in your inbox.',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
