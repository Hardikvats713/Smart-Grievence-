import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/district_provider.dart';
import '../logic/photo_picker_service.dart';
import '../logic/profile_controller.dart';
import '../widgets/district_dropdown.dart';
import '../widgets/profile_avatar_picker.dart';
import '../widgets/profile_text_field.dart';

/// Screen 05 — Set Up Your Profile.
///
/// Citizen registers their name, optional email, district, and avatar photo
/// following successful OTP verification.
class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({
    super.key,
    this.phoneNumber,
    this.profileController,
    this.districtProvider,
    this.photoPickerService,
  });

  /// Verified 10-digit phone number passed from OTP verification.
  final String? phoneNumber;

  /// Optional injected controller for testing.
  final ProfileController? profileController;

  /// Optional injected district provider for testing.
  final DistrictProvider? districtProvider;

  /// Optional injected photo picker service for testing.
  final PhotoPickerService? photoPickerService;

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  late final ProfileController _controller;
  late final DistrictProvider _districtProvider;
  late final PhotoPickerService _photoService;

  String _effectivePhone = '';
  String? _selectedDistrict;
  Uint8List? _avatarBytes;
  String? _avatarPath;

  String? _nameError;
  String? _emailError;
  String? _districtError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.profileController ?? StubProfileController.instance;
    _districtProvider = widget.districtProvider ?? const ConfiguredDistrictProvider();
    _photoService = widget.photoPickerService ?? const DefaultPhotoPickerService();

    // Preserve previously selected avatar photo across navigation returns
    final current = _controller.currentProfile;
    if (current != null) {
      if (current.photoBytes != null) _avatarBytes = current.photoBytes;
      if (current.photoPath != null) _avatarPath = current.photoPath;
    }
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    if (_nameError != null) {
      setState(() => _nameError = null);
    }
  }

  void _onEmailChanged(String value) {
    if (_emailError != null) {
      setState(() => _emailError = null);
    }
  }

  void _onDistrictChanged(String district) {
    setState(() {
      _selectedDistrict = district;
      if (_districtError != null) {
        _districtError = null;
      }
    });
  }

  void _onPhotoPicked(PhotoPickResult? result) {
    setState(() {
      if (result == null) {
        _avatarBytes = null;
        _avatarPath = null;
      } else {
        _avatarBytes = result.bytes;
        _avatarPath = result.filePath;
      }
    });
  }

  Future<void> _handleContinue() async {
    // Validate inputs
    final nameErr = validateFullName(_nameController.text);
    final emailErr = validateEmail(_emailController.text);
    final distErr = validateDistrict(_selectedDistrict);

    if (nameErr != null || emailErr != null || distErr != null) {
      setState(() {
        _nameError = nameErr;
        _emailError = emailErr;
        _districtError = distErr;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _nameError = null;
      _emailError = null;
      _districtError = null;
    });

    final profile = UserProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      district: _selectedDistrict!,
      phoneNumber: _effectivePhone,
      photoBytes: _avatarBytes,
      photoPath: _avatarPath,
    );

    final result = await _controller.saveProfile(profile);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text(
            'Profile saved successfully!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate to Allow Access / Permissions screen
      Navigator.of(context).pushReplacementNamed('/allow-access');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            result.message ?? 'Failed to save profile. Please try again.',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Decorative cityscape illustration anchored behind content at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 75,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/get_started_cityscape.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),

            // Main scrollable form container
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),

                    // Top Bar: Back button on left + Centered Logo
                    SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.primaryText,
                                size: 22,
                              ),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                          Center(
                            child: Image.asset(
                              'assets/images/smart_grievance_logo.png',
                              width: 118,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Heading
                    const Text(
                      'Set Up Your Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Circular Avatar with overlapping camera button
                    ProfileAvatarPicker(
                      photoBytes: _avatarBytes,
                      photoPath: _avatarPath,
                      onPhotoSelected: _onPhotoPicked,
                      pickerService: _photoService,
                    ),

                    const SizedBox(height: 12),

                    // Form Field 1: Full Name (Required)
                    ProfileTextField(
                      label: 'Full Name',
                      hintText: 'Enter your full name',
                      controller: _nameController,
                      focusNode: _nameFocus,
                      keyboardType: TextInputType.name,
                      onChanged: _onNameChanged,
                      errorText: _nameError,
                    ),

                    const SizedBox(height: 9),

                    // Form Field 2: Email (Optional)
                    ProfileTextField(
                      label: 'Email (Optional)',
                      hintText: 'Enter your email address',
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: _onEmailChanged,
                      errorText: _emailError,
                    ),

                    const SizedBox(height: 9),

                    // Form Field 3: District / City Dropdown
                    DistrictDropdown(
                      selectedDistrict: _selectedDistrict,
                      onChanged: _onDistrictChanged,
                      districtProvider: _districtProvider,
                      errorText: _districtError,
                    ),

                    const SizedBox(height: 16),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _handleContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.disabled,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


