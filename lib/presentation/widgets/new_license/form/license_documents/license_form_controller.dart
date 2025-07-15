import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:neffils/domain/models/industry/industry_view_model.dart';
import 'package:neffils/domain/models/dftqc_office_model.dart';
import 'package:neffils/domain/repositories/industry/industry_view_repository.dart';
import 'package:neffils/domain/repositories/dftqc_office_repository.dart';

class LicenseDocumentsFormController {
  final Function(Map<String, dynamic>) onChanged;
  final Function(bool) onValidationChanged;
  final Map<String, dynamic> initialData;
  final bool isIndustryPreselected;

  String? selectedIndustry;
  String? selectedIndustryId;
  DftqcOffice? selectedDftqcOffice;
  String? isPvtLtd = 'No';
  String? isBranch = 'No';
  String? isBrandRegistered = 'No';

  final registrationNumberController = TextEditingController();
  final panVatController = TextEditingController();
  final additionalDocNameController = TextEditingController();

  final Map<String, PlatformFile?> documentFiles = {
    'industry_registration': null,
    'letter_of_administration': null,
    'company_regulation': null,
    'updated_share_cost': null,
    'brand_registration': null,
    'technical_proposal': null,
    'registration_form': null,
    'technical_details_scheme': null,
    'pan_vat_doc': null,
    'proposed_industry_layout': null,
    'trademark_registration': null,
  };

  final Map<String, PlatformFile?> additionalDocuments = {};
  final List<String> additionalDocumentNames = [];

  List<DftqcOffice> dftqcOffices = [];
  bool isLoadingOffices = false;
  List<IndustryView> industries = [];
  bool isLoadingIndustries = false;

  LicenseDocumentsFormController({
    required this.onChanged,
    required this.onValidationChanged,
    required this.initialData,
    required this.isIndustryPreselected,
  });

  Future<void> loadInitialData() async {
    await fetchDftqcOffices();

    if (!isIndustryPreselected) {
      await fetchIndustries();
    }

    if (initialData.isNotEmpty) {
      selectedIndustry = initialData['industry_name'];
      selectedIndustryId = initialData['industry_id'];

      // Find matching DFTQC office from loaded list
      if (initialData['dftqc_office_id'] != null) {
        selectedDftqcOffice = dftqcOffices.firstWhere(
              (office) => office.id == initialData['dftqc_office_id'],
          orElse: () => DftqcOffice(id: '', nameEn: '', nameNp: ''),
        );
      }

      isPvtLtd = initialData['is_pvt_ltd'] ?? 'No';
      isBranch = initialData['is_branch'] ?? 'No';
      isBrandRegistered = initialData['is_brand_registered'] ?? 'No';
      registrationNumberController.text = initialData['registration_number'] ?? '';
      panVatController.text = initialData['pan_vat'] ?? '';
    }

    updateData();
  }

  Future<void> fetchDftqcOffices() async {
    try {
      isLoadingOffices = true;
      final repository = DftqcOfficeRepository();
      dftqcOffices = await repository.fetchOffices();
    } catch (e) {
      debugPrint('Error fetching DFTQC offices: $e');
    } finally {
      isLoadingOffices = false;
    }
  }

  Future<void> fetchIndustries() async {
    try {
      isLoadingIndustries = true;
      final repository = IndustryViewRepository();
      industries = await repository.getAllIndustries();
      industries = industries.where((industry) => industry.canApplyForLicense).toList();
    } catch (e) {
      debugPrint('Error fetching industries: $e');
    } finally {
      isLoadingIndustries = false;
    }
  }

  void updateData() {
    final data = {
      'industry_id': selectedIndustryId,
      'industry_name': selectedIndustry,
      'dftqc_office_id': selectedDftqcOffice?.id,
      'dftqc_office_name': selectedDftqcOffice?.nameEn,
      'is_pvt_ltd': isPvtLtd,
      'is_branch': isBranch,
      'is_brand_registered': isBrandRegistered,
      'registration_number': registrationNumberController.text,
      'pan_vat': panVatController.text,
      'documents': documentFiles,
      'additional_documents': additionalDocuments,
      'additional_document_names': additionalDocumentNames,
    };
    onChanged(data);
    validateForm();
  }

  void validateForm() {
    bool isValid = true;

    if (selectedIndustry == null || selectedIndustry!.isEmpty) isValid = false;
    if (selectedDftqcOffice == null) isValid = false;
    if (registrationNumberController.text.isEmpty) isValid = false;
    if (panVatController.text.isEmpty) isValid = false;

    // Required documents validation
    final requiredDocs = [
      'industry_registration',
      'technical_proposal',
      'registration_form',
      'technical_details_scheme',
      'pan_vat_doc',
    ];

    for (var docKey in requiredDocs) {
      if (documentFiles[docKey] == null) {
        isValid = false;
        break;
      }
    }

    // Conditional documents validation
    if (isPvtLtd == 'Yes') {
      final pvtLtdDocs = [
        'letter_of_administration',
        'company_regulation',
        'updated_share_cost',
      ];

      for (var docKey in pvtLtdDocs) {
        if (documentFiles[docKey] == null) {
          isValid = false;
          break;
        }
      }
    }

    if (isBrandRegistered == 'Yes' && documentFiles['brand_registration'] == null) {
      isValid = false;
    }

    onValidationChanged(isValid);
  }

  List<Widget> buildRequiredDocuments() {
    return [
      _buildFileUploadField(
        label: 'Industry Registration Certificate',
        documentKey: 'industry_registration',
        maxSizeMB: 5,
      ),
      _buildFileUploadField(
        label: 'Technical Proposal',
        documentKey: 'technical_proposal',
        maxSizeMB: 20,
      ),
      _buildFileUploadField(
        label: 'Registration Form',
        documentKey: 'registration_form',
        maxSizeMB: 5,
      ),
      _buildFileUploadField(
        label: 'Technical Details Scheme',
        documentKey: 'technical_details_scheme',
        maxSizeMB: 20,
      ),
      _buildFileUploadField(
        label: 'PAN / VAT Document',
        documentKey: 'pan_vat_doc',
        maxSizeMB: 5,
      ),
    ];
  }

  List<Widget> buildPvtLtdDocuments() {
    return [
      _buildFileUploadField(
        label: 'Letter of Administration',
        documentKey: 'letter_of_administration',
        maxSizeMB: 5,
      ),
      _buildFileUploadField(
        label: 'Company Regulation',
        documentKey: 'company_regulation',
        maxSizeMB: 5,
      ),
      _buildFileUploadField(
        label: 'Updated Share Cost',
        documentKey: 'updated_share_cost',
        maxSizeMB: 5,
      ),
    ];
  }

  List<Widget> buildBrandDocuments() {
    return [
      _buildFileUploadField(
        label: 'Brand Registration Certificate',
        documentKey: 'brand_registration',
        maxSizeMB: 5,
      ),
    ];
  }

  List<Widget> buildOptionalDocuments() {
    return [
      _buildFileUploadField(
        label: 'Proposed Industry Layout (Optional)',
        documentKey: 'proposed_industry_layout',
        maxSizeMB: 20,
        isRequired: false,
      ),
      _buildFileUploadField(
        label: 'Trademark Registration (Optional)',
        documentKey: 'trademark_registration',
        maxSizeMB: 5,
        isRequired: false,
      ),
    ];
  }

  Widget _buildFileUploadField({
    required String label,
    required String documentKey,
    required int maxSizeMB,
    bool isRequired = true,
  }) {
    final file = documentFiles[documentKey];
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
        GestureDetector(
          onTap: () => pickFile(documentKey, maxSizeMB),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(Icons.upload_file, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    file?.name ?? 'Click to upload $label',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                if (file != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      documentFiles[documentKey] = null;
                      updateData();
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildAdditionalDocumentForm(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Additional Document'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: additionalDocNameController,
            decoration: const InputDecoration(
              labelText: 'Document Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
              );

              if (result != null && additionalDocNameController.text.isNotEmpty) {
                final file = result.files.first;
                final docName = additionalDocNameController.text;

                additionalDocuments[docName] = file;
                additionalDocumentNames.add(docName);
                additionalDocNameController.clear();

                updateData();
                Navigator.pop(context);
              }
            },
            child: const Text('Upload Document'),
          ),
        ],
      ),
    );
  }

  List<Widget> buildAdditionalDocuments() {
    return additionalDocumentNames.map((docName) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            docName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(Icons.insert_drive_file, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    additionalDocuments[docName]?.name ?? 'No file selected',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    additionalDocuments.remove(docName);
                    additionalDocumentNames.remove(docName);
                    updateData();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget buildAddDocumentButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => buildAdditionalDocumentForm(context),
        );
      },
      icon: const Icon(Icons.add, size: 18),
      label: const Text("Add Additional Document"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.blue.shade100),
        ),
      ),
    );
  }

  Widget buildIndustrySelection() {
    if (isIndustryPreselected) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Industry',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Text(
              selectedIndustry ?? 'No industry selected',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Industry *',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
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
              value: selectedIndustry,
              hint: isLoadingIndustries
                  ? const Text('Loading industries...')
                  : const Text('Select an industry'),
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  final selected = industries.firstWhere(
                        (industry) => industry.displayName == newValue,
                  );
                  selectedIndustry = newValue;
                  selectedIndustryId = selected.id;
                  updateData();
                }
              },
              items: industries.map<DropdownMenuItem<String>>((IndustryView industry) {
                return DropdownMenuItem<String>(
                  value: industry.displayName,
                  child: Text(industry.displayName),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildDftqcOfficeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select DFTQC Office *',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
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
            child: DropdownButton<DftqcOffice>(
              isExpanded: true,
              value: selectedDftqcOffice,
              hint: isLoadingOffices
                  ? const Text('Loading offices...')
                  : const Text('Select DFTQC office'),
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (DftqcOffice? newValue) {
                selectedDftqcOffice = newValue;
                updateData();
              },
              items: dftqcOffices.map<DropdownMenuItem<DftqcOffice>>((DftqcOffice office) {
                return DropdownMenuItem<DftqcOffice>(
                  value: office,
                  child: Text(office.nameEn),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> pickFile(String documentKey, int maxSizeMB) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final file = result.files.first;
        final fileSizeMB = file.size / (1024 * 1024);

        if (fileSizeMB > maxSizeMB) {
          // Show error to user (you might want to pass this to the UI)
          debugPrint('File size exceeds $maxSizeMB MB limit');
          return;
        }

        documentFiles[documentKey] = file;
        updateData();
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  void dispose() {
    registrationNumberController.dispose();
    panVatController.dispose();
    additionalDocNameController.dispose();
  }
}