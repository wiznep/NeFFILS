import 'package:flutter/material.dart';
import 'package:neffils/utils/colors/color.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/userProfile_model.dart';
import '../../widgets/shimmer/PersonalDetailsShimmerLoader.dart';
import 'edit_personal_information_screen.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late Future<UserProfile> _profileFuture;
  final ProfileRepository _profileRepository = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = _profileRepository.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: appColors.formsubmit,
        foregroundColor: Colors.white,
        title: const Text('My Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final user = await _profileFuture;
              final result = await Navigator.push<UserProfile?>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPersonalDetailsScreen(profile: user),
                ),
              );
              if (result != null) {
                setState(() {
                  _profileFuture = Future.value(result);
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const PersonalDetailsShimmerLoader();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return _buildProfileDetails(snapshot.data!);
          } else {
            return const Center(child: Text('No profile data found.'));
          }
        },
      ),
    );
  }

  Widget _buildProfileDetails(UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Personal Information'),
          const SizedBox(height: 8),
          _buildDetailItem('Username', profile.username),
          _buildDetailItem('Full Name', profile.fullNameEn),
          _buildDetailItem('Phone Number', profile.phoneNumber),
          _buildDetailItem('E-mail Address', profile.email),
          _buildDetailItem('Status', profile.isActive ? 'Active' : 'Inactive'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
