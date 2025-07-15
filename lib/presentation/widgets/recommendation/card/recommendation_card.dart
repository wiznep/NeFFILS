import 'package:flutter/material.dart';
import '../../../../domain/models/recommendation/recommendation_view_model.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback? onView;

  const RecommendationCard({
    Key? key,
    required this.recommendation,
    this.onView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            // Title + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application: ${recommendation.applicationNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                _buildStatusBadge(recommendation.status),
              ],
            ),
            const SizedBox(height: 12),

            // Industry Info
            _buildDetailRow(
              Icons.business,
              'Industry',
              '${recommendation.industryNameEn} • ${recommendation.industryNameNp}',
            ),
            const SizedBox(height: 8),

            // Address
            _buildDetailRow(
              Icons.location_on,
              'Address',
              '${recommendation.industryAddressEn} • ${recommendation.industryAddressNp}',
            ),
            const SizedBox(height: 8),

            // DFTQC Office
            _buildDetailRow(
              Icons.assessment,
              'DFTQC Office',
              '${recommendation.dftqcOfficeNameEn} • ${recommendation.dftqcOfficeNameNp}',
            ),
            const SizedBox(height: 8),

            // Recommendation Office
            _buildDetailRow(
              Icons.work,
              'Recommendation Office',
              '${recommendation.recommendationOfficeNameEn} • ${recommendation.recommendationOfficeNameNp}',
            ),
            const SizedBox(height: 12),

            // Footer with Date and Payment
            const Divider(height: 16, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      recommendation.createdDateNp,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      recommendation.isPaymentVerified ? Icons.verified : Icons.payment,
                      size: 16,
                      color: recommendation.isPaymentVerified ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recommendation.isPaymentVerified ? 'Verified' : 'Not Verified',
                      style: TextStyle(
                        fontSize: 12,
                        color: recommendation.isPaymentVerified ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // View Button (no Edit button anymore)
            if (onView != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 30),
                    ),
                    onPressed: onView,
                    child: const Text('View', style: TextStyle(fontSize: 12)),
                  ),
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
      case 'PENDING':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        displayText = 'Pending';
        break;
      case 'APPROVED':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        displayText = 'Approved';
        break;
      case 'REJECTED':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        displayText = 'Rejected';
        break;
      case 'PROCESSING':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        displayText = 'Processing';
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

  Widget _buildDetailRow(IconData icon, String label, String text) {
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
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
