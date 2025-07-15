import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:neffils/config/config.dart';
import 'package:neffils/domain/models/license/license_view_model.dart';
import 'package:neffils/domain/repositories/license/license_view_repository.dart';
import 'package:neffils/presentation/widgets/error_view/error_view.dart';
import 'package:neffils/presentation/widgets/new_license/card/newlicense_card.dart';
import 'package:neffils/presentation/widgets/new_license/filter/newlicense_filter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/services/token/token_storage_service.dart';
import '../../../../utils/colors/color.dart';
import '../../../widgets/empty_view/empty_state_widget.dart';
import 'add_license_screen/add_license_screen.dart';

class ViewLicenseScreen extends StatefulWidget {
  const ViewLicenseScreen({Key? key}) : super(key: key);

  @override
  _ViewLicenseScreenState createState() => _ViewLicenseScreenState();
}

class _ViewLicenseScreenState extends State<ViewLicenseScreen> {
  final LicenseRepository _repository = LicenseRepository();
  List<LicenseViewModel> _licenses = [];
  List<LicenseViewModel> _filteredLicenses = [];
  bool _isLoading = true;
  String? _selectedStatus;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchLicenses();
  }

  Future<void> _fetchLicenses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final licenses = await _repository.getAllLicenses();
      setState(() {
        _licenses = licenses;
        _filteredLicenses = licenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredLicenses = _licenses.where((license) {
        final matchesSearch = _searchQuery.isEmpty ||
            license.industrynameen.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            license.applicationnumber.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesStatus = _selectedStatus == null ||
            (_selectedStatus == 'verified' && license.status.toLowerCase() == 'verified') ||
            (_selectedStatus == 'pending' && license.status.toLowerCase() == 'pending') ||
            (_selectedStatus == 'rejected' && license.status.toLowerCase() == 'rejected');

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _searchQuery = '';
      _filteredLicenses = _licenses;
    });
  }

  void _navigateToAddScreen() {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const addLicenseScreen(selectedIndustry: null,)),
    ).then((value) {
      if (value == true) {
        _fetchLicenses();
      }
    });
  }

  Future<void> _showFilterModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: LicenseFilter(
            selectedStatus: _selectedStatus,
            searchQuery: _searchQuery,
            onStatusChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onResetFilters: _resetFilters,
            onApplyFilters: _applyFilters,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appColors.formsubmit,
        foregroundColor: Colors.white,
        title: const Text(
          'All Licenses',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterModal,
            tooltip: 'Filter Licenses',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddScreen,
            tooltip: 'Add New License',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LicenseShimmer();
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        message: 'Failed to load licenses',
        onRetry: _fetchLicenses,
      );
    }

    if (_filteredLicenses.isEmpty) {
      return const EmptyStateWidget(
        title: 'No licenses found',
        subtitle: 'Try adjusting your filters or add a new license',
      );
    }

    return LiquidPullToRefresh(
      onRefresh: _fetchLicenses,
      color: appColors.formsubmit,
      backgroundColor: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredLicenses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final license = _filteredLicenses[index];
          return LicenseCard(
            licenseViewModel: license,
            onView: () => _showLicenseDetails(license),
          );
        },
      ),
    );
  }

  void _showLicenseDetails(LicenseViewModel license) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(license.industrynameen),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Application Number', license.applicationnumber),
              _buildDetailItem('Status', license.status),
              _buildDetailItem('DFTQC Office', license.dftqctypeen),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class LicenseShimmer extends StatelessWidget {
  const LicenseShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 150,
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        width: 80,
                        height: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 80,
                        height: 30,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 60,
                        height: 30,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LicenseRepository {
  final String baseUrl = '$apiUrl/license/license-applications/';

  Future<List<LicenseViewModel>> getAllLicenses() async {
    final token = await TokenStorageService.getAccessToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => LicenseViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load licenses: ${response.statusCode}');
    }
  }
}