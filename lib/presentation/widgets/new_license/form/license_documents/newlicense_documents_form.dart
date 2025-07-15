import 'package:flutter/material.dart';
import 'package:neffils/utils/colors/color.dart';
import 'package:neffils/domain/models/industry/industry_view_model.dart';
import 'license_form_controller.dart';

class LicenseDocumentsForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onChanged;
  final Function(bool) onValidationChanged;
  final bool isIndustryPreselected;

  const LicenseDocumentsForm({
    Key? key,
    required this.initialData,
    required this.onChanged,
    required this.onValidationChanged,
    required this.isIndustryPreselected,
  }) : super(key: key);

  @override
  State<LicenseDocumentsForm> createState() => _LicenseDocumentsFormState();
}

class _LicenseDocumentsFormState extends State<LicenseDocumentsForm> {
  late LicenseDocumentsFormController _formController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formController = LicenseDocumentsFormController(
      onValidationChanged: widget.onValidationChanged,
      onChanged: widget.onChanged,
      initialData: widget.initialData,
      isIndustryPreselected: widget.isIndustryPreselected,
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await _formController.loadInitialData();
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
    List<String> options = const ['Yes', 'No'],
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? "$label *" : label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isRequired ? Colors.red : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (val) {
                onChanged(val);
                setState(() {});
              },
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? "$label *" : label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isRequired ? Colors.red : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          onChanged: (value) => _formController.updateData(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDocumentSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        ...children,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _formController.buildIndustrySelection(),
          _formController.buildDftqcOfficeSelection(),

          const Divider(height: 32, thickness: 1),

          _buildSectionTitle('Company Information'),
          _buildDropdown(
            label: 'Is Pvt. Ltd.?',
            value: _formController.isPvtLtd,
            onChanged: (val) {
              _formController.isPvtLtd = val;
              _formController.updateData();
            },
          ),

          _buildDropdown(
            label: 'Is Branch?',
            value: _formController.isBranch,
            onChanged: (val) {
              _formController.isBranch = val;
              _formController.updateData();
            },
          ),

          _buildDropdown(
            label: 'Is Brand Registered?',
            value: _formController.isBrandRegistered,
            onChanged: (val) {
              _formController.isBrandRegistered = val;
              _formController.updateData();
            },
          ),

          _buildTextField(
            label: 'Industry Registration Number',
            controller: _formController.registrationNumberController,
            isRequired: true,
          ),

          _buildTextField(
            label: 'PAN / VAT Number',
            controller: _formController.panVatController,
            isRequired: true,
          ),

          const Divider(height: 32, thickness: 1),

          _buildDocumentSection(
            'Required Documents *',
            _formController.buildRequiredDocuments(),
          ),

          if (_formController.isPvtLtd == 'Yes' || _formController.isBrandRegistered == 'Yes')
            _buildDocumentSection(
              'Additional Required Documents',
              [
                if (_formController.isPvtLtd == 'Yes')
                  ..._formController.buildPvtLtdDocuments(),
                if (_formController.isBrandRegistered == 'Yes')
                  ..._formController.buildBrandDocuments(),
              ],
            ),

          _buildDocumentSection(
            'Optional Documents',
            _formController.buildOptionalDocuments(),
          ),

          _buildDocumentSection(
            'Additional Documents',
            [
              ..._formController.buildAdditionalDocuments(),
              const SizedBox(height: 16),
              _formController.buildAddDocumentButton(context),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }
}