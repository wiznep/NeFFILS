import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:neffils/ui/color_manager.dart';
import 'package:neffils/utils/colors/color.dart';
import '../../../../domain/models/industry/industry_view_model.dart';
import '../../../../domain/repositories/industry/industry_view_repository.dart';
import '../../../widgets/empty_view/empty_state_widget.dart';
import '../../../widgets/error_view/error_view.dart';
import '../../../widgets/industry_management/industry_card.dart';
import '../../../widgets/shimmer/industry_shimmer.dart';
import '../new_license/add_license_screen/add_license_screen.dart';
import '../recommendations/add_recommendations_screen/add_recommendation_screen.dart';
import 'add_industry_management/add_industry_management_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class ViewIndustryManagementScreen extends StatefulWidget {
  const ViewIndustryManagementScreen({Key? key}) : super(key: key);

  @override
  State<ViewIndustryManagementScreen> createState() =>
      _ViewIndustryManagementScreenState();
}

class _ViewIndustryManagementScreenState
    extends State<ViewIndustryManagementScreen> with RouteAware {
  final IndustryViewRepository _repository = IndustryViewRepository();
  List<IndustryView> _industries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchIndustries();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _fetchIndustries();
  }

  Future<void> _fetchIndustries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final industries = await _repository.getAllIndustries();
      setState(() {
        _industries = industries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToAddScreen() {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (context) => const AddIndustryManagementScreen()),
    ).then((value) {
      if (value == true) {
        _fetchIndustries();
      }
    });
  }

  void _navigateToEditScreen(IndustryView industry) {
    final String id = industry.id;
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid industry ID')),
      );
      return;
    }

    Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (context) => AddIndustryManagementScreen(industryId: id)),
    ).then((value) {
      if (value == true) {
        _fetchIndustries();
      }
    });
  }

  void _navigateToRecommendation(IndustryView industry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddRecommendationScreen(selectedIndustry: industry),
      ),
    );
  }

  void _navigateToLicense(IndustryView industry) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => addLicenseScreen(selectedIndustry: industry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'All Industries',
          // style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddScreen,
            tooltip: 'Add New Industry',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const IndustryShimmer();
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        message:
            'We couldn\'t load industries.\nPlease check your connection or try again.',
        onRetry: _fetchIndustries,
      );
    }

    if (_industries.isEmpty) {
      return const EmptyStateWidget(
        title: 'No industries found',
        subtitle: 'Tap the "+" button above to add your first industry.',
      );
    }

    return LiquidPullToRefresh(
      onRefresh: _fetchIndustries,
      color: appColors.formsubmit,
      backgroundColor: Colors.white,
      animSpeedFactor: 2.0,
      showChildOpacityTransition: false,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _industries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final industry = _industries[index];
          return IndustryCard(
            industry: industry,
            onEdit:
                industry.canEdit ? () => _navigateToEditScreen(industry) : null,
            onRecommend: industry.canApplyForRecommendation
                ? () => _navigateToRecommendation(industry)
                : null,
            onLicense: industry.canApplyForLicense
                ? () => _navigateToLicense(industry)
                : null,
          );
        },
      ),
    );
  }
}
