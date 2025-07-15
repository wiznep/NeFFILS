import 'package:flutter/material.dart';

import '../../../../utils/colors/color.dart';

class NewlicenseResponsiblePersonForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onChanged;
  final Function(bool) onValidationChanged;

  const NewlicenseResponsiblePersonForm({
    Key? key,
    required this.initialData,
    required this.onChanged,
    required this.onValidationChanged,
  }) : super(key: key);

  @override
  State<NewlicenseResponsiblePersonForm> createState() => _newlicenseResponsiblePersonform();
}

class _newlicenseResponsiblePersonform extends State<NewlicenseResponsiblePersonForm> {
  final Map<String, TextEditingController> controllers = {};

  final List<String> dropdownFields = [
    'industryType',
    'ownProperty',
    'industryCapital',
    'country',
    'province',
    'district',
    'municipality',
    'wardNo',
  ];

  final Map<String, String> fieldLabels = {
    'industryNameNepali': 'Industry Name in Nepali (उद्योगको नाम - नेपाली)',
    'industryNameEnglish': 'Industry Name in English',
    'industryContactNumber': 'Industry Contact Number',
    'industryType': 'Industry Type',
    'ownProperty': 'Own Property?',
    'industryCapital': 'Industry Capital',
    'totalProperty': 'Total Property',
    'industryCapacity': 'Industry Capacity',
    'marketsize': 'Marketsize',
    'numberOfEmployees': 'Number of Employees',
    'intendedProducts': 'Intended Products to be Produced',
    'country': 'Country (देश)',
    'province': 'Province',
    'district': 'District',
    'municipality': 'Municipality',
    'wardNo': 'Ward No.',
    'houseNo': 'House No.',
    'gPlusCode': 'G-PLUS Code',
    'nearestLandmark': 'Nearest Landmark',
  };

  @override
  void initState() {
    super.initState();
    for (final key in fieldLabels.keys) {
      controllers[key] = TextEditingController(text: widget.initialData[key] ?? '');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidationChanged(true);
    });
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: appColors.white_black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: appColors.formsubmit, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: appColors.dimwhite, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required Widget field,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: '* ',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _buildTextField(String key) {
    return _buildLabeledField(
      label: fieldLabels[key] ?? key,
      field: TextFormField(
        controller: controllers[key],
        onChanged: (value) {
          widget.onChanged({key: value});
        },
        decoration: _inputDecoration(hintText: 'Enter ${fieldLabels[key]?.toLowerCase() ?? key}'),
      ),
    );
  }

  Widget _buildDropdownField(String key) {
    return _buildLabeledField(
      label: fieldLabels[key] ?? key,
      field: DropdownButtonFormField<String>(
        value: controllers[key]!.text.isNotEmpty ? controllers[key]!.text : null,
        decoration: _inputDecoration(hintText: 'Select ${fieldLabels[key]?.toLowerCase()}'),
        items: ['Option 1', 'Option 2', 'Option 3']
            .map((option) => DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
        onChanged: (value) {
          controllers[key]!.text = value ?? '';
          widget.onChanged({key: value});
        },
      ),
    );
  }

  Widget _buildField(String key) {
    return dropdownFields.contains(key)
        ? _buildDropdownField(key)
        : _buildTextField(key);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildField('industryNameNepali'),
          const SizedBox(height: 12),
          _buildField('industryNameEnglish'),
          const SizedBox(height: 12),
          _buildField('industryContactNumber'),
          const SizedBox(height: 12),
          _buildField('industryType'),
          const SizedBox(height: 12),
          _buildField('ownProperty'),
          const SizedBox(height: 12),
          _buildField('industryCapital'),
          const SizedBox(height: 12),
          _buildField('totalProperty'),
          const SizedBox(height: 12),
          _buildField('industryCapacity'),
          const SizedBox(height: 12),
          _buildField('marketsize'),
          const SizedBox(height: 12),
          _buildField('numberOfEmployees'),
          const SizedBox(height: 12),
          _buildField('intendedProducts'),
          const SizedBox(height: 24),
          _buildSectionHeader('Industry Address (उद्योगको ठेगाना)'),
          const SizedBox(height: 12),
          _buildField('country'),
          const SizedBox(height: 12),
          _buildField('province'),
          const SizedBox(height: 12),
          _buildField('district'),
          const SizedBox(height: 12),
          _buildField('municipality'),
          const SizedBox(height: 12),
          _buildField('wardNo'),
          const SizedBox(height: 12),
          _buildField('houseNo'),
          const SizedBox(height: 12),
          _buildField('gPlusCode'),
          const SizedBox(height: 12),
          _buildField('nearestLandmark'),
        ],
      ),
    );
  }
}
