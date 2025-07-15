import 'package:flutter/material.dart';

class RecommendationShimmer extends StatelessWidget {
  const RecommendationShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150,
                      height: 20,
                      color: Colors.grey[300],
                    ),
                    Container(
                      width: 80,
                      height: 20,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 16,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 80,
                      height: 30,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 30,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}