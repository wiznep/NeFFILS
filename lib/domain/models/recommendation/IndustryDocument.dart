class IndustryDocument {
  final String id;
  final String name;
  final String code;
  final String? fileUrl;
  final DateTime createdDate;
  final bool isVerified;
  final DateTime? verifiedDate;
  final String? verifiedBy;

  IndustryDocument({
    required this.id,
    required this.name,
    required this.code,
    required this.fileUrl,
    required this.createdDate,
    required this.isVerified,
    this.verifiedDate,
    this.verifiedBy,
  });

  factory IndustryDocument.fromJson(Map<String, dynamic> json) {
    return IndustryDocument(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      fileUrl: json['file'],
      createdDate: DateTime.parse(json['created_date_en'] ?? DateTime.now().toString()),
      isVerified: json['is_verified'] ?? false,
      verifiedDate: json['verified_date_en'] != null
          ? DateTime.parse(json['verified_date_en'])
          : null,
      verifiedBy: json['verified_by'],
    );
  }

  bool get isAdditionalDocument => code.startsWith('ADDITIONAL_DOCUMENT');
}