import 'package:flutter/material.dart';
import 'package:neffils/utils/colors/color.dart';
import 'package:neffils/domain/models/industry/industry_view_model.dart';
import 'package:neffils/presentation/widgets/industry_management/form_buttons.dart';
import 'package:neffils/presentation/widgets/industry_management/form_progress_bar.dart';
import 'package:neffils/presentation/widgets/recommendation/form/recommendation_documents/documents_form.dart';
import 'package:neffils/presentation/widgets/recommendation/form/office_selection_form.dart';

import '../../../../widgets/recommendation/form/recommendation_documents/documents_form_controller.dart';

class AddRecommendationScreen extends StatefulWidget {
  final IndustryView? selectedIndustry;

  const AddRecommendationScreen({
    Key? key,
    this.selectedIndustry,
  }) : super(key: key);

  @override
  _AddRecommendationScreenState createState() => _AddRecommendationScreenState();
}

class _AddRecommendationScreenState extends State<AddRecommendationScreen> {
  int _currentStep = 1;
  final int _totalSteps = 2;
  final Map<String, dynamic> _formData = {};
  bool _isNextEnabled = false;
  late DocumentsFormController _documentsController;
  bool _isInitialized = false;

  final List<String> _stepTitles = [
    'Documents',
    'Office Selection & Payment Details',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _initializeController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    });
  }

  void _initializeFormData() {
    if (widget.selectedIndustry != null) {
      _formData.addAll({
        'industry_id': widget.selectedIndustry!.id,
        'industry_name': widget.selectedIndustry!.displayName,
      });
    }
  }

  void _initializeController() {
    _documentsController = DocumentsFormController(
      onChanged: (data) => _safeUpdateFormData(data),
      onValidationChanged: (enabled) => _safeSetNextEnabled(enabled),
      initialData: _formData,
      isIndustryPreselected: widget.selectedIndustry != null,
    );
    _documentsController.loadInitialData();
  }

  void _safeUpdateFormData(Map<String, dynamic> data) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _formData.addAll(data));
      }
    });
  }

  void _safeSetNextEnabled(bool enabled) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isNextEnabled != enabled) {
        setState(() => _isNextEnabled = enabled);
      }
    });
  }

  Future<void> _nextStep() async {
    if (_currentStep == 1) {
      try {
        await _documentsController.submitDocuments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documents submitted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
        return;
      }
    }

    if (_currentStep < _totalSteps && mounted) {
      setState(() {
        _currentStep++;
        _isNextEnabled = false;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 1 && mounted) {
      setState(() {
        _currentStep--;
        _isNextEnabled = true;
      });
    }
  }

  void _submitForm() {
    debugPrint('Form submitted: $_formData');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: appColors.formsubmit,
        foregroundColor: Colors.white,
        title: const Text('Apply for Recommendation'),
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
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildStepContent(),
              ),
            ),
            const SizedBox(height: 16),
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
        return RecommendationDocumentsForm(
          key: ValueKey(_formData['industry_id']),
          initialData: _formData,
          onChanged: _safeUpdateFormData,
          onValidationChanged: _safeSetNextEnabled,
          isIndustryPreselected: widget.selectedIndustry != null,
        );
      case 2:
        return OfficeSelectionForm(
          initialData: _formData,
          onChanged: _safeUpdateFormData,
          onValidationChanged: _safeSetNextEnabled,
        );
      default:
        return Container();
    }
  }

  @override
  void dispose() {
    _documentsController.dispose();
    super.dispose();
  }
}