import 'package:flutter/material.dart';
import 'package:neffils/domain/models/industry/industry_basic_info.dart';
import 'package:neffils/presentation/screens/application_portal/industry_management/add_industry_management/added_industry_success.dart';
import 'package:neffils/presentation/widgets/industry_management/additional_details/additional_info_form.dart';
import 'package:neffils/presentation/widgets/industry_management/shareholder/shareholders_controller.dart';
import '../../../../../utils/colors/color.dart';
import '../../../../widgets/industry_management/form_buttons.dart';
import '../../../../widgets/industry_management/form_progress_bar.dart';
import '../../../../widgets/industry_management/industry_basic_info/industry_info_form/industry_info_form.dart';
import '../../../../widgets/industry_management/industry_descriptions/industry_descriptions.dart';
import '../../../../../domain/repositories/industry/industry_view_repository.dart';
import '../../../../widgets/industry_management/industry_proprietor/industry_proprietor_view.dart';

class AddIndustryManagementScreen extends StatefulWidget {
  final String? industryId;

  const AddIndustryManagementScreen({Key? key, this.industryId})
      : super(key: key);

  @override
  State<AddIndustryManagementScreen> createState() =>
      _AddIndustryManagementScreenState();
}

class _AddIndustryManagementScreenState
    extends State<AddIndustryManagementScreen> {
  final GlobalKey<IndustryInfoFormState> _basicFormKey =
      GlobalKey<IndustryInfoFormState>();
  final GlobalKey<IndustryDescriptionFormState> _descriptionFormKey =
      GlobalKey<IndustryDescriptionFormState>();
  final GlobalKey<ShareholdersControllerState> _shareholdersKey =
      GlobalKey<ShareholdersControllerState>();
  final GlobalKey<ProprietorViewState> _proprietorKey =
      GlobalKey<ProprietorViewState>();

  int _currentStep = 1;
  final int _totalSteps = 5;
  bool _isNextEnabled = false;
  bool _isSubmitting = false;
  String? _industryId;
  IndustryBasicInfo? _initialInfo;
  bool _isLoading = false;

  final List<String> _stepTitles = [
    'Basic Info (उद्योगको जानकारी)',
    'Descriptions (उद्योगको विवरण)',
    'Board of Directors (सञ्चालक(हरू) विवरण)',
    'Proprietor (उद्योगपतिको विवरण)',
    'Additional (अतिरिक्त जानकारी)',
  ];

  get selectedShareholder => null;

  @override
  void initState() {
    super.initState();
    if (widget.industryId != null) {
      _industryId = widget.industryId;
      _loadIndustryBasicInfo();
    } else {
      _initialInfo = IndustryBasicInfo.empty();
    }
  }

  Future<void> _loadIndustryBasicInfo() async {
    if (_industryId == null) return;

    setState(() => _isLoading = true);
    try {
      final repository = IndustryViewRepository();
      final info = await repository.getBasicIndustryInfo(_industryId!);
      setState(() => _initialInfo = info);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading industry: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onValidationChanged(bool valid) {
    if (mounted) {
      setState(() => _isNextEnabled = valid);
    }
  }

  void _onBasicInfoSubmitted(String industryId) {
    if (mounted) {
      setState(() {
        _industryId = industryId;
        _isSubmitting = false;
        _currentStep++;
        _isNextEnabled = false;
      });
    }
  }

  void _nextStep() {
    switch (_currentStep) {
      case 1:
        _basicFormKey.currentState?.submit();
        break;
      case 2:
        _descriptionFormKey.currentState?.submitForm();
        break;
      case 3:
        _shareholdersKey.currentState?.submit();
        break;
      case 4:
        _proprietorKey.currentState?.submit();
        break;
      default:
        if (_currentStep < _totalSteps) {
          setState(() {
            _currentStep++;
            _isNextEnabled = false;
          });
        }
    }
    setState(() => _isSubmitting = true);
  }

  void _prevStep() {
    if (_currentStep > 1 && mounted) {
      if (_currentStep == 2) {
        _loadIndustryBasicInfo().then((_) {
          if (mounted) {
            setState(() {
              _currentStep--;
              _isNextEnabled = true;
            });
          }
        });
      } else {
        setState(() {
          _currentStep--;
          _isNextEnabled = true;
        });
      }
    }
  }

  Widget _buildStepContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_currentStep) {
      case 1:
        return IndustryInfoForm(
          key: _basicFormKey,
          industryId: _industryId,
          initialInfo: _initialInfo ?? IndustryBasicInfo.empty(),
          onValidationChanged: _onValidationChanged,
          onSubmitted: _onBasicInfoSubmitted,
        );
      case 2:
        return IndustryDescriptionForm(
          key: _descriptionFormKey,
          industryId: _industryId!,
          onValidationChanged: _onValidationChanged,
          onSubmitted: () {
            if (mounted) {
              setState(() {
                _isSubmitting = false;
                _currentStep++;
                _isNextEnabled = false;
              });
            }
          },
        );
      case 3:
        return ShareholdersController(
          key: _shareholdersKey,
          industryId: _industryId!,
          onValidationChanged: _onValidationChanged,
          onSubmitted: () {
            if (mounted) {
              setState(() {
                _isSubmitting = false;
                _currentStep++;
                _isNextEnabled = false;
              });
            }
          },
        );
      case 4:
        return ProprietorView(
          industryId: _industryId!,
          key: _proprietorKey,
          onValidationChanged: _onValidationChanged,
          shareholder: selectedShareholder,
          onSubmitted: () {
            if (mounted) {
              setState(() {
                _isSubmitting = false;
                _currentStep++;
                _isNextEnabled = false;
              });
            }
          },
        );
      case 5:
        return AdditionalInfoForm();

      default:
        return const SizedBox();
    }
  }

  void _handleFormCompletion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const IndustryAddedSuccess()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          widget.industryId != null ? 'Edit Industry' : 'Add Industry',
        ),
        backgroundColor: appColors.formsubmit,
        centerTitle: false,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FormProgressBar(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              stepTitles: _stepTitles,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  child: _buildStepContent(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FormButtons(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              isNextEnabled: _isNextEnabled,
              onBackPressed: _prevStep,
              onNextPressed: _nextStep,
              onSubmitPressed: _handleFormCompletion,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
