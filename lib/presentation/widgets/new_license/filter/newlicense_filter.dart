import 'package:flutter/material.dart';
import 'package:neffils/utils/colors/color.dart';

class LicenseFilter extends StatefulWidget {
  final String? selectedStatus;
  final String searchQuery;
  final Function(String?) onStatusChanged;
  final Function(String) onSearchChanged;
  final Function() onResetFilters;
  final Function() onApplyFilters;

  const LicenseFilter({
    Key? key,
    required this.selectedStatus,
    required this.searchQuery,
    required this.onStatusChanged,
    required this.onSearchChanged,
    required this.onResetFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<LicenseFilter> createState() => _LicenseFilterState();
}

class _LicenseFilterState extends State<LicenseFilter> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Licenses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search Field
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: appColors.formsubmit),
              hintText: 'Search by name or application number',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: appColors.formsubmit, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: Colors.grey.shade600),
                onPressed: () {
                  _searchController.clear();
                  widget.onSearchChanged('');
                },
              )
                  : null,
            ),
            onChanged: widget.onSearchChanged,
          ),
          const SizedBox(height: 24),

          // Status Filter
          _buildFilterSection(
            title: 'License Status',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.grey.shade100,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.selectedStatus,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: appColors.formsubmit),
                  iconSize: 28,
                  elevation: 2,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  hint: Text('Select Status',
                      style: TextStyle(color: Colors.grey.shade600)),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    DropdownMenuItem(
                      value: 'verified',
                      child: Text('Verified'),
                    ),
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Text('Rejected'),
                    ),
                  ],
                  onChanged: widget.onStatusChanged,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onResetFilters();
                    _searchController.clear();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: appColors.formsubmit, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'RESET',
                    style: TextStyle(
                      color: appColors.formsubmit,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.formsubmit,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'APPLY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}