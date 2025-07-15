class Recommendation {
  final String id;
  final String applicationNumber;
  final String status;
  final String currentBlock;
  final String recommendationLetterNumber;
  final String recommendationChalanNumber;
  final String createdDateNp;
  final String industryId;
  final String industryNameEn;
  final String industryNameNp;
  final String dftqcOfficeNameEn;
  final String dftqcOfficeNameNp;
  final String dftqcOfficeId;
  final String recommendationOfficeNameEn;
  final String recommendationOfficeNameNp;
  final String industryAddressEn;
  final String industryAddressNp;
  final bool isPaymentVerified;
  final String? recommedationBodyWithLetterHead;
  final String? recommedationBody;

  Recommendation({
    required this.id,
    required this.applicationNumber,
    required this.status,
    required this.currentBlock,
    required this.recommendationLetterNumber,
    required this.recommendationChalanNumber,
    required this.createdDateNp,
    required this.industryId,
    required this.industryNameEn,
    required this.industryNameNp,
    required this.dftqcOfficeNameEn,
    required this.dftqcOfficeNameNp,
    required this.dftqcOfficeId,
    required this.recommendationOfficeNameEn,
    required this.recommendationOfficeNameNp,
    required this.industryAddressEn,
    required this.industryAddressNp,
    required this.isPaymentVerified,
    this.recommedationBodyWithLetterHead,
    this.recommedationBody,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      applicationNumber: json['application_number'],
      status: json['status'],
      currentBlock: json['current_block'],
      recommendationLetterNumber: json['recommendation_letter_number'],
      recommendationChalanNumber: json['recommendation_chalan_number'],
      createdDateNp: json['created_date_np'],
      industryId: json['industry_id'],
      industryNameEn: json['industry_name_en'],
      industryNameNp: json['industry_name_np'],
      dftqcOfficeNameEn: json['dftqc_office_name_en'],
      dftqcOfficeNameNp: json['dftqc_office_name_np'],
      dftqcOfficeId: json['dftqc_office_id'],
      recommendationOfficeNameEn: json['recommendation_office_name_en'],
      recommendationOfficeNameNp: json['recommendation_office_name_np'],
      industryAddressEn: json['industry_address_en'],
      industryAddressNp: json['industry_address_np'],
      isPaymentVerified: json['is_payment_verified'],
      recommedationBodyWithLetterHead: json['recommedation_body_with_letter_head'],
      recommedationBody: json['recommedation_body'],
    );
  }
}