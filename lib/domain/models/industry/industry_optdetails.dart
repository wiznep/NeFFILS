class IndustryOperationalInfo {
  final String machineryDetails;
  final String rawMaterialsDetails;
  final String cleanManagement;
  final String technicalSkills;

  IndustryOperationalInfo({
    required this.machineryDetails,
    required this.rawMaterialsDetails,
    required this.cleanManagement,
    required this.technicalSkills,
  });

  factory IndustryOperationalInfo.fromJson(Map<String, dynamic> json) {
    return IndustryOperationalInfo(
      machineryDetails: json['machinery_details'] ?? '',
      rawMaterialsDetails: json['raw_materials_details'] ?? '',
      cleanManagement: json['clean_management'] ?? '',
      technicalSkills: json['technical_skills'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "machinery_details": machineryDetails,
      "raw_materials_details": rawMaterialsDetails,
      "clean_management": cleanManagement,
      "technical_skills": technicalSkills,
    };
  }
}