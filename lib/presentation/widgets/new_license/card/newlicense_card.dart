import 'package:flutter/material.dart';
import 'package:neffils/domain/models/license/license_view_model.dart';

class LicenseCard extends StatelessWidget {
  final LicenseViewModel licenseViewModel;
  final VoidCallback? onView;
  final VoidCallback? onEdit;

  const LicenseCard({
    Key? key,
    required this.licenseViewModel,
    this.onView, this.onEdit,
  }) : super(key : key);
  @override
  Widget build(BuildContext context) {
    return Card(
      color : Colors.white,
      elevation : 3,
      shape : RoundedRectangleBorder(
        borderRadius : BorderRadius.circular(12),
        side : BorderSide(color : Colors.grey.shade200, width : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                 'Application No: ${licenseViewModel.applicationnumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                _buildStatusBadge(licenseViewModel.status),
              ],
            ),
            const SizedBox(height: 12),

            //industry name
            _buildDetailRow(
              Icons.business,
              'Industry Name',
              '${licenseViewModel.industrynameen} • ${licenseViewModel.industrynamenp}',
            ),
            const SizedBox(height: 8),

            //dftqc office

            _buildDetailRow(
              Icons.local_post_office,
              'DFTQC Office',
              '${licenseViewModel.dftqctypeen} • ${licenseViewModel.dftqctypenp}',
            ),
            const SizedBox(height: 12),

            //footer with view and edit buttons

            const Divider(height: 16, thickness: 0.5,),
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
                    onPressed: onView, child: const Text('View', style: TextStyle(fontSize: 12),))
              ]
            ),
            if (onEdit != null)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 30),
                ),
                onPressed: onEdit,
                child: const Text('Edit', style: TextStyle(fontSize: 12)),
              ),
          ],
        )
      )
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