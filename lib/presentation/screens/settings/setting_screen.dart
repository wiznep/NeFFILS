import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neffils/presentation/screens/auth/password_screen/forgot_password_screen.dart';
import 'package:neffils/presentation/screens/settings/personal_details_screen.dart';
import 'package:neffils/presentation/widgets/shimmer/SettingShimmerLoader.dart';
import 'package:neffils/utils/colors/color.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_providers.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/userProfile_model.dart';
import '../auth/login_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> with WidgetsBindingObserver {
  late Future<UserProfile> _profileFuture;
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _showShimmer = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();

    Timer(const Duration(seconds: 1), () {
      setState(() {
        _showShimmer = false;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadProfile();
      setState(() {});
    }
  }

  void _loadProfile() {
    _profileFuture = _profileRepository.getUserProfile().catchError((error) {
      setState(() {
        _hasError = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _showShimmer
          ? const SettingShimmerLoader()
          : FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SettingShimmerLoader();
          } else if (snapshot.hasError || _hasError) {
            return _buildContentWithPlaceholder();
          } else if (snapshot.hasData) {
            return _buildContent(snapshot.data!);
          } else {
            return _buildContentWithPlaceholder();
          }
        },
      ),
    );
  }

  Widget _buildContent(UserProfile profile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileImage('https://example.com/profile.jpg'),
                const SizedBox(height: 16),
                Text(
                  profile.fullNameEn.toUpperCase(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.email, profile.email),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.phone, profile.phoneNumber),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuOptions(),
        ],
      ),
    );
  }

  Widget _buildContentWithPlaceholder() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileImage(null),
                const SizedBox(height: 16),
                const Text(
                  'N/A',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.email, 'N/A'),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.phone, 'N/A'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuOptions(),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    return CircleAvatar(
      radius: 54,
      backgroundColor: appColors.formsubmit,
      child: Icon(Icons.person, color: Colors.white , size: 60),
    );
  }

  Widget _buildInfoRow(IconData icon, String info) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.black),
        const SizedBox(width: 8),
        Text(
          info,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      children: [
        buildMenuBox(
          icon: Icons.person,
          title: 'My Details',
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PersonalDetailsScreen()),
            );
            _loadProfile();
            setState(() {});
          },
        ),
        buildMenuBox(
          icon: Icons.password,
          title: 'Change Password',
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
            );
            _loadProfile();
            setState(() {});
          },
        ),
        buildMenuBox(
          icon: Icons.task_alt,
          title: 'Terms & Conditions',
          onTap: () {
            _showComingSoon(context);
          },
        ),
        buildMenuBox(
          icon: Icons.info,
          title: 'About App',
          onTap: () {
            _showComingSoon(context);
          },
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showLogoutConfirmation(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.formsubmit,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Neffils ©2025 Created by Kantipur Infotech',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget buildMenuBox({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: appColors.default2white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: appColors.formsubmit),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
