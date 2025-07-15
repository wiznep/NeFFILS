import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:neffils/config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

import '../../../../data/services/token/token_storage_service.dart';
import '../../../../domain/models/recommendation/recommendation_view_model.dart';
import '../../../../utils/colors/color.dart';
import '../../../widgets/empty_view/empty_state_widget.dart';
import '../../../widgets/error_view/error_view.dart';
import '../../../widgets/recommendation/card/recommendation_card.dart';
import '../../../widgets/recommendation/filter/recommendation_filter.dart';
import 'add_recommendations_screen/add_recommendation_screen.dart';

class ViewRecommendationScreen extends StatefulWidget {
  const ViewRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<ViewRecommendationScreen> createState() => _ViewRecommendationScreenState();
}

class _ViewRecommendationScreenState extends State<ViewRecommendationScreen> {
  final RecommendationRepository _repository = RecommendationRepository();
  List<Recommendation> _recommendations = [];
  List<Recommendation> _filteredRecommendations = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedPaymentStatus;
  String? _selectedOffice;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recommendations = await _repository.getAllRecommendations();
      setState(() {
        _recommendations = recommendations;
        _filteredRecommendations = recommendations;
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
      _filteredRecommendations = _recommendations.where((recommendation) {
        // Apply search filter
        final matchesSearch = _searchQuery.isEmpty ||
            recommendation.industryNameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            recommendation.applicationNumber.toLowerCase().contains(_searchQuery.toLowerCase());

        // Apply payment status filter
        final matchesPaymentStatus = _selectedPaymentStatus == null ||
            (_selectedPaymentStatus == 'verified' && recommendation.isPaymentVerified) ||
            (_selectedPaymentStatus == 'not_verified' && !recommendation.isPaymentVerified);

        // Apply office filter
        final matchesOffice = _selectedOffice == null ||
            (_selectedOffice == 'food_tech' &&
                recommendation.dftqcOfficeNameEn == 'Department of Food Technology and Quality Control') ||
            (_selectedOffice == 'cottage_industry' &&
                recommendation.dftqcOfficeNameEn == 'Food Technology and Quality Control Office');

        return matchesSearch && matchesPaymentStatus && matchesOffice;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedPaymentStatus = null;
      _selectedOffice = null;
      _searchQuery = '';
      _filteredRecommendations = _recommendations;
    });
  }

  void _navigateToAddScreen() {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddRecommendationScreen(selectedIndustry: null,)),
    ).then((value) {
      if (value == true) {
        _fetchRecommendations();
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
          child: RecommendationFilter(
            selectedPaymentStatus: _selectedPaymentStatus,
            selectedOffice: _selectedOffice,
            searchQuery: _searchQuery,
            onPaymentStatusChanged: (value) {
              setState(() {
                _selectedPaymentStatus = value;
              });
            },
            onOfficeChanged: (value) {
              setState(() {
                _selectedOffice = value;
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
          'All Recommendations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterModal,
            tooltip: 'Filter Recommendations',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddScreen,
            tooltip: 'Add New Recommendation',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const RecommendationShimmer();
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        message: 'Failed to load recommendations',
        onRetry: _fetchRecommendations,
      );
    }

    if (_filteredRecommendations.isEmpty) {
      return const EmptyStateWidget(
        title: 'No recommendations found',
        subtitle: 'Try adjusting your filters or add a new recommendation',
      );
    }

    return LiquidPullToRefresh(
      onRefresh: _fetchRecommendations,
      color: appColors.formsubmit,
      backgroundColor: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredRecommendations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final recommendation = _filteredRecommendations[index];
          return RecommendationCard(
            recommendation: recommendation,
            onView: () => _showRecommendationDetails(recommendation),
          );
        },
      ),
    );
  }

  void _showRecommendationDetails(Recommendation recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recommendation.industryNameEn),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Application Number', recommendation.applicationNumber),
              _buildDetailItem('Status', recommendation.status),
              _buildDetailItem('Payment Status',
                  recommendation.isPaymentVerified ? 'Verified' : 'Not Verified'),
              _buildDetailItem('DFTQC Office', recommendation.dftqcOfficeNameEn),
              _buildDetailItem('Recommendation Office', recommendation.recommendationOfficeNameEn),
              _buildDetailItem('Created Date', recommendation.createdDateNp),
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

class RecommendationShimmer extends StatelessWidget {
  const RecommendationShimmer({Key? key}) : super(key: key);

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

class RecommendationRepository {
  final String baseUrl = '$apiUrl/license/recommendation/';

  Future<List<Recommendation>> getAllRecommendations() async {
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
      return results.map((json) => Recommendation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recommendations: ${response.statusCode}');
    }
  }
}