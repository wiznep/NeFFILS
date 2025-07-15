import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../domain/models/industry/industry_view_model.dart';
import '../../../../../domain/models/license/documents_view.dart';
import '../../../../../domain/repositories/industry/industry_view_repository.dart';
import '../../../../../domain/repositories/license/license_document_repository.dart';

class DocumentsFormController {
  final Function(bool) onValidationChanged;
  final Function(Map<String, dynamic>) onChanged;
  final Map<String, dynamic>? initialData;
  final bool isIndustryPreselected;

  final DocumentRepository _documentRepository;
  final IndustryViewRepository _industryRepository;

  List<Map<String, dynamic>> _requiredDocuments = [];
  List<Map<String, dynamic>> _optionalDocuments = [];
  List<Map<String, dynamic>> _additionalDocuments = [];
  String? _selectedIndustryId;
  String? _selectedIndustryName;
  List<IndustryView> _industries = [];
  bool _isLoadingIndustries = false;
  bool _isLoadingDocuments = false;
  bool _hasLoadedApiDocuments = false;
  bool _isSubmitting = false;

  DocumentsFormController({
    required this.onValidationChanged,
    required this.onChanged,
    required this.initialData,
    required this.isIndustryPreselected,
  })  : _documentRepository = DocumentRepository(),
        _industryRepository = IndustryViewRepository() {
    _initializeDocuments();
  }

  bool get isLoadingIndustries => _isLoadingIndustries;
  bool get isLoadingDocuments => _isLoadingDocuments;
  bool get isSubmitting => _isSubmitting;
  List<IndustryView> get industries => _industries;
  String? get selectedIndustryId => _selectedIndustryId;
  String? get selectedIndustryName => _selectedIndustryName;

  Future<void> loadInitialData() async {
    try {
      if (!isIndustryPreselected) {
        await _loadIndustries();
      }

      if (initialData?['industry_id'] != null) {
        _selectedIndustryId = initialData!['industry_id'];
        _selectedIndustryName = initialData!['industry_name'];
      }

      if (isIndustryPreselected && _selectedIndustryId != null && !_hasLoadedApiDocuments) {
        await _loadApiDocuments();
      }

      _updateParentData();
      onValidationChanged(validateForm());
    } catch (e) {
      debugPrint('Initialization error: $e');
      rethrow;
    }
  }

  void _initializeDocuments() {
    _requiredDocuments = [
      {
        'name': 'Technical Proposal',
        'code': 'TECHNICAL_PROPOSAL',
        'file': initialData?['technical_proposal'],
        'maxSize': 5,
        'isRequired': true,
      },
      {
        'name': 'Industry Registration Application Form',
        'code': 'REGISTRATION_FORM',
        'file': initialData?['registration_form'],
        'maxSize': 5,
        'isRequired': true,
      },
    ];

    _optionalDocuments = [
      {
        'name': 'Letter of Administration',
        'code': 'LETTER_OF_ADMINISTRATION',
        'file': initialData?['administration_letter'],
        'maxSize': 5,
        'isRequired': false,
      },
      {
        'name': 'Proposed Industry Layout',
        'code': 'PROPOSED_INDUSTRY_LAYOUT',
        'file': initialData?['industry_layout'],
        'maxSize': 20,
        'isRequired': false,
      },
    ];

    _additionalDocuments = (initialData?['additional_documents'] as List?)?.map((doc) {
      return {
        'name': doc['name'] ?? '',
        'code': doc['code'] ?? 'ADDITIONAL_DOC_${DateTime.now().millisecondsSinceEpoch}',
        'file': doc['file'],
        'maxSize': 5,
        'controller': TextEditingController(text: doc['name'] ?? ''),
        'isRequired': false,
        'apiId': doc['apiId'],
      };
    }).toList() ?? [];
  }

  Future<void> _loadIndustries() async {
    try {
      _isLoadingIndustries = true;
      final allIndustries = await _industryRepository.getAllIndustries();
      _industries = allIndustries.where((i) => i.canApplyForRecommendation).toList();
    } catch (e) {
      debugPrint('Error loading industries: $e');
      _industries = [];
      rethrow;
    } finally {
      _isLoadingIndustries = false;
    }
  }

  Future<void> _loadApiDocuments() async {
    try {
      if (_selectedIndustryId == null) return;

      _isLoadingDocuments = true;
      final documents = await _documentRepository.getIndustryDocuments(_selectedIndustryId!);

      _clearApiDocuments();

      for (final doc in documents) {
        if (doc.isAdditionalDocument) {
          _addAdditionalDocumentFromApi(doc);
        } else {
          _updateExistingDocumentFromApi(doc);
        }
      }

      _hasLoadedApiDocuments = true;
      _updateParentData();
      onValidationChanged(validateForm());
    } catch (e) {
      debugPrint('Error loading API documents: $e');
      rethrow;
    } finally {
      _isLoadingDocuments = false;
    }
  }

  void _clearApiDocuments() {
    for (final doc in [..._requiredDocuments, ..._optionalDocuments]) {
      if (doc['file'] != null && doc['file']['isFromApi'] == true) {
        doc['file'] = null;
        doc.remove('apiId');
      }
    }

    _additionalDocuments.removeWhere((doc) => doc.containsKey('apiId'));
  }

  void _addAdditionalDocumentFromApi(IndustryDocument doc) {
    _additionalDocuments.add({
      'name': doc.name,
      'code': doc.code,
      'file': _createFileMapFromApiDocument(doc),
      'maxSize': 5,
      'controller': TextEditingController(text: doc.name),
      'isRequired': false,
      'apiId': doc.id,
    });
  }

  void _updateExistingDocumentFromApi(IndustryDocument doc) {
    final allDocs = [..._requiredDocuments, ..._optionalDocuments];
    final index = allDocs.indexWhere((d) => d['code'] == doc.code);

    if (index != -1) {
      final targetList = index < _requiredDocuments.length ? _requiredDocuments : _optionalDocuments;
      final adjustedIndex = index < _requiredDocuments.length ? index : index - _requiredDocuments.length;

      targetList[adjustedIndex]['file'] = _createFileMapFromApiDocument(doc);
      targetList[adjustedIndex]['apiId'] = doc.id;
    }
  }

  Map<String, dynamic> _createFileMapFromApiDocument(IndustryDocument doc) {
    return {
      'path': doc.fileUrl,
      'name': doc.name,
      'size': '0',
      'extension': doc.fileUrl?.split('.').last ?? 'pdf',
      'isFromApi': true,
      'url': doc.fileUrl,
    };
  }

  Widget buildIndustryDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedIndustryId,
        isExpanded: true,
        hint: const Text('Select industry'),
        items: _industries.map((industry) {
          return DropdownMenuItem(
            value: industry.id,
            child: Text(industry.displayName),
          );
        }).toList(),
        onChanged: (value) async {
          if (value != null) {
            _selectedIndustryId = value;
            _selectedIndustryName = _industries.firstWhere((i) => i.id == value).displayName;
            await _loadApiDocuments();
            _updateParentData();
            onValidationChanged(validateForm());
          }
        },
      ),
    );
  }

  List<Widget> buildRequiredDocuments() => _requiredDocuments.map(_buildDocumentCard).toList();
  List<Widget> buildOptionalDocuments() => _optionalDocuments.map(_buildDocumentCard).toList();

  List<Widget> buildAdditionalDocuments() {
    return _additionalDocuments.asMap().entries.map((entry) {
      return _buildDocumentCard(entry.value, isAdditional: true, index: entry.key);
    }).toList();
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc, {bool isAdditional = false, int? index}) {
    final hasFile = doc['file'] != null;
    final isFromApi = hasFile && doc['file']['isFromApi'] == true;
    final fileSize = hasFile ? (doc['file']['size'] ?? '0') : '0';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdditional) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: doc['controller'],
                      decoration: const InputDecoration(
                        labelText: 'Document Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (value) {
                        doc['name'] = value;
                        _updateParentData();
                        onValidationChanged(validateForm());
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeAdditionalDocument(index!),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            Text(
              isAdditional ? 'Upload Document' : doc['name'] ?? 'Document',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _buildFileUploadField(doc),

            if (hasFile) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _viewDocument(doc),
                    child: const Text('View'),
                  ),
                  if (!isFromApi || isAdditional)
                    TextButton(
                      onPressed: () => _removeFile(doc),
                      child: const Text('Remove', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadField(Map<String, dynamic> doc) {
    final hasFile = doc['file'] != null;
    final isFromApi = hasFile && doc['file']['isFromApi'] == true;
    final fileSize = hasFile ? (doc['file']['size'] ?? '0') : '0';

    return GestureDetector(
      onTap: isFromApi ? null : () => _pickFile(doc),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: hasFile ? Colors.blue : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file, color: hasFile ? Colors.blue : Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? (doc['file']['name'] ?? 'Uploaded file') : 'Click to select file',
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasFile)
                    Text(
                      isFromApi ? 'Uploaded' : '${double.tryParse(fileSize)?.toStringAsFixed(2) ?? '0'} MB',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            if (hasFile && !isFromApi)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => _removeFile(doc),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildAddDocumentButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Add Additional Document'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue,
          side: const BorderSide(color: Colors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        onPressed: _addAdditionalDocument,
      ),
    );
  }

  Future<void> _pickFile(Map<String, dynamic> doc) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileSize = file.size / (1024 * 1024);

        if (fileSize > (doc['maxSize'] ?? 5)) {
          throw Exception('File size exceeds ${doc['maxSize'] ?? 5} MB limit');
        }

        doc['file'] = {
          'path': file.path!,
          'name': file.name,
          'size': fileSize.toString(),
          'extension': file.extension ?? 'pdf',
          'isFromApi': false,
        };

        _updateParentData();
        onValidationChanged(validateForm());
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      rethrow;
    }
  }

  void _removeFile(Map<String, dynamic> doc) {
    doc['file'] = null;
    doc.remove('apiId');
    _updateParentData();
    onValidationChanged(validateForm());
  }

  void _addAdditionalDocument() {
    _additionalDocuments.add({
      'name': '',
      'code': 'ADDITIONAL_DOC_${DateTime.now().millisecondsSinceEpoch}',
      'file': null,
      'maxSize': 5,
      'controller': TextEditingController(),
      'isRequired': false,
    });
    _updateParentData();
    onValidationChanged(validateForm());
  }

  void _removeAdditionalDocument(int index) {
    final doc = _additionalDocuments[index];

    if (doc.containsKey('apiId') && _selectedIndustryId != null) {
      _documentRepository.deleteDocument(
        industryId: _selectedIndustryId!,
        documentId: doc['apiId'],
      ).catchError((e) {
        debugPrint('Error deleting document: $e');
      });
    }

    doc['controller'].dispose();
    _additionalDocuments.removeAt(index);
    _updateParentData();
    onValidationChanged(validateForm());
  }

  Future<void> _viewDocument(Map<String, dynamic> doc) async {
    try {
      final url = doc['file']['url'] ?? doc['file']['path'];
      if (url == null) return;

      final uri = Uri.parse(url);
      if (!uri.isAbsolute) return;

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error viewing document: $e');
    }
  }

  bool validateForm() {
    if (_selectedIndustryId == null || _selectedIndustryId!.isEmpty) {
      return false;
    }

    for (final doc in _requiredDocuments) {
      if (doc['isRequired'] == true && doc['file'] == null) {
        return false;
      }
    }

    for (final doc in _additionalDocuments) {
      if ((doc['name']?.isEmpty ?? true) && doc['file'] != null) return false;
      if ((doc['name']?.isNotEmpty ?? false) && doc['file'] == null) return false;
    }

    return true;
  }

  Future<void> submitDocuments() async {
    if (_selectedIndustryId == null || _selectedIndustryId!.isEmpty) {
      throw Exception('Please select an industry before submitting');
    }

    try {
      _isSubmitting = true;
      onValidationChanged(false); // Disable next button while submitting

      // First upload required and optional documents
      for (final doc in [..._requiredDocuments, ..._optionalDocuments]) {
        if (doc['file'] != null && doc['file']['isFromApi'] != true) {
          await _documentRepository.uploadDocument(
            industryId: _selectedIndustryId!,
            documentCode: doc['code'],
            filePath: doc['file']['path'],
            documentId: doc['apiId'],
          );
        }
      }

      // Then handle additional documents
      for (final doc in _additionalDocuments) {
        if (doc['file'] != null) {
          if (doc.containsKey('apiId')) {
            // Update existing additional document
            await _documentRepository.uploadDocument(
              industryId: _selectedIndustryId!,
              documentCode: doc['code'],
              filePath: doc['file']['path'],
              documentId: doc['apiId'],
              documentName: doc['name'],
            );
          } else {
            // Create new additional document
            await _documentRepository.uploadDocument(
              industryId: _selectedIndustryId!,
              documentCode: doc['code'],
              filePath: doc['file']['path'],
              documentName: doc['name'],
            );
          }
        } else if (doc.containsKey('apiId')) {
          // Delete document if it exists in API but has no file
          await _documentRepository.deleteDocument(
            industryId: _selectedIndustryId!,
            documentId: doc['apiId'],
          );
        }
      }
    } catch (e) {
      debugPrint('Error submitting documents: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      onValidationChanged(validateForm());
    }
  }

  void _updateParentData() {
    final data = {
      'industry_id': _selectedIndustryId,
      'industry_name': _selectedIndustryName,
      'technical_proposal': _getDocumentData('TECHNICAL_PROPOSAL'),
      'registration_form': _getDocumentData('REGISTRATION_FORM'),
      'administration_letter': _getDocumentData('LETTER_OF_ADMINISTRATION'),
      'industry_layout': _getDocumentData('PROPOSED_INDUSTRY_LAYOUT'),
      'additional_documents': _additionalDocuments.map((doc) => ({
        'name': doc['name'],
        'code': doc['code'],
        'file': doc['file'],
        'apiId': doc['apiId'],
      })).toList(),
    };

    onChanged(data);
  }

  Map<String, dynamic>? _getDocumentData(String code) {
    final allDocs = [..._requiredDocuments, ..._optionalDocuments];
    final doc = allDocs.firstWhere((d) => d['code'] == code, orElse: () => {});
    return doc.isNotEmpty
        ? {
      'file': doc['file'],
      'apiId': doc['apiId'],
    }
        : null;
  }

  void dispose() {
    for (final doc in _additionalDocuments) {
      doc['controller'].dispose();
    }
  }
}