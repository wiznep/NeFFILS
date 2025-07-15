import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:neffils/config/config.dart';
import 'package:neffils/ui/color_manager.dart';
import 'package:neffils/ui/styles_manager.dart';
import 'package:neffils/ui/values_manager.dart';
import 'dart:convert';
import '../../../../../data/services/token/token_storage_service.dart';
import '../../../../../domain/models/dropdown_option_model.dart';
import '../../../../../domain/models/industry/industry_basic_info.dart';
import '../../../../../domain/repositories/industry/industry_view_repository.dart';
import '../../../shimmer/industry_info_shimmer.dart';

class IndustryInfoForm extends StatefulWidget {
  final String? industryId;
  final IndustryBasicInfo initialInfo;
  final Function(bool) onValidationChanged;
  final Function(String) onSubmitted;

  const IndustryInfoForm({
    Key? key,
    this.industryId,
    required this.initialInfo,
    required this.onValidationChanged,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  State<IndustryInfoForm> createState() => IndustryInfoFormState();
}

class IndustryInfoFormState extends State<IndustryInfoForm> {
  late IndustryBasicInfo info;
  final Map<String, TextEditingController> controllers = {};
  final Map<String, List<DropdownOption>> options = {};
  final Map<String, String> displayValues = {};
  bool isLoading = false;
  final IndustryViewRepository _repository = IndustryViewRepository();
  final String _baseUrl = '$apiUrl';

  final List<String> ddKeys = [
    'industryType',
    'industryCapital',
    'ownProperty',
    'country',
    'province',
    'district',
    'municipality',
  ];

  final Map<String, String> labels = {
    'industryNameNepali': 'Industry Name in Nepali (उद्योगको नाम - नेपाली)',
    'industryNameEnglish':
        'Industry Name in English (उद्योगको नाम - अंग्रेजीमा)',
    'industryContactNumber': 'Industry Contact Number (सम्पर्क नम्बर)',
    'industryType': 'Industry Type (उद्योगको प्रकार)',
    'ownProperty': 'Own Property? (आफ्नै सम्पत्ति ?)',
    'industryCapital': 'Industry Capital (उद्योग पूंजी)',
    'totalProperty': 'Total Capital (कुल पूंजी)',
    'industryCapacity': 'Annual Production Capacity (वार्षिक उत्पादन क्षमता)',
    'marketsize': 'Marketsize (बजार आकार)',
    'numberOfEmployees':
        'Number of Technical/Trained Employees (प्राविधिक/प्रशिक्षित कर्मचारीहरूको संख्या)',
    'intendedProducts':
        'Intended products to be produced (अनुमानित उत्पादन गर्न चाहेको वस्तुहरु)',
    'country': 'Country (देश)',
    'province': 'Province (प्रदेश)',
    'district': 'District (जिल्ला)',
    'municipality': 'Municipality (पालिका)',
    'wardNo': 'Ward No. (वडा नम्बर)',
    'houseNo': 'House No. (घर नम्बर)',
    'nearestLandmark': 'Nearest Landmark (नजिकको चर्चित भू-भाग)',
    'gPlusCode': 'G-PLUS Code (जी-प्लस कोड)',
  };

  final List<String> optionalFields = [
    'houseNo',
    'nearestLandmark',
    'gPlusCode',
  ];

  @override
  void initState() {
    super.initState();
    info = widget.initialInfo;
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    for (var key in labels.keys) {
      controllers[key] = TextEditingController(
        text: widget.initialInfo.toJson()[_jsonKeyFor(key)]?.toString() ?? '',
      );
    }
    controllers['ownProperty']!.text =
        widget.initialInfo.ownProperty ? 'true' : 'false';
  }

  String _jsonKeyFor(String fieldKey) {
    final map = {
      'industryNameNepali': 'name_np',
      'industryNameEnglish': 'name_en',
      'industryContactNumber': 'contact_number',
      'industryType': 'industry_type',
      'industryCapital': 'industry_capital',
      'ownProperty': 'own_property',
      'totalProperty': 'total_property',
      'industryCapacity': 'estimated_industry_production_capacity',
      'marketsize': 'estimated_market_size',
      'numberOfEmployees': 'employee_count',
      'intendedProducts': 'intended_products',
      'country': 'country',
      'province': 'province',
      'district': 'district',
      'municipality': 'local_level',
      'wardNo': 'ward_number',
      'houseNo': 'house_number',
      'nearestLandmark': 'nearest_landmark',
      'gPlusCode': 'g_plus_code',
    };
    return map[fieldKey] ?? fieldKey;
  }

  Future<String> _getToken() async {
    final token = await TokenStorageService.getAccessToken();
    if (token == null) throw Exception('No authentication token found');
    return token;
  }

  Future<List<DropdownOption>> _fetchOptions(
    String endpoint, {
    String params = '',
  }) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint$params'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        log(response.body);
        return data.map((item) {
          if (endpoint.contains('induster-capital')) {
            return DropdownOption(
              id: item['id'].toString(),
              name: item['eng_label'] ?? item['id'].toString(),
            );
          }
          return DropdownOption(
            id: item['id'].toString(),
            name:
                item['name_en'] ??
                item['name_np'] ??
                item['name'] ??
                item['id'].toString(),
          );
        }).toList();
      }
      throw Exception('Failed to load options: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching $endpoint: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _fetchOptionById(
    String endpoint,
    String id,
  ) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching option by ID: $e');
      return null;
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    try {
      // Load dropdown options
      options['industryType'] = await _fetchOptions(
        'masterdata/industry-type/',
      );
      options['industryCapital'] = await _fetchOptions(
        'masterdata/induster-capital/',
      );
      options['country'] = await _fetchOptions('nepal-map/country/');

      // Set ownProperty options
      options['ownProperty'] = [
        DropdownOption(id: 'true', name: 'Yes'),
        DropdownOption(id: 'false', name: 'No'),
      ];

      // Fetch provinces only if country is selected
      if (controllers['country']!.text.isNotEmpty) {
        options['province'] = await _fetchOptions(
          'nepal-map/province/',
          params: '?country=${controllers['country']!.text}',
        );
      } else {
        options['province'] = [];
      }
      // Fetch districts only if province is selected
      if (controllers['province']!.text.isNotEmpty) {
        options['district'] = await _fetchOptions(
          'nepal-map/district/',
          params: '?province=${controllers['province']!.text}',
        );
      } else {
        options['district'] = [];
      }
      // Fetch municipalities only if district is selected
      if (controllers['district']!.text.isNotEmpty) {
        options['municipality'] = await _fetchOptions(
          'nepal-map/local-levels/',
          params: '?district=${controllers['district']!.text}',
        );
      } else {
        options['municipality'] = [];
      }
      options['wardNo'] = List.generate(
        35,
        (index) => DropdownOption(
          id: (index + 1).toString(),
          name: (index + 1).toString(),
        ),
      );

      if (widget.industryId != null) {
        final initialInfo = await _repository.getBasicIndustryInfo(
          widget.industryId!,
        );

        if (initialInfo.industryCapital.isNotEmpty) {
          final capitalData = await _fetchOptionById(
            'masterdata/induster-capital/',
            initialInfo.industryCapital,
          );
          if (capitalData != null) {
            displayValues['industryCapital'] =
                capitalData['eng_label'] ?? initialInfo.industryCapital;
          }
        }

        if (initialInfo.municipality.isNotEmpty) {
          final municipalityData = await _fetchOptionById(
            'nepal-map/local-levels/',
            initialInfo.municipality,
          );
          if (municipalityData != null) {
            displayValues['municipality'] =
                municipalityData['name_en'] ??
                municipalityData['name_np'] ??
                initialInfo.municipality;
          }
        }

        _setDropdownValue('industryType', initialInfo.industryType);
        _setDropdownValue('country', initialInfo.country);
        _setDropdownValue('province', initialInfo.province);
        _setDropdownValue('district', initialInfo.district);
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      setState(() => isLoading = false);
      widget.onValidationChanged(_validateForm());
    }
  }

  void _setDropdownValue(String field, String? value) {
    if (value == null || value.isEmpty) return;

    final option = options[field]?.firstWhere(
      (opt) => opt.id == value,
      orElse: () => DropdownOption(id: value, name: value),
    );

    if (option != null) {
      controllers[field]!.text = option.id;
    }
  }

  Future<void> _loadDistricts(String provinceId) async {
    setState(() {
      isLoading = true;
      controllers['district']!.text = '';
      controllers['municipality']!.text = '';
      options['district'] = [];
      options['municipality'] = [];
    });

    try {
      options['district'] = await _fetchOptions(
        'nepal-map/district/',
        params: '?province=$provinceId',
      );
    } catch (e) {
      debugPrint('Error loading districts: $e');
    } finally {
      setState(() => isLoading = false);
      widget.onValidationChanged(_validateForm());
    }
  }

  Future<void> _loadMunicipalities(String districtId) async {
    setState(() {
      isLoading = true;
      controllers['municipality']!.text = '';
      options['municipality'] = [];
    });

    try {
      options['municipality'] = await _fetchOptions(
        'nepal-map/local-levels/',
        params: '?district=$districtId',
      );
    } catch (e) {
      debugPrint('Error loading municipalities: $e');
    } finally {
      setState(() => isLoading = false);
      widget.onValidationChanged(_validateForm());
    }
  }

  bool _validateForm() {
    for (var key in labels.keys) {
      if (optionalFields.contains(key)) continue;
      if (controllers[key]?.text.isEmpty ?? true) return false;
    }
    return true;
  }

  Future<void> submit() async {
    if (!_validateForm()) {
      widget.onValidationChanged(false);
      return;
    }

    setState(() => isLoading = true);
    try {
      final updatedInfo = IndustryBasicInfo(
        id: widget.industryId ?? info.id,
        nameEn: controllers['industryNameEnglish']!.text,
        nameNp: controllers['industryNameNepali']!.text,
        contactNumber: controllers['industryContactNumber']!.text,
        industryType: controllers['industryType']!.text,
        industryCapital: controllers['industryCapital']!.text,
        ownProperty: controllers['ownProperty']!.text == 'true',
        totalProperty: controllers['totalProperty']!.text,
        industryCapacity: controllers['industryCapacity']!.text,
        marketSize: controllers['marketsize']!.text,
        numberOfEmployees:
            int.tryParse(controllers['numberOfEmployees']!.text) ?? 0,
        intendedProducts: controllers['intendedProducts']!.text,
        country: controllers['country']!.text,
        province: controllers['province']!.text,
        district: controllers['district']!.text,
        municipality: controllers['municipality']!.text,
        wardNo: controllers['wardNo']!.text,
        houseNo: controllers['houseNo']!.text,
        nearestLandmark: controllers['nearestLandmark']!.text,
        gPlusCode: controllers['gPlusCode']!.text,
      );

      if (updatedInfo.id != null) {
        await _repository.updateBasicIndustryInfo(updatedInfo.id!, updatedInfo);
        widget.onSubmitted(updatedInfo.id!);
      } else {
        final token = await _getToken();
        final response = await http.post(
          Uri.parse('$_baseUrl/industry/industry/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(updatedInfo.toJson()),
        );

        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          widget.onSubmitted(responseData['id'].toString());
        } else {
          throw Exception('Failed to create industry: ${response.statusCode}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration({String? hintText, bool isRequired = true}) {
    return InputDecoration(
      hintText: hintText,
      // hintStyle: TextStyle(color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      // focusedBorder: OutlineInputBorder(
      //   borderRadius: BorderRadius.circular(8),
      //   borderSide: BorderSide(color: appColors.text_field, width: 1.5),
      // ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: AppSize.s12,
      ),
    );
  }

  Widget _buildLabel({required String label, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            if (isRequired)
              TextSpan(
                text: '* ',
                style: getBoldStyle(color: Colors.red, fontSize: 14),
              ),
            TextSpan(text: label, style: getMediumStyle()),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String key, {bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label: labels[key] ?? key, isRequired: isRequired),
        TextFormField(
          controller: controllers[key],
          onChanged: (_) => widget.onValidationChanged(_validateForm()),
          decoration: _inputDecoration(
            hintText: 'Enter ${labels[key]?.toLowerCase() ?? key}',
            isRequired: isRequired,
          ),
          style: getRegularStyle(),
        ),
      ],
    );
  }

  Widget _buildDropdown(String key, {bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label: labels[key] ?? key, isRequired: isRequired),
        DropdownButtonFormField<String>(
          value: controllers[key]!.text.isEmpty ? null : controllers[key]!.text,
          decoration: _inputDecoration(
            hintText: 'Select ${labels[key]?.toLowerCase()}',
            isRequired: isRequired,
          ),
          items:
              (options[key] ?? [])
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(e.name, style: getRegularStyle()),
                    ),
                  )
                  .toList(),
          onChanged: (value) async {
            if (value == null) return;
            setState(() {
              controllers[key]!.text = value;
              displayValues.remove(key);
              if (key == 'country') {
                controllers['province']!.text = '';
                controllers['district']!.text = '';
                controllers['municipality']!.text = '';
                options['province'] = [];
                options['district'] = [];
                options['municipality'] = [];
              }
            });
            if (key == 'country') {
              setState(() {
                isLoading = true;
              });
              options['province'] = await _fetchOptions(
                'nepal-map/province/',
                params: '?country=$value',
              );
              setState(() {
                isLoading = false;
              });
            }
            if (key == 'province') {
              setState(() {
                isLoading = true;
              });
              controllers['district']!.text = '';
              controllers['municipality']!.text = '';
              options['district'] = await _fetchOptions(
                'nepal-map/district/',
                params: '?province=$value',
              );
              options['municipality'] = [];
              setState(() {
                isLoading = false;
              });
            }
            if (key == 'district') {
              setState(() {
                isLoading = true;
              });
              controllers['municipality']!.text = '';
              options['municipality'] = await _fetchOptions(
                'nepal-map/local-levels/',
                params: '?district=$value',
              );
              setState(() {
                isLoading = false;
              });
            }
            widget.onValidationChanged(_validateForm());
          },
          icon: const Icon(Icons.arrow_drop_down, size: 24),
          iconEnabledColor: Colors.grey[700],
          dropdownColor: Colors.white,
          style: getRegularStyle(),
          borderRadius: BorderRadius.circular(8),
          isExpanded: true,
          menuMaxHeight: 300,
        ),
      ],
    );
  }

  Widget _buildField(String key) {
    final isRequired = !optionalFields.contains(key);

    if (isLoading &&
        ddKeys.contains(key) &&
        (options[key] == null || options[key]!.isEmpty)) {
      return IndustryInfoShimmer();
    }

    return ddKeys.contains(key)
        ? _buildDropdown(key, isRequired: isRequired)
        : _buildTextField(key, isRequired: isRequired);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: getBoldStyle(fontSize: 16, color: ColorManager.darkGrey2),
      ),
    );
  }

  final marketSizeController = MultiSelectController<String>();
  var marketSizeItems = [
    DropdownItem(label: 'National', value: 'National'),
    DropdownItem(label: 'International', value: "International"),
    // DropdownItem(label: 'National / ', value: User(name: 'India', id: 2)),
    // DropdownItem(label: 'China', value: User(name: 'China', id: 3)),
    // DropdownItem(label: 'USA', value: User(name: 'USA', id: 4)),
    // DropdownItem(label: 'UK', value: User(name: 'UK', id: 5)),
    // DropdownItem(label: 'Germany', value: User(name: 'Germany', id: 7)),
    // DropdownItem(label: 'France', value: User(name: 'France', id: 8)),
  ];

  // Widget _buildMarketSizeField(String key) {
  //   final isRequired = !optionalFields.contains(key);

  //   if (isLoading &&
  //       ddKeys.contains(key) &&
  //       (options[key] == null || options[key]!.isEmpty)) {
  //     return IndustryInfoShimmer();
  //   }

  //   return ddKeys.contains(key)
  //       ? _buildDropdown(key, isRequired: isRequired)
  //       : _buildTextField(key, isRequired: isRequired);
  // }

  Widget _buildMarketSizeField(String key, {bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label: labels[key] ?? key, isRequired: isRequired),
        MultiDropdown<String>(
          items: marketSizeItems,
          controller: marketSizeController,
          enabled: true,
          searchEnabled: false,
          chipDecoration: ChipDecoration(
            backgroundColor: ColorManager.primary,
            border: Border.all(color: ColorManager.primary, width: 1),
            labelStyle: getRegularStyle(color: Colors.white, fontSize: 12),
            deleteIcon: Icon(Icons.close, color: Colors.white, size: 14),
            wrap: false,
            runSpacing: 2,
            spacing: 10,
          ),
          fieldDecoration: FieldDecoration(
            hintText: 'Market Size (बजार आकार)',
            hintStyle: getRegularStyle(),
            // prefixIcon: const Icon(CupertinoIcons.flag),
            showClearIcon: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black87),
            ),
          ),
          dropdownDecoration: DropdownDecoration(
            marginTop: 4,
            maxHeight: MediaQuery.of(context).size.height * 0.5,
            elevation: 3,
            header: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Select market size',
                textAlign: TextAlign.start,
                style: getSemiBoldStyle(),
              ),
            ),
          ),
          dropdownItemDecoration: DropdownItemDecoration(
            selectedIcon: Icon(Icons.check_box, color: ColorManager.success),
            disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a country';
            }
            return null;
          },
          onSelectionChange: (selectedItems) {
            debugPrint("OnSelectionChange: $selectedItems");
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading && options.isEmpty
        ? const IndustryInfoShimmer()
        : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField('industryNameNepali'),
              const SizedBox(height: 16),
              _buildField('industryNameEnglish'),
              const SizedBox(height: 16),
              _buildField('industryContactNumber'),
              const SizedBox(height: 16),
              _buildField('industryType'),
              const SizedBox(height: 16),
              _buildField('ownProperty'),
              const SizedBox(height: 16),
              _buildField('industryCapital'),
              const SizedBox(height: 16),
              _buildField('totalProperty'),
              const SizedBox(height: 16),
              _buildField('industryCapacity'),
              const SizedBox(height: 16),
              _buildMarketSizeField('marketsize'),
              const SizedBox(height: 16),
              _buildField('numberOfEmployees'),
              const SizedBox(height: 16),
              _buildField('intendedProducts'),
              _buildSectionHeader('Industry Address (उद्योगको ठेगाना)'),
              _buildField('country'),
              const SizedBox(height: 16),
              _buildField('province'),
              const SizedBox(height: 16),
              _buildField('district'),
              const SizedBox(height: 16),
              _buildField('municipality'),
              const SizedBox(height: 16),
              _buildField('wardNo'),
              const SizedBox(height: 16),
              _buildField('houseNo'),
              const SizedBox(height: 16),
              _buildField('gPlusCode'),
              const SizedBox(height: 16),
              _buildField('nearestLandmark'),
              const SizedBox(height: 8),
            ],
          ),
        );
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
