class IndustryView {
  final String id;
  final String nameEn;
  final String nameNp;
  final String contactNumber;
  final bool haveLicense;
  final String status;
  final String addressEn;
  final String addressNp;
  final String? proprietorNameEn;
  final String? proprietorNameNp;
  final bool canApplyForRecommendation;
  final bool canApplyForLicense;
  final bool canApplyRenewal;
  final bool canEdit;

  IndustryView({
    required this.id,
    required this.nameEn,
    required this.nameNp,
    required this.contactNumber,
    required this.haveLicense,
    required this.status,
    required this.addressEn,
    required this.addressNp,
    this.proprietorNameEn,
    this.proprietorNameNp,
    required this.canApplyForRecommendation,
    required this.canApplyForLicense,
    required this.canApplyRenewal,
    required this.canEdit,
  });

  factory IndustryView.fromJson(Map<String, dynamic> json) {
    return IndustryView(
      id: json['id'],
      nameEn: json['name_en'] ?? '',
      nameNp: json['name_np'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      haveLicense: json['have_license'] ?? false,
      status: json['status'] ?? 'DRAFT',
      addressEn: json['address_en'] ?? '',
      addressNp: json['address_np'] ?? '',
      proprietorNameEn: json['proprietor_name_en'],
      proprietorNameNp: json['proprietor_name_np'],
      canApplyForRecommendation: json['can_apply_for_recommendation'] ?? false,
      canApplyForLicense: json['can_apply_for_license'] ?? false,
      canApplyRenewal: json['can_apply_renewal'] ?? false,
      canEdit: json['can_edit'] ?? false,
    );
  }

  String get displayName => nameEn.isNotEmpty ? nameEn : nameNp;

  String get displayAddress => '$addressEn\n$addressNp';

  String get displayProprietor {
    if (proprietorNameEn != null && proprietorNameEn!.isNotEmpty) {
      return proprietorNameEn!;
    }
    return proprietorNameNp ?? 'No Proprietor';
  }
}