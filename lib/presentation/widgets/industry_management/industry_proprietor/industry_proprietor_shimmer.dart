import 'package:flutter/material.dart';
import 'package:neffils/utils/colors/color.dart';

class ProprietorShimmer extends StatelessWidget {
  const ProprietorShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionShimmer(),
          const SizedBox(height: 16),
          _buildFieldShimmer(),
          const SizedBox(height: 16),
          _buildFieldShimmer(),
          const SizedBox(height: 16),
          _buildSignatureShimmer(),
          const SizedBox(height: 24),
          _buildSectionShimmer(),
          const SizedBox(height: 16),
          _buildDropdownShimmer(),
          const SizedBox(height: 16),
          _buildDropdownShimmer(),
          const SizedBox(height: 16),
          _buildDropdownShimmer(),
          const SizedBox(height: 16),
          _buildDropdownShimmer(),
          const SizedBox(height: 16),
          _buildFieldShimmer(),
          const SizedBox(height: 16),
          _buildFieldShimmer(),
          const SizedBox(height: 16),
          _buildFieldShimmer(),
          const SizedBox(height: 24),
          _buildSectionShimmer(),
          const SizedBox(height: 16),
          _buildCheckboxShimmer(),
          const SizedBox(height: 24),
          _buildSectionShimmer(),
          const SizedBox(height: 16),
          _buildFieldShimmer(),
          const SizedBox(height: 16),
          _buildFieldShimmer(),
          const SizedBox(height: 16),
          _buildFieldShimmer(),
          const SizedBox(height: 16),
          _buildFieldShimmer(),
          const SizedBox(height: 16),
          _buildFieldShimmer(),
          const SizedBox(height: 16),
          _buildFieldShimmer(),
        ],
      ),
    );
  }

  Widget _buildSectionShimmer() {
    return Container(
      height: 24,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildFieldShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 16,
          width: 100,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 16,
          width: 100,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 16,
          width: 100,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxShimmer() {
    return Row(
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 16,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}