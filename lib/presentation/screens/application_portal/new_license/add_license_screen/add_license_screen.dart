import 'package:flutter/material.dart';
import 'package:neffils/domain/models/industry/industry_view_model.dart';
import 'package:neffils/presentation/widgets/new_license/form/newlicense_product_details_form.dart';
import 'package:neffils/presentation/widgets/new_license/form/newlicense_responsible_person_form.dart';

import '../../../../../utils/colors/color.dart';
import '../../../../widgets/industry_management/form_buttons.dart';
import '../../../../widgets/industry_management/form_progress_bar.dart';
import '../../../../widgets/new_license/form/license_documents/license_form_controller.dart';
import '../../../../widgets/new_license/form/license_documents/newlicense_documents_form.dart';

class addLicenseScreen extends StatefulWidget {
  final IndustryView? selectedIndustry;
  const addLicenseScreen({
    Key? key,
    this.selectedIndustry,
  }) : super(key: key);

  @override
  State<addLicenseScreen> createState() => _AddLicenseScreenState();
}

class _AddLicenseScreenState extends State<addLicenseScreen> {
  int _currentStep = 1;
  final int _totalSteps = 3;
  final Map<String, dynamic> _formData = {};
  bool _isNextEnabled = false;

  final List<String> _stepTitles = [
    'Documents',
    'Product Details',
    'Responsible Person',
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
        _isNextEnabled = false;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
        _isNextEnabled = true;
      });
    }
  }

  void _submitForm() {
    print('Form submitted: $_formData');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form submitted successfully')),
    );
  }

  void _updateFormData(Map<String, dynamic> data) {
    setState(() {
      _formData.addAll(data);
    });
  }

  void _setNextEnabled(bool enabled) {
    if (mounted) {
      setState(() {
        _isNextEnabled = enabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appColors.formsubmit,
        foregroundColor: Colors.white,
        title: const Text('New License',
            style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FormProgressBar(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              stepTitles: _stepTitles,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildStepContent(),
            ),
            const SizedBox(height: 24),
            FormButtons(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              isNextEnabled: _isNextEnabled,
              onBackPressed: _prevStep,
              onNextPressed: _nextStep,
              onSubmitPressed: _submitForm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return LicenseDocumentsForm(
          initialData: _formData,
          onChanged: _updateFormData,
          onValidationChanged: _setNextEnabled,
          isIndustryPreselected: widget.selectedIndustry != null,
        );

      case 2:
        return NewlicenseProductdetailsForm(
          initialData: _formData,
          onChanged: _updateFormData,
          onValidationChanged: _setNextEnabled,
        );

      case 3:
        return NewlicenseResponsiblePersonForm(
          initialData: _formData,
          onChanged: _updateFormData,
          onValidationChanged: _setNextEnabled,
        );
      default:
        return Container();
    }
  }
}