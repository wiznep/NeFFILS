import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:neffils/domain/models/dropdown_option_model.dart';
import 'package:neffils/domain/models/industry/industry_proprietor_model.dart';
import 'package:neffils/domain/models/industry/industry_shareholder.dart';
import 'package:neffils/utils/colors/color.dart';
import '../../../../config/config.dart';
import '../../../../data/services/token/token_storage_service.dart';

class ProprietorFormController {
  final Function(bool) onValidationChanged;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, List<DropdownOption>> _options = {};
  bool isLoading = false;
  bool isSameAsPermanent = false;
  XFile? _signatureImage;
  Proprietor? _initialData;
  Shareholder? _selectedShareholder;
  List<Shareholder> _shareholders = [];
  final String _baseUrl = '$apiUrl';

  ProprietorFormController({
    required this.onValidationChanged,
    Proprietor? initialData,
    Shareholder? selectedShareholder,
    List<Shareholder> shareholders = const [],
  })  : _initialData = initialData,
        _selectedShareholder = selectedShareholder,
        _shareholders = shareholders {
    _initializeControllers();
    if (initialData != null) {
      _loadInitialValues(initialData);
    }
  }

  // Field definitions
  final List<String> addressFields = [
    'country', 'province', 'district', 'local_level',
    'ward_number', 'house_number', 'g_plus_code', 'nearest_landmark'
  ];

  final Map<String, String> _labels = {
    'phone_number': 'Contact Number',
    'email': 'Email Address',
    'grandfather_name_en': 'Grandfather Name (English)',
    'grandfather_name_np': 'Grandfather Name (Nepali)',
    'father_name_en': 'Father Name (English)',
    'father_name_np': 'Father Name (Nepali)',
    'mother_name_en': 'Mother Name (English)',
    'mother_name_np': 'Mother Name (Nepali)',
    'country': 'Country',
    'province': 'Province',
    'district': 'District',
    'local_level': 'Municipality',
    'ward_number': 'Ward Number',
    'house_number': 'House Number',
    'g_plus_code': 'G-PLUS Code',
    'nearest_landmark': 'Nearest Landmark',
  };

  void _initializeControllers() {
    for (var key in _labels.keys) {
      _controllers[key] = TextEditingController();
      _controllers['${key}_tem'] = TextEditingController();
    }
  }

  void _loadInitialValues(Proprietor data) {
    // Personal information
    _controllers['phone_number']!.text = data.phoneNumber ?? '';
    _controllers['email']!.text = data.email ?? '';

    // Family details
    _controllers['grandfather_name_en']!.text = data.grandfatherNameEn ?? '';
    _controllers['grandfather_name_np']!.text = data.grandfatherNameNp ?? '';
    _controllers['father_name_en']!.text = data.fatherNameEn ?? '';
    _controllers['father_name_np']!.text = data.fatherNameNp ?? '';
    _controllers['mother_name_en']!.text = data.motherNameEn ?? '';
    _controllers['mother_name_np']!.text = data.motherNameNp ?? '';

    // Permanent address
    _controllers['country']!.text = data.countryPer ?? '';
    _controllers['province']!.text = data.provincePer ?? '';
    _controllers['district']!.text = data.districtPer ?? '';
    _controllers['local_level']!.text = data.localLevelPer ?? '';
    _controllers['ward_number']!.text = data.wardNumberPer?.toString() ?? '';
    _controllers['house_number']!.text = data.houseNumberPer ?? '';
    _controllers['g_plus_code']!.text = data.gPlusCodePer ?? '';
    _controllers['nearest_landmark']!.text = data.nearestLandmarkPer ?? '';

    // Temporary address
    _controllers['country_tem']!.text = data.countryTem ?? '';
    _controllers['province_tem']!.text = data.provinceTem ?? '';
    _controllers['district_tem']!.text = data.districtTem ?? '';
    _controllers['local_level_tem']!.text = data.localLevelTem ?? '';
    _controllers['ward_number_tem']!.text = data.wardNumberTem?.toString() ?? '';
    _controllers['house_number_tem']!.text = data.houseNumberTem ?? '';
    _controllers['g_plus_code_tem']!.text = data.gPlusCodeTem ?? '';
    _controllers['nearest_landmark_tem']!.text = data.nearestLandmarkTem ?? '';

    // Set same as permanent address flag
    isSameAsPermanent = (data.countryPer == data.countryTem) &&
        (data.provincePer == data.provinceTem) &&
        (data.districtPer == data.districtTem) &&
        (data.localLevelPer == data.localLevelTem) &&
        (data.wardNumberPer == data.wardNumberTem) &&
        (data.houseNumberPer == data.houseNumberTem);
  }

  Future<List<DropdownOption>> _fetchOptions(String url) async {
    try {
      final token = await TokenStorageService.getAccessToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/$url'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => DropdownOption(
          id: item['id'].toString(),
          name: item['name_en'] ?? item['name_np'] ?? item['name'] ?? item['id'].toString(),
        )).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching $url: $e');
      return [];
    }
  }

  Future<void> loadDropdownOptions({
    String? initialProvincePer,
    String? initialDistrictPer,
    String? initialProvinceTem,
    String? initialDistrictTem,
  }) async {
    isLoading = true;
    try {
      _options['country'] = await _fetchOptions('nepal-map/country/');
      _options['province'] = await _fetchOptions('nepal-map/province/');
      _options['ward_number'] = List.generate(35, (i) => DropdownOption(id: '${i + 1}', name: '${i + 1}'));
      _options['country_tem'] = List.from(_options['country'] ?? []);
      _options['province_tem'] = List.from(_options['province'] ?? []);
      _options['ward_number_tem'] = List.from(_options['ward_number'] ?? []);
      if (initialProvincePer != null && initialProvincePer.isNotEmpty) {
        _options['district'] = await _fetchOptions('nepal-map/district/?province=$initialProvincePer');

        if (initialDistrictPer != null && initialDistrictPer.isNotEmpty) {
          _options['local_level'] = await _fetchOptions('nepal-map/local-levels/?district=$initialDistrictPer');
        }
      }

      if (initialProvinceTem != null && initialProvinceTem.isNotEmpty) {
        _options['district_tem'] = await _fetchOptions('nepal-map/district/?province=$initialProvinceTem');

        if (initialDistrictTem != null && initialDistrictTem.isNotEmpty) {
          _options['local_level_tem'] = await _fetchOptions('nepal-map/local-levels/?district=$initialDistrictTem');
        }
      }
    } catch (e) {
      debugPrint('Error loading dropdown options: $e');
    } finally {
      isLoading = false;
      onValidationChanged(validateForm());
    }
  }

  Future<void> _loadDistricts(String provinceId, bool isTemporary) async {
    final optionsKey = isTemporary ? 'district_tem' : 'district';
    final controllerKey = isTemporary ? 'district_tem' : 'district';

    // Clear dependent fields
    if (isTemporary) {
      _controllers['local_level_tem']?.text = '';
      _options['local_level_tem'] = [];
    } else {
      _controllers['local_level']?.text = '';
      _options['local_level'] = [];
    }

    try {
      final districts = await _fetchOptions('nepal-map/district/?province=$provinceId');
      _options[optionsKey] = districts;

      final currentValue = _controllers[controllerKey]?.text;
      if (currentValue != null && currentValue.isNotEmpty) {
        if (!districts.any((option) => option.id == currentValue)) {
          _controllers[controllerKey]?.text = '';
        }
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
    } finally {
      onValidationChanged(validateForm());
    }
  }

  Future<void> _loadLocalLevels(String districtId, bool isTemporary) async {
    final optionsKey = isTemporary ? 'local_level_tem' : 'local_level';
    final controllerKey = isTemporary ? 'local_level_tem' : 'local_level';

    try {
      final localLevels = await _fetchOptions('nepal-map/local-levels/?district=$districtId');
      _options[optionsKey] = localLevels;

      final currentValue = _controllers[controllerKey]?.text;
      if (currentValue != null && currentValue.isNotEmpty) {
        if (!localLevels.any((option) => option.id == currentValue)) {
          _controllers[controllerKey]?.text = '';
        }
      }
    } catch (e) {
      debugPrint('Error loading local levels: $e');
    } finally {
      onValidationChanged(validateForm());
    }
  }

  InputDecoration _inputDecoration({String? hintText, bool isRequired = true}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: appColors.text_field, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget buildTextField(String key, {bool isRequired = true, bool isTemporary = false}) {
    final controllerKey = isTemporary ? '${key}_tem' : key;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(key, isRequired),
        TextFormField(
          controller: _controllers[controllerKey],
          onChanged: (_) => onValidationChanged(validateForm()),
          decoration: _inputDecoration(
            hintText: 'Enter ${_labels[key]?.toLowerCase()}',
            isRequired: isRequired,
          ),
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget buildDropdown(String key, {bool isRequired = true, bool isTemporary = false}) {
    final controllerKey = isTemporary ? '${key}_tem' : key;
    final optionsKey = isTemporary ? '${key}_tem' : key;

    final currentOptions = _options[optionsKey] ?? [];
    final currentValue = _controllers[controllerKey]!.text.isEmpty ? null : _controllers[controllerKey]!.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(key, isRequired),
        DropdownButtonFormField<String>(
          value: currentValue,
          items: currentOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option.id,
              child: Text(option.name, style: const TextStyle(fontSize: 15)),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value == null) return;
            _controllers[controllerKey]!.text = value;
            if (key == 'province') {
              _loadDistricts(value, isTemporary);
            } else if (key == 'district') {
              _loadLocalLevels(value, isTemporary);
            }
            onValidationChanged(validateForm());
          },
          decoration: _inputDecoration(
            hintText: 'Select ${_labels[key]?.toLowerCase()}',
            isRequired: isRequired,
          ),
          icon: const Icon(Icons.arrow_drop_down, size: 24),
          iconEnabledColor: Colors.grey[700],
          dropdownColor: Colors.white,
          style: TextStyle(color: Colors.grey[800]),
          borderRadius: BorderRadius.circular(8),
          isExpanded: true,
          menuMaxHeight: 300,
        ),
      ],
    );
  }

  Widget buildShareholderDropdown({required ValueChanged<Shareholder?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('proprietor_shareholder', true),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Shareholder>(
              value: _selectedShareholder,
              isExpanded: true,
              hint: const Text('Select shareholder', style: TextStyle(color: Colors.grey)),
              items: _shareholders.map((shareholder) {
                return DropdownMenuItem<Shareholder>(
                  value: shareholder,
                  child: Text(
                    shareholder.nameEnglish,
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }).toList(),
              onChanged: (Shareholder? value) {
                onChanged(value);
                _selectedShareholder = value;
                onValidationChanged(validateForm());
              },
              icon: const Icon(Icons.arrow_drop_down, size: 24),
              dropdownColor: Colors.white,
              style: TextStyle(color: Colors.grey[800]),
              borderRadius: BorderRadius.circular(8),
              menuMaxHeight: 300,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAddressSection({required bool isTemporary}) => Column(
    children: [
      buildDropdown('country', isTemporary: isTemporary),
      const SizedBox(height: 16),
      buildDropdown('province', isTemporary: isTemporary),
      const SizedBox(height: 16),
      buildDropdown('district', isTemporary: isTemporary),
      const SizedBox(height: 16),
      buildDropdown('local_level', isTemporary: isTemporary),
      const SizedBox(height: 16),
      buildDropdown('ward_number', isTemporary: isTemporary),
      const SizedBox(height: 16),
      buildTextField('house_number', isTemporary: isTemporary),
      const SizedBox(height: 16),
      buildTextField('g_plus_code', isTemporary: isTemporary, isRequired: false),
      const SizedBox(height: 16),
      buildTextField('nearest_landmark', isTemporary: isTemporary, isRequired: false),
    ],
  );

  Widget buildSameAddressCheckbox({required ValueChanged<bool> onChanged}) => Row(
    children: [
      Checkbox(
        value: isSameAsPermanent,
        onChanged: (bool? value) {
          if (value != null) {
            isSameAsPermanent = value;
            onChanged(isSameAsPermanent);
          }
        },
      ),
      const Text('Same as permanent address?'),
    ],
  );

  Widget buildSignatureSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel('signature', true),
      const SizedBox(height: 8),
      InkWell(
        onTap: _pickSignatureImage,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Icon(Icons.upload_file, color: appColors.formsubmit),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _signatureImage?.name ?? 'Upload Signature Image',
                  style: TextStyle(
                    color: _signatureImage == null ? Colors.grey[600] : Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
              if (_signatureImage != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _signatureImage = null;
                    onValidationChanged(validateForm());
                  },
                ),
            ],
          ),
        ),
      ),
      if (_signatureImage != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_signatureImage!.path),
              height: 150,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
    ],
  );

  Widget _buildLabel(String key, bool isRequired) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        children: [
          if (isRequired) const TextSpan(text: '* ', style: TextStyle(color: Colors.red)),
          TextSpan(
            text: _labels[key] ?? key.replaceAll('_', ' '),
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    ),
  );

  Future<void> _pickSignatureImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        _signatureImage = picked;
        onValidationChanged(validateForm());
      }
    } catch (e) {
      debugPrint('Error picking signature image: $e');
    }
  }

  bool validateForm() {
    try {
      final requiredFields = [
        'phone_number', 'email',
        'grandfather_name_en', 'grandfather_name_np',
        'father_name_en', 'father_name_np',
        'mother_name_en', 'mother_name_np'
      ];

      for (var field in requiredFields) {
        if (_controllers[field]?.text.trim().isEmpty ?? true) return false;
      }

      if (_selectedShareholder == null) return false;

      for (var field in addressFields.where((f) => f != 'g_plus_code' && f != 'nearest_landmark')) {
        if (_controllers[field]?.text.trim().isEmpty ?? true) return false;
        if (!isSameAsPermanent && (_controllers['${field}_tem']?.text.trim().isEmpty ?? true)) return false;
      }

      return _signatureImage != null || _initialData?.proprietorSignature != null;
    } catch (e) {
      debugPrint('Error validating form: $e');
      return false;
    }
  }

  Proprietor collectFormData(String industryId) {
    return Proprietor(
      id: _initialData?.id,
      nameEn: _selectedShareholder?.nameEnglish ?? '',
      nameNp: _selectedShareholder?.nameNepali ?? '',
      phoneNumber: _controllers['phone_number']!.text.trim(),
      email: _controllers['email']!.text.trim(),
      wardNumberPer: int.tryParse(_controllers['ward_number']!.text.trim()) ?? 0,
      houseNumberPer: _controllers['house_number']!.text.trim(),
      nearestLandmarkPer: _controllers['nearest_landmark']!.text.trim(),
      gPlusCodePer: _controllers['g_plus_code']!.text.trim(),
      wardNumberTem: isSameAsPermanent
          ? int.tryParse(_controllers['ward_number']!.text.trim()) ?? 0
          : int.tryParse(_controllers['ward_number_tem']!.text.trim()) ?? 0,
      houseNumberTem: isSameAsPermanent
          ? _controllers['house_number']!.text.trim()
          : _controllers['house_number_tem']!.text.trim(),
      nearestLandmarkTem: isSameAsPermanent
          ? _controllers['nearest_landmark']!.text.trim()
          : _controllers['nearest_landmark_tem']!.text.trim(),
      gPlusCodeTem: isSameAsPermanent
          ? _controllers['g_plus_code']!.text.trim()
          : _controllers['g_plus_code_tem']!.text.trim(),
      grandfatherNameEn: _controllers['grandfather_name_en']!.text.trim(),
      grandfatherNameNp: _controllers['grandfather_name_np']!.text.trim(),
      fatherNameEn: _controllers['father_name_en']!.text.trim(),
      fatherNameNp: _controllers['father_name_np']!.text.trim(),
      motherNameEn: _controllers['mother_name_en']!.text.trim(),
      motherNameNp: _controllers['mother_name_np']!.text.trim(),
      industry: industryId,
      shareholder: _selectedShareholder?.id ?? '',
      countryPer: _controllers['country']!.text.trim(),
      provincePer: _controllers['province']!.text.trim(),
      districtPer: _controllers['district']!.text.trim(),
      localLevelPer: _controllers['local_level']!.text.trim(),
      countryTem: isSameAsPermanent ? _controllers['country']!.text.trim() : _controllers['country_tem']!.text.trim(),
      provinceTem: isSameAsPermanent ? _controllers['province']!.text.trim() : _controllers['province_tem']!.text.trim(),
      districtTem: isSameAsPermanent ? _controllers['district']!.text.trim() : _controllers['district_tem']!.text.trim(),
      localLevelTem: isSameAsPermanent ? _controllers['local_level']!.text.trim() : _controllers['local_level_tem']!.text.trim(),
    );
  }

  File? getSignatureFile() => _signatureImage != null ? File(_signatureImage!.path) : null;

  void copyPermanentToTemporary() {
    for (var field in addressFields) {
      _controllers['${field}_tem']!.text = _controllers[field]!.text;
    }

    _options['country_tem'] = List.from(_options['country'] ?? []);
    _options['province_tem'] = List.from(_options['province'] ?? []);
    _options['district_tem'] = List.from(_options['district'] ?? []);
    _options['local_level_tem'] = List.from(_options['local_level'] ?? []);
    _options['ward_number_tem'] = List.from(_options['ward_number'] ?? []);

    onValidationChanged(validateForm());
  }

  void clearTemporaryAddress() {
    for (var field in addressFields) {
      _controllers['${field}_tem']!.clear();
    }

    _options['district_tem'] = [];
    _options['local_level_tem'] = [];

    onValidationChanged(validateForm());
  }

  void updateSelectedShareholder(Shareholder shareholder) {
    _selectedShareholder = shareholder;
    onValidationChanged(validateForm());
  }

  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
  }
}