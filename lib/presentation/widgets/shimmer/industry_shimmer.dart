// lib/presentation/screens/application_portal/industry_management/view_industry_management/industry_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class IndustryShimmer extends StatelessWidget {
  const IndustryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
          ),
        );
      },
    );
  }
}
