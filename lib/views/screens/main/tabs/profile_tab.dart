import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../constants/app_constants.dart';
import '../../../../models/user.dart';
import '../../../../widgets/custom_button.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Profile header
              _buildProfileHeader(user),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Profile actions
              _buildProfileActions(),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Settings
              _buildSettings(),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Support and legal
              _buildSupportAndLegal(),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Logout button
              _buildLogoutButton(authController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile image
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: user?.profileImage != null
                ? NetworkImage(user!.profileImage!)
                : null,
            child: user?.profileImage == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  )
                : null,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          
          // User name
          Text(
            user?.fullName ?? 'User Name',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          
          // User email
          Text(
            user?.email ?? 'user@example.com',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          
          // Edit profile button
          CustomButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.editProfile);
            },
            isOutlined: true,
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileActionTile(
            icon: Icons.payment,
            title: 'Payment Methods',
            subtitle: 'Manage your payment options',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.paymentMethods);
            },
          ),
          _buildDivider(),
          _buildProfileActionTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Configure notification preferences',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.notifications);
            },
          ),
          _buildDivider(),
          _buildProfileActionTile(
            icon: Icons.security,
            title: 'Security',
            subtitle: 'Password and security settings',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.security);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileActionTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.language);
            },
          ),
          _buildDivider(),
          _buildProfileActionTile(
            icon: Icons.currency_exchange,
            title: 'Currency',
            subtitle: 'USD (\$)',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.currency);
            },
          ),
          _buildDivider(),
          _buildProfileActionTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Off',
            trailing: Switch(
              value: false, // TODO: Implement dark mode when theme controller is ready
              onChanged: (value) {
                // TODO: Toggle dark mode when theme controller is ready
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dark mode ${value ? 'enabled' : 'disabled'}'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportAndLegal() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileActionTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.help);
            },
          ),
          _buildDivider(),
          _buildProfileActionTile(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Read our terms and conditions',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.terms);
            },
          ),
          _buildDivider(),
          _buildProfileActionTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Learn about our privacy practices',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.privacy);
            },
          ),
          _buildDivider(),
          _buildProfileActionTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.about);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AuthController authController) {
    return CustomButton(
      onPressed: () {
        _showLogoutDialog(authController);
      },
      backgroundColor: AppColors.error,
      child: const Text('Logout'),
    );
  }

  Widget _buildProfileActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
    );
  }

  void _showLogoutDialog(AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authController.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 