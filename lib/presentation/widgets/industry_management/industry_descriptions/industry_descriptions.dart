import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../domain/models/industry/industry_optdetails.dart';
import '../../../../domain/repositories/industry/industry_view_repository.dart';
import '../../../../utils/colors/color.dart';

class IndustryDescriptionForm extends StatefulWidget {
  final String industryId;
  final Function(bool) onValidationChanged;
  final VoidCallback onSubmitted;

  const IndustryDescriptionForm({
    Key? key,
    required this.industryId,
    required this.onValidationChanged,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  IndustryDescriptionFormState createState() => IndustryDescriptionFormState();
}

class IndustryDescriptionFormState extends State<IndustryDescriptionForm> {
  final TextEditingController _machineryController = TextEditingController();
  final TextEditingController _rawMaterialsController = TextEditingController();
  final TextEditingController _cleanManagementController = TextEditingController();
  final TextEditingController _technicalSkillsController = TextEditingController();

  bool _isSubmitting = false;
  bool _isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final IndustryViewRepository _repository = IndustryViewRepository();

  static const int maxCharacters = 50000;
  int _machineryChars = 0;
  int _rawMaterialsChars = 0;
  int _cleanManagementChars = 0;
  int _technicalSkillsChars = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    _machineryController.addListener(() {
      setState(() {
        _machineryChars = _machineryController.text.length;
      });
      _validateForm();
    });

    _rawMaterialsController.addListener(() {
      setState(() {
        _rawMaterialsChars = _rawMaterialsController.text.length;
      });
      _validateForm();
    });

    _cleanManagementController.addListener(() {
      setState(() {
        _cleanManagementChars = _cleanManagementController.text.length;
      });
      _validateForm();
    });

    _technicalSkillsController.addListener(() {
      setState(() {
        _technicalSkillsChars = _technicalSkillsController.text.length;
      });
      _validateForm();
    });
  }

  @override
  void dispose() {
    _machineryController.dispose();
    _rawMaterialsController.dispose();
    _cleanManagementController.dispose();
    _technicalSkillsController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    await _submitForm();
  }

  String _stripHtml(String htmlText) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '').trim();
  }

  Future<void> _loadInitialData() async {
    try {
      final data = await _repository.getOperationalInfo(widget.industryId);

      setState(() {
        _machineryController.text = _stripHtml(data.machineryDetails ?? '');
        _rawMaterialsController.text = _stripHtml(data.rawMaterialsDetails ?? '');
        _cleanManagementController.text = _stripHtml(data.cleanManagement ?? '');
        _technicalSkillsController.text = _stripHtml(data.technicalSkills ?? '');

        _machineryChars = _machineryController.text.length;
        _rawMaterialsChars = _rawMaterialsController.text.length;
        _cleanManagementChars = _cleanManagementController.text.length;
        _technicalSkillsChars = _technicalSkillsController.text.length;
      });

      _validateForm();

    } catch (e) {
      _showErrorSnackbar('Error loading operational data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _validateForm() {
    final isValid =
        _machineryController.text.isNotEmpty &&
            _rawMaterialsController.text.isNotEmpty &&
            _cleanManagementController.text.isNotEmpty &&
            _technicalSkillsController.text.isNotEmpty;

    widget.onValidationChanged(isValid);
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final operationalInfo = IndustryOperationalInfo(
        machineryDetails: _machineryController.text.trim(),
        rawMaterialsDetails: _rawMaterialsController.text.trim(),
        cleanManagement: _cleanManagementController.text.trim(),
        technicalSkills: _technicalSkillsController.text.trim(),
      );

      await _repository.updateOperationalInfo(widget.industryId, operationalInfo);
      widget.onSubmitted();

    } catch (e) {
      _showErrorSnackbar('Failed to save operational data: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, int currentChars, {bool isRequired = true}) {
    return InputDecoration(
      labelText: isRequired ? '$label*' : label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: appColors.text_field, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      errorStyle: TextStyle(color: Colors.red[700]),
      suffixText: '$currentChars/$maxCharacters',
      suffixStyle: TextStyle(
        color: currentChars > maxCharacters ? Colors.red : Colors.grey,
        fontSize: 12,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    required int currentChars,
    int maxLines = 3,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: _buildInputDecoration('Enter details', currentChars),
          validator: validator,
          maxLines: maxLines,
          maxLength: maxCharacters,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildShimmerField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      height: 100,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (_isLoading)
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Column(
                  children: [
                    _buildShimmerField(),
                    const SizedBox(height: 16),
                    _buildShimmerField(),
                    const SizedBox(height: 16),
                    _buildShimmerField(),
                    const SizedBox(height: 16),
                    _buildShimmerField(),
                  ],
                ),
              )
            else ...[
              _buildTextFormField(
                controller: _machineryController,
                label: 'Machinery Details',
                currentChars: _machineryChars,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Machinery details are required';
                  }
                  if (value!.length > maxCharacters) {
                    return 'Exceeds maximum character limit';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _rawMaterialsController,
                label: 'Raw Materials Details',
                currentChars: _rawMaterialsChars,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Raw materials details are required';
                  }
                  if (value!.length > maxCharacters) {
                    return 'Exceeds maximum character limit';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _cleanManagementController,
                label: 'Clean Management',
                currentChars: _cleanManagementChars,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Clean management details are required';
                  }
                  if (value!.length > maxCharacters) {
                    return 'Exceeds maximum character limit';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _technicalSkillsController,
                label: 'Technical Skills',
                currentChars: _technicalSkillsChars,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Technical skills details are required';
                  }
                  if (value!.length > maxCharacters) {
                    return 'Exceeds maximum character limit';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}