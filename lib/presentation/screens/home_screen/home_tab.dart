import 'dart:async';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:neffils/presentation/screens/application_portal/industry_management/view_Industry_management_screen.dart';
import 'package:neffils/presentation/screens/application_portal/license_renewal_screen.dart';
import 'package:neffils/presentation/screens/application_portal/new_license/view_license_screen.dart';
import 'package:neffils/presentation/screens/application_portal/other_services_screen.dart';
import 'package:neffils/presentation/screens/application_portal/recommendations/view_recommendation_screen.dart';
import 'package:neffils/presentation/screens/settings/personal_details_screen.dart';
import 'package:neffils/ui/color_manager.dart';
import 'package:neffils/ui/styles_manager.dart';
import 'package:neffils/ui/values_manager.dart';
import 'package:neffils/utils/colors/color.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_providers.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/userProfile_model.dart';
import '../auth/login_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  late Future<UserProfile> _profileFuture;
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _showShimmer = true;
  bool _hasError = false;
  int _currentCarousel = 0;

  final List<String> carouselImages = [
    'assets/images/slider/banner.jpg',
    'assets/images/slider/banner.jpg',
    'assets/images/slider/banner.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();

    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
      }
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
    }
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = _profileRepository.getUserProfile().catchError((error) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _showShimmer
                  ? _buildShimmerContent()
                  : FutureBuilder<UserProfile>(
                      future: _profileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildShimmerContent();
                        } else if (snapshot.hasError || _hasError) {
                          return _buildContentWithPlaceholder();
                        } else if (snapshot.hasData) {
                          return _buildContent(snapshot.data!);
                        } else {
                          return _buildContentWithPlaceholder();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildShimmerHeader(),
          const SizedBox(height: 20),
          _buildShimmerCarousel(),
          const SizedBox(height: 8),
          _buildShimmerDotIndicators(),
          const SizedBox(height: 20),
          _buildShimmerApplicationPortal(),
        ],
      ),
    );
  }

  Widget _buildContent(UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          _buildHeader(context, profile),
          const SizedBox(height: 20),
          _buildCarousel(),
          const SizedBox(height: 8),
          _buildDotIndicators(),
          const SizedBox(height: 20),
          _buildApplicationPortal(context),
        ],
      ),
    );
  }

  Widget _buildContentWithPlaceholder() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          _buildHeaderWithPlaceholder(context),
          const SizedBox(height: 20),
          _buildCarousel(),
          const SizedBox(height: 8),
          _buildDotIndicators(),
          const SizedBox(height: 20),
          _buildApplicationPortal(context),
        ],
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 120,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 150,
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PersonalDetailsScreen(),
                  ),
                ),
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: appColors.formsubmit,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey, ${profile.username.toUpperCase()}!',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.fullNameEn.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(
              Icons.notifications_none,
              color: appColors.formsubmit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: appColors.formsubmit,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey, USER!',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LOADING...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(
              Icons.notifications_none,
              color: appColors.formsubmit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCarousel() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: true,
        height: 180,
        viewportFraction: 0.9,
        onPageChanged: (index, reason) {
          setState(() {
            _currentCarousel = index;
          });
        },
      ),
      items: carouselImages.map((path) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShimmerDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
        );
      }),
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(carouselImages.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentCarousel == index ? 10.0 : 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentCarousel == index
                ? appColors.formsubmit
                : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildShimmerApplicationPortal() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        height: 200,
        decoration: BoxDecoration(
          color: appColors.defaultwhite,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildApplicationPortal(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: appColors.defaultwhite,
          borderRadius: BorderRadius.circular(0),
          // boxShadow: [
          //   BoxShadow(color: Colors.black12, blurRadius: 6),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Portal',
              style: getSemiBoldStyle(
                fontSize: AppSize.s16,
                color: appColors.formsubmit,
              ),
            ),
            // const SizedBox(height: 16),
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                _buildServiceItem(
                  context,
                  'Industry Management',
                  'ic_industry.png',
                  ViewIndustryManagementScreen(),
                ),
                _buildServiceItem(
                  context,
                  'Recommendation',
                  'ic_recommendation.png',
                  ViewRecommendationScreen(),
                ),
                _buildServiceItem(
                  context,
                  'New License',
                  'ic_new-license.png',
                  ViewLicenseScreen(),
                ),
                _buildServiceItem(
                  context,
                  'License Renewal',
                  'ic_license-renewal.png',
                  LicenseRenewalScreen(),
                ),
                _buildServiceItem(
                  context,
                  'Other Services',
                  'ic_others.png',
                  OtherServicesScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    String title,
    String icon,
    Widget page,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              Image.asset('assets/icons/$icon', height: 40, width: 40),
              const SizedBox(width: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: getMediumStyle(
                  fontSize: AppSize.s14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
