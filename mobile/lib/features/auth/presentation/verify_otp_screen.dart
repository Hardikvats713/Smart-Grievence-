import 'package:flutter/material.dart';
import '../../../app/router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/auth_controller.dart';
import '../logic/remote_auth_service.dart';
import '../widgets/otp_input_fields.dart';
import '../widgets/resend_otp_control.dart';

/// Screen 04 — Verify OTP.
///
/// Citizen enters the 6-digit OTP sent to their mobile number.
/// Verifies through [AuthController] and navigates to the next flow on success.
class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({
    super.key,
    this.phoneNumber,
    this.authController,
  });

  /// 10-digit mobile number passed from previous screen.
  final String? phoneNumber;

  /// Optional injected auth controller for testing.
  final AuthController? authController;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final GlobalKey<OtpInputFieldsState> _otpKey = GlobalKey<OtpInputFieldsState>();
  final GlobalKey<ResendOtpControlState> _resendKey =
      GlobalKey<ResendOtpControlState>();

  late final AuthController _auth;
  String _effectivePhone = '';
  String _enteredOtp = '';
  String? _errorMessage;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _auth = widget.authController ?? RemoteAuthController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_effectivePhone.isEmpty) {
      final routeArg = ModalRoute.of(context)?.settings.arguments;
      if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
        _effectivePhone = widget.phoneNumber!;
      } else if (routeArg is String && routeArg.isNotEmpty) {
        _effectivePhone = routeArg;
      } else {
        _effectivePhone = '9876543210';
      }
    }
  }

  bool get _canVerify => _enteredOtp.length == 6 && !_isVerifying;

  void _onOtpChanged(String otp) {
    setState(() {
      _enteredOtp = otp;
      if (_errorMessage != null) _errorMessage = null;
    });
  }

  Future<void> _handleVerify() async {
    if (_enteredOtp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits of the OTP';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final result = await _auth.verifyOtp(_effectivePhone, _enteredOtp);

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text(
            'OTP verified successfully!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      final activeRole = await ApiClient.getActiveRole();
      final roles = await ApiClient.getRoles();
      if (!mounted) return;

      if (roles.length > 1) {
        Navigator.of(context).pushReplacementNamed(AppRouter.roleSelection);
      } else if (activeRole == 'DEPARTMENT_OFFICER' ||
          activeRole == 'SENIOR_OFFICER' ||
          activeRole == 'ADMINISTRATOR') {
        Navigator.of(context).pushReplacementNamed(AppRouter.officerDashboard);
      } else {
        Navigator.of(context).pushNamed(
          AppRouter.setupProfile,
          arguments: _effectivePhone,
        );
      }
    } else {
      setState(() {
        _errorMessage = result.message ?? 'Invalid or expired OTP. Please try again.';
      });
    }
  }

  Future<void> _handleResend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    final result = await _auth.resendOtp(_effectivePhone);

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    if (result.isSuccess) {
      _resendKey.currentState?.restartCooldown(_auth.resendCooldownSeconds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(
            'New OTP sent to ${formatIndianMobile(_effectivePhone)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = result.message ?? 'Failed to resend OTP. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedNumber = formatIndianMobile(_effectivePhone);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Scrollable content area ───────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Back navigation arrow
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.primaryText,
                            size: 24,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // A. Brand header — centered logo
                      Center(
                        child: Image.asset(
                          'assets/images/smart_grievance_logo.png',
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // B. Main heading
                      const Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // C. Supporting description + dynamic mobile number
                      const Text(
                        'Enter the 6-digit OTP sent to',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedNumber,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // D. 6-digit OTP input boxes
                      OtpInputFields(
                        key: _otpKey,
                        onChanged: _onOtpChanged,
                        onCompleted: (val) {
                          // Automatically ready to verify, user taps Verify
                        },
                        hasError: _errorMessage != null,
                      ),

                      // Inline error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // E. Resend OTP timer control
                      Center(
                        child: ResendOtpControl(
                          key: _resendKey,
                          initialCooldownSeconds: _auth.resendCooldownSeconds,
                          onResend: _handleResend,
                          isResending: _isResending,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // F. Verify button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _canVerify ? _handleVerify : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.disabled,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Text(
                                  'Verify',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // G. Bottom cityscape illustration
              _CityscapeIllustration(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityscapeIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth,
      child: Image.asset(
        'assets/images/get_started_cityscape.png',
        width: screenWidth,
        fit: BoxFit.fitWidth,
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}

