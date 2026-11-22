import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/logic/auth_controller.dart';
import '../../home/widgets/dashboard_bottom_navigation.dart';
import '../logic/profile_controller.dart';

/// Screen 16 — Profile & Settings.
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    this.profileController,
  });

  final ProfileController? profileController;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = widget.profileController ?? StubProfileController.instance;
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of Smart Grievance?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (_profileController is StubProfileController) {
                (_profileController as StubProfileController).clearSession();
              }
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/get-started',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        content: Text(
          '$title is connected and ready for backend configuration.',
          style: const TextStyle(fontFamily: 'Poppins', color: AppColors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _profileController is Listenable
          ? (_profileController as Listenable)
          : ValueNotifier<int>(0),
      builder: (context, _) {
        final currentProfile = _profileController.currentProfile;
        final displayName = currentProfile?.fullName.isNotEmpty == true
            ? currentProfile!.fullName
            : 'Rahul Sharma';
        final rawPhone = currentProfile?.phoneNumber.isNotEmpty == true
            ? currentProfile!.phoneNumber
            : '9876543210';
        final displayPhone = formatIndianMobile(rawPhone);

        return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            Navigator.of(context).pushReplacementNamed('/home'),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Citizen Profile Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2EDE7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displayPhone,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Settings List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _SettingsRow(
                    icon: Icons.person_outline_rounded,
                    title: 'My Profile',
                    onTap: () {
                      Navigator.of(context).pushNamed('/profile/edit');
                    },
                  ),
                  _SettingsRow(
                    icon: Icons.bookmark_border_rounded,
                    title: 'Saved Addresses',
                    onTap: () {
                      Navigator.of(context).pushNamed('/profile/saved-addresses');
                    },
                  ),
                  _SettingsRow(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    trailingText: 'English',
                    onTap: () => _showComingSoon('Language Settings'),
                  ),
                  _SettingsRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notification Preferences',
                    onTap: () => _showComingSoon('Notification Preferences'),
                  ),
                  _SettingsRow(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    onTap: () => _showComingSoon('Help & Support'),
                  ),
                  _SettingsRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'Privacy Policy',
                    onTap: () => _showComingSoon('Privacy Policy'),
                  ),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: _showLogoutDialog,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),

      // Fixed Bottom Navigation with Profile active (index: 3)
      bottomNavigationBar: DashboardBottomNavigation(
        selectedIndex: 3,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/home');
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed('/my-grievances');
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/grievance-map');
              break;
            case 3:
              // Already on profile
              break;
          }
        },
      ),
    );
      },
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailingText,
    this.iconColor,
    this.textColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? AppColors.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? AppColors.primaryText,
                    ),
                  ),
                ),
                if (trailingText != null) ...[
                  Text(
                    trailingText!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
