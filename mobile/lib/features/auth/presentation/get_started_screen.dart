import 'package:flutter/material.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/auth_controller.dart';
import '../widgets/mobile_number_field.dart';
import '../widgets/send_otp_button.dart';

/// Screen 03 — Get Started / Mobile Number Login.
///
/// Allows a citizen to enter their Indian mobile number to receive an OTP.
/// The OTP verification screen is out-of-scope for this iteration.
class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  // ── State ────────────────────────────────────────────────────────────────
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  final AuthController _auth = StubAuthController();

  String _phone = '';
  String? _errorText;
  bool _isLoading = false;

  // ── Helpers ──────────────────────────────────────────────────────────────
  void _onPhoneChanged(String value) {
    setState(() {
      _phone = value;
      // Clear error while user is actively typing.
      if (_errorText != null) _errorText = null;
    });
  }

  Future<void> _onSendOtp() async {
    // Validate before hitting the network.
    final error = validateIndianMobile(_phone);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final result = await _auth.sendOtp(_phone);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(
            'OTP sent to +91 $_phone',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.white,
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pushNamed(
        AppRouter.verifyOtp,
        arguments: _phone,
      );
    } else {
      setState(() => _errorText = result.message ?? 'Failed to send OTP.');
    }
  }

  void _onRegister() {
    // Registration screen is not yet implemented.
    // Update this route once Screen 04 / Registration is built.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Registration screen coming soon.',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard when tapping outside the input.
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
                      const SizedBox(height: 32),

                      // A. Brand logo — centred
                      Center(
                        child: Image.asset(
                          'assets/images/smart_grievance_logo.png',
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // B. Main heading
                      const Text(
                        'Get Started',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // C. Supporting description
                      const Text(
                        'Enter your mobile number to continue',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryText,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // D. Mobile number input
                      MobileNumberField(
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        onChanged: _onPhoneChanged,
                        errorText: _errorText,
                      ),

                      const SizedBox(height: 28),

                      // E. Send OTP button
                      SendOtpButton(
                        onPressed: _onSendOtp,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 32),

                      // F. Registration link
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: _onRegister,
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Extra breathing room before illustration
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // G. Bottom cityscape illustration — always visible at bottom
              _CityscapeIllustration(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom cityscape illustration — flush with bottom edge.
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
