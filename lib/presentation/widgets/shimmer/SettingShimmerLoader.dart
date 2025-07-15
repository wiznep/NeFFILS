import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SettingShimmerLoader extends StatelessWidget {
  const SettingShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            const SizedBox(height: 50),

            // Profile picture shimmer
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 16),

            // Name shimmer
            Container(
              width: 140,
              height: 16,
              color: Colors.white,
            ),
            const SizedBox(height: 8),

            // Email shimmer
            Container(
              width: 180,
              height: 14,
              color: Colors.white,
            ),
            const SizedBox(height: 4),

            // Phone shimmer
            Container(
              width: 150,
              height: 14,
              color: Colors.white,
            ),

            const SizedBox(height: 24),

            // Shimmer menu items
            ...List.generate(4, (index) => _shimmerMenuItem()),

            const SizedBox(height: 16),

            // Logout button shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Footer shimmer
            Container(
              width: 220,
              height: 12,
              color: Colors.white,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _shimmerMenuItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
