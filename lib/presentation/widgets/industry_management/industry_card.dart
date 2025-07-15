import 'package:flutter/material.dart';
import 'package:neffils/utils/colors/color.dart';
import '../../../../domain/models/industry/industry_view_model.dart';

class IndustryCard extends StatelessWidget {
  final IndustryView industry;
  final VoidCallback? onEdit;
  final VoidCallback? onRecommend;
  final VoidCallback? onLicense;

  const IndustryCard({
    super.key,
    required this.industry,
    this.onEdit,
    this.onRecommend,
    this.onLicense,
  });

  @override
  Widget build(BuildContext context) {
    final hasActions = onEdit != null || onRecommend != null || onLicense != null;

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    industry.nameEn.isNotEmpty && industry.nameNp.isNotEmpty
                        ? '${industry.nameEn} (${industry.nameNp})'
                        : industry.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusBadge(industry.status),
              ],
            ),
            const SizedBox(height: 16),

            // Address
            if (industry.addressEn.isNotEmpty || industry.addressNp.isNotEmpty)
              _buildDetailRow(
                Icons.location_on,
                'Industry Address',
                _joinValues(industry.addressEn, industry.addressNp),
              ),
            const SizedBox(height: 8),

            // Contact Number
            if (industry.contactNumber.isNotEmpty)
              _buildDetailRow(
                Icons.phone,
                'Contact No',
                industry.contactNumber,
              ),
            const SizedBox(height: 8),

            // Proprietor
            if ((industry.proprietorNameEn?.isNotEmpty ?? false) ||
                (industry.proprietorNameNp?.isNotEmpty ?? false))
              _buildDetailRow(
                Icons.person,
                'Proprietor',
                _joinValues(industry.proprietorNameEn, industry.proprietorNameNp),
              ),

            // Divider + Actions
            if (hasActions) ...[
              const SizedBox(height: 4),
              const Divider(height: 4, thickness: 0.5),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onRecommend != null)
                    OutlinedButton(
                      onPressed: onRecommend,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: appColors.formsubmit,
                        side: BorderSide(color: appColors.formsubmit),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(0, 30),
                      ),
                      child: const Text('Recommendation', style: TextStyle(fontSize: 12)),
                    ),
                  if (onLicense != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: onLicense,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: appColors.blue_blue_dark,
                        side: BorderSide(color: appColors.blue_blue_dark),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(0, 30),
                      ),
                      child: const Text('New License', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  if (onEdit != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: onEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(0, 30),
                      ),
                      child: const Text('Edit', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toUpperCase()) {
      case 'DRAFT':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        displayText = 'Draft';
        break;
      case 'COMPLETED':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        displayText = 'Completed';
        break;
      case 'PENDING':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        displayText = 'Pending';
        break;
      case 'REJECTED':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        displayText = 'Rejected';
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _joinValues(String? en, String? np) {
    if ((en?.isEmpty ?? true) && (np?.isEmpty ?? true)) return '';
    if ((en?.isEmpty ?? true)) return np!;
    if ((np?.isEmpty ?? true)) return en!;
    return '$en • $np';
  }
}
