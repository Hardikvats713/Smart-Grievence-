import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/logic/auth_controller.dart';
import '../../profile/logic/district_provider.dart';
import '../../profile/logic/profile_controller.dart';
import '../../profile/widgets/district_dropdown.dart';
import '../../profile/widgets/profile_avatar_picker.dart';
import '../../profile/widgets/profile_text_field.dart';
import '../../grievances/widgets/grievance_header.dart';

/// Screen 22 — Edit Profile (My Profile).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.controller,
    this.districtProvider,
  });

  final ProfileController? controller;
  final DistrictProvider? districtProvider;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileController _controller;
  late final DistrictProvider _districtProvider;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  String? _selectedDistrict;
  late final String _verifiedPhone;
  Uint8List? _avatarBytes;
  String? _avatarPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? StubProfileController.instance;
    _districtProvider = widget.districtProvider ?? const ConfiguredDistrictProvider();

    final current = _controller.currentProfile;
    _nameController = TextEditingController(text: current?.fullName ?? 'Rahul Sharma');
    _emailController = TextEditingController(text: current?.email ?? 'rahul.sharma@email.com');
    _selectedDistrict = current?.district ?? 'Papum Pare';
    _verifiedPhone = current?.phoneNumber ?? '9876543210';
    _avatarBytes = current?.photoBytes;
    _avatarPath = current?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final updated = UserProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      district: _selectedDistrict ?? 'Papum Pare',
      phoneNumber: _verifiedPhone,
      photoBytes: _avatarBytes,
      photoPath: _avatarPath,
    );

    final result = await _controller.saveProfile(updated);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Profile updated successfully'),
          ),
        );
        Navigator.of(context).maybePop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(result.message ?? 'Failed to update profile'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  GrievanceHeader(
                    title: 'My Profile',
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Avatar with camera icon
                      Center(
                        child: ProfileAvatarPicker(
                          photoBytes: _avatarBytes,
                          photoPath: _avatarPath,
                          onPhotoSelected: (result) {
                            setState(() {
                              if (result == null) {
                                _avatarBytes = null;
                                _avatarPath = null;
                              } else {
                                _avatarBytes = result.bytes;
                                _avatarPath = result.filePath;
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Full Name
                      ProfileTextField(
                        label: 'Full Name',
                        hintText: 'Rahul Sharma',
                        controller: _nameController,
                        errorText: validateFullName(_nameController.text),
                      ),
                      const SizedBox(height: 14),

                      // Email
                      ProfileTextField(
                        label: 'Email',
                        hintText: 'rahul.sharma@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        errorText: validateEmail(_emailController.text),
                      ),
                      const SizedBox(height: 14),

                      // District / City
                      DistrictDropdown(
                        selectedDistrict: _selectedDistrict,
                        districtProvider: _districtProvider,
                        onChanged: (val) => setState(() => _selectedDistrict = val),
                        errorText: validateDistrict(_selectedDistrict),
                      ),
                      const SizedBox(height: 14),

                      // Mobile Number (Verified, non-editable without OTP)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mobile Number',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECE7E1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  formatIndianMobile(_verifiedPhone),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondarySurface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Save Changes Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
