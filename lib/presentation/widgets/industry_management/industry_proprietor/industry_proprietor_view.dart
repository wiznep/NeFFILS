import 'package:flutter/material.dart';
import 'package:neffils/domain/models/industry/industry_proprietor_model.dart';
import 'package:neffils/domain/models/industry/industry_shareholder.dart';
import 'package:neffils/domain/repositories/industry/industry_proprietor_repository.dart';
import 'package:neffils/utils/colors/color.dart';

import 'industry_proprietor_form.dart';
import 'industry_proprietor_shimmer.dart';

class ProprietorView extends StatefulWidget {
  final String industryId;
  final Function(bool) onValidationChanged;
  final VoidCallback onSubmitted;
  final Shareholder? shareholder;

  const ProprietorView({
    Key? key,
    required this.industryId,
    required this.onValidationChanged,
    required this.onSubmitted,
    this.shareholder,
  }) : super(key: key);

  @override
  State<ProprietorView> createState() => ProprietorViewState();
}

class ProprietorViewState extends State<ProprietorView> {
  late ProprietorFormController _formController;
  bool _isLoading = true;
  bool _submitting = false;
  Proprietor? _existingProprietor;
  List<Shareholder> _shareholders = [];
  Shareholder? _selectedShareholder;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _formController = ProprietorFormController(
      onValidationChanged: widget.onValidationChanged,
      selectedShareholder: widget.shareholder,
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final repository = IndustryProprietorRepository();
      _shareholders = await repository.getShareholders(widget.industryId);
      _existingProprietor = await repository.getProprietor(widget.industryId);

      if (_existingProprietor != null && _existingProprietor!.shareholder.isNotEmpty) {
        _selectedShareholder = _shareholders.firstWhere(
              (sh) => sh.id == _existingProprietor!.shareholder,
          orElse: () => widget.shareholder ?? _shareholders.first,
        );
      } else {
        _selectedShareholder = widget.shareholder;
      }

      _formController = ProprietorFormController(
        onValidationChanged: widget.onValidationChanged,
        initialData: _existingProprietor,
        selectedShareholder: _selectedShareholder,
        shareholders: _shareholders,
      );

      // Load dropdown options with proper initialization for both addresses
      await _formController.loadDropdownOptions(
        initialProvincePer: _existingProprietor?.provincePer,
        initialDistrictPer: _existingProprietor?.districtPer,
        initialProvinceTem: _existingProprietor?.provinceTem,
        initialDistrictTem: _existingProprietor?.districtTem,
      );
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> submit() async {
    if (!_formController.validateForm()) {
      return false;
    }

    setState(() => _submitting = true);
    try {
      final repository = IndustryProprietorRepository();
      final success = await repository.saveProprietor(
        industryId: widget.industryId,
        proprietor: _formController.collectFormData(widget.industryId),
        signatureFile: _formController.getSignatureFile(),
      );

      if (success) {
        widget.onSubmitted();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error submitting proprietor: $e');
      return false;
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: appColors.white_black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ProprietorShimmer();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Proprietor Information'),
          _formController.buildShareholderDropdown(
            onChanged: (Shareholder? value) {
              if (value == null) return;
              setState(() {
                _selectedShareholder = value;
                _formController.updateSelectedShareholder(value);
              });
              widget.onValidationChanged(_formController.validateForm());
            },
          ),
          const SizedBox(height: 16),
          _formController.buildTextField('phone_number'),
          const SizedBox(height: 16),
          _formController.buildTextField('email'),
          const SizedBox(height: 16),
          _formController.buildSignatureSection(),

          _buildSectionHeader('Permanent Address'),
          _formController.buildAddressSection(isTemporary: false),

          _buildSectionHeader('Temporary Address'),
          _formController.buildSameAddressCheckbox(onChanged: (val) {
            setState(() {
              _formController.isSameAsPermanent = val;
              if (val) {
                _formController.copyPermanentToTemporary();
              } else {
                _formController.clearTemporaryAddress();
              }
              widget.onValidationChanged(_formController.validateForm());
            });
          }),
          if (!_formController.isSameAsPermanent)
            _formController.buildAddressSection(isTemporary: true),

          _buildSectionHeader('Family Details'),
          _formController.buildTextField('grandfather_name_en'),
          const SizedBox(height: 16),
          _formController.buildTextField('grandfather_name_np'),
          const SizedBox(height: 16),
          _formController.buildTextField('father_name_en'),
          const SizedBox(height: 16),
          _formController.buildTextField('father_name_np'),
          const SizedBox(height: 16),
          _formController.buildTextField('mother_name_en'),
          const SizedBox(height: 16),
          _formController.buildTextField('mother_name_np'),
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