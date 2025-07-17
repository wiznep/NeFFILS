import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
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
  final HtmlEditorController _machineryHtmlController = HtmlEditorController();
  final HtmlEditorController _rawMaterialsHtmlController =
      HtmlEditorController();
  final HtmlEditorController _cleanManagementHtmlController =
      HtmlEditorController();
  final HtmlEditorController _technicalSkillsHtmlController =
      HtmlEditorController();

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
  }

  @override
  void dispose() {
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
      // Set initial HTML values for editors
      _machineryHtmlController.setText(data.machineryDetails);
      _rawMaterialsHtmlController.setText(data.rawMaterialsDetails);
      _cleanManagementHtmlController.setText(data.cleanManagement);
      _technicalSkillsHtmlController.setText(data.technicalSkills);
      setState(() {
        _machineryChars = _stripHtml(data.machineryDetails).length;
        _rawMaterialsChars = _stripHtml(data.rawMaterialsDetails).length;
        _cleanManagementChars = _stripHtml(data.cleanManagement).length;
        _technicalSkillsChars = _stripHtml(data.technicalSkills).length;
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
    Future.wait([
      _machineryHtmlController.getText(),
      _rawMaterialsHtmlController.getText(),
      _cleanManagementHtmlController.getText(),
      _technicalSkillsHtmlController.getText(),
    ]).then((values) {
      final isValid = values.every((text) => _stripHtml(text).isNotEmpty);
      widget.onValidationChanged(isValid);
    });
  }

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);
    try {
      final machineryDetails = await _machineryHtmlController.getText();
      final rawMaterialsDetails = await _rawMaterialsHtmlController.getText();
      final cleanManagement = await _cleanManagementHtmlController.getText();
      final technicalSkills = await _technicalSkillsHtmlController.getText();
      final operationalInfo = IndustryOperationalInfo(
        machineryDetails: machineryDetails,
        rawMaterialsDetails: rawMaterialsDetails,
        cleanManagement: cleanManagement,
        technicalSkills: technicalSkills,
      );
      await _repository.updateOperationalInfo(
          widget.industryId, operationalInfo);
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

  Widget _buildTextFormField({
    required HtmlEditorController controller,
    required String label,
    int currentChars = 0,
    // removed unused maxLines parameter
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
        HtmlEditor(
          controller: controller,
          htmlEditorOptions: HtmlEditorOptions(
            hint: 'Enter $label',
            shouldEnsureVisible: true,
          ),
          htmlToolbarOptions: HtmlToolbarOptions(
            defaultToolbarButtons: [
              FontButtons(),
              ColorButtons(),
              ListButtons(),
              ParagraphButtons(),
              InsertButtons(),
              OtherButtons(),
            ],
          ),
          otherOptions: OtherOptions(height: 200),
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
                controller: _machineryHtmlController,
                label: 'Machinery Details',
                currentChars: _machineryChars,
              ),
              _buildTextFormField(
                controller: _rawMaterialsHtmlController,
                label: 'Raw Materials Details',
                currentChars: _rawMaterialsChars,
              ),
              _buildTextFormField(
                controller: _cleanManagementHtmlController,
                label: 'Clean Management',
                currentChars: _cleanManagementChars,
              ),
              _buildTextFormField(
                controller: _technicalSkillsHtmlController,
                label: 'Technical Skills',
                currentChars: _technicalSkillsChars,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
