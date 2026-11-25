import 'package:flutter/material.dart';
import '../../../app/router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';

/// Role Selection Screen shown after OTP verification when a user
/// holds multiple authorized roles, or accessed to switch portals.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  List<String> _roles = ['CITIZEN'];
  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final roles = await ApiClient.getRoles();
    if (mounted) {
      setState(() => _roles = roles);
    }
  }

  Future<void> _selectRole(String role) async {
    setState(() => _isSwitching = true);
    final res = await ApiClient.post('/auth/switch-role', {'role': role});
    if (res.success && res.data is Map<String, dynamic>) {
      final token = res.data['accessToken']?.toString() ?? '';
      if (token.isNotEmpty) {
        await ApiClient.saveSession(
          accessToken: token,
          refreshToken: '',
          activeRole: role,
          roles: _roles,
        );
      }
    }

    if (!mounted) return;
    setState(() => _isSwitching = false);

    if (role == 'DEPARTMENT_OFFICER' ||
        role == 'SENIOR_OFFICER' ||
        role == 'ADMINISTRATOR') {
      Navigator.of(context).pushReplacementNamed(AppRouter.officerDashboard);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text(
          'Select Workspace Role',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
      body: _isSwitching
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose your active portal',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your account has multiple authorized roles. Select how you want to continue.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._roles.map((role) => _RoleTile(
                        role: role,
                        onTap: () => _selectRole(role),
                      )),
                ],
              ),
            ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({required this.role, required this.onTap});
  final String role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, icon) = switch (role) {
      'DEPARTMENT_OFFICER' => (
          'Department Officer',
          'Manage grievances assigned to your department & jurisdiction',
          Icons.engineering_outlined,
        ),
      'SENIOR_OFFICER' => (
          'Senior Officer',
          'Supervise field officers, review resolutions & escalations',
          Icons.admin_panel_settings_outlined,
        ),
      'ADMINISTRATOR' => (
          'System Administrator',
          'Configure departments, SLA policies, roles & audit logs',
          Icons.security_outlined,
        ),
      _ => (
          'Citizen Portal',
          'Report civic issues, track complaints & submit feedback',
          Icons.person_outline,
        ),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: AppColors.secondarySurface,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.secondaryText,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
        onTap: onTap,
      ),
    );
  }
}
