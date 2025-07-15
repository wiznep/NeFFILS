import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:neffils/utils/colors/color.dart';

class PersonalDetailsShimmerLoader extends StatelessWidget {
  const PersonalDetailsShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Container(
              height: 20,
              width: 180,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 16),
            ),

            // Repeated shimmer tiles for profile details
            ...List.generate(5, (_) => _shimmerDetailItem()),
          ],
        ),
      ),
    );
  }

  Widget _shimmerDetailItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: appColors.default2white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label shimmer
          Container(
            height: 14,
            width: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 8),

          // Value shimmer
          Container(
            height: 16,
            width: double.infinity,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
